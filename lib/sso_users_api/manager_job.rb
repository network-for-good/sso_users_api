require 'active_job'

module SsoUsersApi
  class ManagerJob  < ActiveJob::Base
    queue_as :sso_users_api

    def perform(id, class_name, count = 0)
      # do not attempt to perform the operation again if the count has exceeded 3
      return if count == 3

      user = class_name.constantize.find(id)
      SsoUsersApi::Manager.new(user).call
    rescue StandardError => e
      sleep 5 * count
      self.class.perform_later(id, class_name, count + 1)
    end

  end

end