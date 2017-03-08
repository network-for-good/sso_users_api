module SsoUsersApi
  class GoodPlatformUser
    attr_accessor :user

    def self.call(user)
      self.new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      filtered_gp_results
    rescue Flexirest::HTTPNotFoundClientException
      []
    end

    private

    def raw_results
      @raw_results ||= SsoUsersApi::UserApplicationAccessList.list email: user.email.downcase
    end

    def filtered_gp_results
      raw_results.items.select { |record| record.table.app.downcase.match(/gp/) }
    end

    def active_gp_results
      filtered_gp_results.select { |record| record.status == "active"}
    end
  end
end