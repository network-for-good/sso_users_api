module SsoUsersApi
  class ManagerJob
    def self.delay_amount
      2
    end

    def perform(id, class_name, count = 0, options = {})
      user = class_name.constantize.find(id)
      SsoUsersApi::Manager.new(user).call
      begin
        options[:on_success_call_back_job_name].constantize.perform_later(id) if options[:on_success_call_back_job_name].present?
      rescue StandardError => e
        NfgRestClient::Logger.error("Failed to execute: #{options[:on_success_call_back_job_name]}, error: #{e.message}")
      end

    rescue StandardError => e
      # do not attempt to perform the operation again if this is the third attempt
      if count >= 2
        raise
      else
        sleep self.class.delay_amount * count
        self.class.perform_later(id, class_name, count + 1, options)
      end
    end
  end
end
