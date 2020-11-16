require 'sidekiq'

module SsoUsersApi
  class ManagerJob
    include Sidekiq::Worker

    sidekiq_options queue: :high_priority, retry: 0

    def perform(id, class_name, options = {})
      user = class_name.constantize.find(id)
      SsoUsersApi::Manager.new(user).call
      callback_job_name = options['on_success_call_back_job_name']
      callback_job_name.constantize.perform_async(id) if callback_job_name.present?
    end
  end
end
