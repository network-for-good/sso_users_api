module SsoUsersApi
  class Token < Flexirest::Base
    verbose true
    base_url Rails.env.production? ? "https://identity.networkforgood.org/connect" : "https://identity-qa.networkforgood.org/connect"

    def initialize
      super
      self.scope = 'donation idmgr'
      self.grant_type = 'client_credentials'
    end


    post :create, "/token"

  end

end