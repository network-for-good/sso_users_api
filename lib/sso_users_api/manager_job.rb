require 'active_job'

module SsoUsersApi
  class ManagerJob  < ActiveJob::Base
    queue_as :sso_users_api

    def self.delay_amount
      2
    end

    def perform(id, class_name, count = 0)

      user = class_name.constantize.find(id)
      SsoUsersApi::Manager.new(user).call

    rescue StandardError => e
      # do not attempt to perform the operation again if this is the third attempt
      if count >= 2
        raise
      else
        sleep self.class.delay_amount * count
        self.class.perform_later(id, class_name, count + 1)
      end
    end
  end
end