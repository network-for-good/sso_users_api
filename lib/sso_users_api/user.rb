module SsoUsersApi
  class User < Base
    verbose!

    # before using, the access_token must be set on the base class, i.e
    # SsoUsersApi::Base.access_token [access_token]

    base_url "https://users-qa.networkforgood.org/api"
    verbose true

    get :all, "/user"
    get :find, "/user/:id"
    put :update, "/user/:id"
    post :create, "/user"
  end
end