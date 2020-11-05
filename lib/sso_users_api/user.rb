module SsoUsersApi
  class User < Base

    # before using, the access_token must be set on the base class, i.e
    # SsoUsersApi::Base.access_token [access_token]

    base_url SsoOpenid::Urls.identity_users.fqdn

    get :all, "/api/user"
    get :find, "/api/user/:id"
    get :search, "api/user", params_encoder: :flat # expects user_name to be passed as a parameter. The users endpoint chokes if the param is encoded/escaped
    put :update, "/api/user/:id"
    post :create, "/api/user"
  end
end