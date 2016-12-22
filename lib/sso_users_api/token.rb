module SsoUsersApi
  class Token < Flexirest::Base
    base_url "https://identity-qa.networkforgood.org/connect"

    def initialize
      super
      self.scope = 'donation idmgr'
      self.grant_type = 'client_credentials'
    end
    verbose!

    # To create a new token, pass in the grant type and scope as parameters
    # SsoUserSApi::Token.create(userid: [partner user id], password: [partner password], grant_type: "client_credentials", scope: "donation idmgr")

    post :create, "/token"
  end

end