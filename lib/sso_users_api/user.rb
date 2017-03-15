module SsoUsersApi
  class User < Base

    # before using, the access_token must be set on the base class, i.e
    # SsoUsersApi::Base.access_token [access_token]

    base_url SsoOpenid::Urls.identity_users.fqdn

    get :all, "/api/user"
    get :find, "/api/user/:id"
    put :update, "/api/user/:id"
    post :create, "/api/user"
  end
end