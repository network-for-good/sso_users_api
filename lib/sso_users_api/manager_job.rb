# frozen_string_literal: true

require 'sidekiq'
require 'active_record'
require_relative 'exception_handler'

module SsoUsersApi
  # Creates and updates users using the Network for Good identity server
  # @see SsoUsersApi::Manager
  # @TODO: is there additional documentation we can reference here?
  class ManagerJob
    include Sidekiq::Worker

    # @param [#call] Dependency injection port for host application notification systems like Honeybadger
    # @example Installing Honeybadger
    #   SsoUsersApi::ManagerJob.exception_notifier = Honeybadger.public_method(:notify)
    cattr_accessor :exception_notifier, default: Sidekiq.logger.public_method(:error)

    sidekiq_options queue: :high_priority, retry: 5

    sidekiq_retries_exhausted do |msg, retried_exception|
      original_ex = retried_exception.cause
      Rails.logger.warn "Failed retrying '#{original_ex.class.name})'with args #{msg['args']}: #{msg['error_message']}"

      exception_notifier.call(original_ex)
    end

    # @param [#call] Dependency injection port for module to parse UAT server exceptions
    # @see SsoUsersApi::ExceptionHandler
    attr_writer :exception_handler

    # @param id [Integer] Identifies the record to create or update
    # @param class_name [String] Identifies the record's class (example: Admin)
    # @param [Hash] options additional job parameters
    # @option on_success_call_back_job_name [String] Identifies the follow-on job to be executed upon success
    # @raise [NameError] when invoked with unrecognized class_name or on_success_call_back_job_name
    def perform(id, class_name, options = {})
      log_tag = "#{class_name} ##{id}"

      user = class_name.constantize.find(id)
      SsoUsersApi::Manager.new(user).call

      callback_job_name = options['on_success_call_back_job_name']
      return if callback_job_name.blank?

      callback_job_class = callback_job_name.constantize
      new_job_id = callback_job_class.perform_async(id)

      Rails.logger.info "Invoked #{callback_job_class} success callback for #{log_tag} (Job ID ##{new_job_id})"
    rescue Flexirest::RequestException => e
      reraisable_exception = exception_handler.call(e) do |ignorable_msg|
        # if the handler yields, we know it is safe to log & ignore the exception
        Rails.logger.warn ignorable_msg
        return # rubocop:disable Lint/NonLocalExitFromIterator
      end

      Rails.logger.error "Re-raising #{e.class} - #{e.message}"
      # if the handler did not yield, we should raise the returned exception
      raise reraisable_exception
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "Unable to find #{log_tag}"
    end

    private

    def exception_handler
      @exception_handler ||= SsoUsersApi::ExceptionHandler.new
    end
  end
end
