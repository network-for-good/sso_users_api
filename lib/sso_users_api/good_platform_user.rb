module SsoUsersApi
  class GoodPlatformUser
    # Requests all related user records from the portal server,
    # which checks with each of the applications and returns all
    # of the active records for this user

    # These are then filtered for "GP" related records
    # for which both the user and the org is active.
    #
    # It returns the first, if any, of these records
    attr_accessor :user

    def self.call(user)
      self.new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      active_gp_results
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
      filtered_gp_results.select { |record| record.table.status == "active" && record.table.org_status == "active" }
    end
  end
end