module SsoUsersApi
  class Token < Flexirest::Base
    base_url "https://identity-qa.networkforgood.org/connect"

    def initialize
      super
      self.scope = 'donation idmgr'
      self.grant_type = 'client_credentials'
    end
    verbose!

    post :create, "/token"
  end

end