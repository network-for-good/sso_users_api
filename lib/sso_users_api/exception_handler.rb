# frozen_string_literal: true

require_relative 'retryable_exception'
require 'flexirest'

module SsoUsersApi
  # Examines exceptions raised by the SSO User API to determine which can be
  # ignored, retried, or reported.
  # @example: Ignorable client exceptions (4xx) that will be logged
  #   "User already exists on one of the platforms"
  #   "Email already in use."
  # @example: Retryable, transient exception
  #   Flexirest::TimeoutException
  # @example: Client exception indicating a bug that should be reported as an xceptions
  #   "Invalid email"
  # @see SsoUsersApi::ManagerJob
  class ExceptionHandler
    # Decides if an exception is retryable, ignorable, or reportable
    # @param exception [Exception] the original exception
    # @yieldparam ignore_msg [String] describes how to log errors that can be ignored
    # @return [SsoUsersApi::RetryableException] if this exception should be retried
    #   without reporting - wraps the original exception
    # @return [Flexirest::RequestException] if this exception can be retried, but
    #   should also be reported to an exception notification service, we return the
    #   original exception
    def call(exception)
      message = exception.message
      err_tag = "#{exception.class} - #{message}"

      case exception
      when Flexirest::TimeoutException, Flexirest::HTTPServerException
        # API timeouts and 5xx errors can be re-tried by Sidekiq
        return SsoUsersApi::RetryableException.new(err_tag)
      when Flexirest::HTTPClientException
        if message =~ MATCH_IGNORABLE_CLIENT_EXCEPTIONS
          # these exceptions are expected and should not be re-raised
          yield "#{err_tag} (expected / ignorable exception)"
          return :non_retryable_sentinel_value # prevents leaking nil value back to the calling method
        end
      end

      # if we have fallen through here, the exception is returned to the caller as a potential bug;
      # it can still be retried by Sidekiq, but should also be reported to the exception notifier
      exception
    end
  end

  private_constant

  MATCH_IGNORABLE_CLIENT_EXCEPTIONS = /(User already exists|Email already in use)/i.freeze
end
