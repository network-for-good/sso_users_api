module SsoUsersApi
  class AllAppUsers
    attr_accessor :user

    def self.call(user)
      self.new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      all_app_users_results
    rescue Flexirest::HTTPNotFoundClientException
      []
    end

    private

    def all_app_users_results
      raw_results.items
    end

    def raw_results
      @raw_results ||= SsoUsersApi::UserApplicationAccessList.list email: user.email.downcase
    end
  end
end