module SsoUsersApi
  class User < Base


    # before using, the access_token must be set on the base class, i.e
    # SsoUsersApi::Base.access_token [access_token]

    base_url Rails.env.production? ? "https://users.networkforgood.org/api" : "https://users-qa.networkforgood.org/api"
    verbose true

    get :all, "/user"
    get :find, "/user/:id"
    put :update, "/user/:id"
    post :create, "/user"
  end
end