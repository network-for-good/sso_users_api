module SsoUsersApi
  class Base < Flexirest::Base
    request_body_type :json
    before_request :add_authentication_details

    def initialize(attrs={})
      # convert all keys to camelcase with leading lowercase character
      attrs.deep_transform_keys!{ |key| key.to_s.camelcase(:lower) }
      super
    end

    def  self.access_token
      @@access_token
    end

    def self.access_token=(token)
      @@access_token = token
    end

    private

    def add_authentication_details(name, request)
      request.headers["Authorization"] = "Bearer #{ SsoUsersApi::Base.access_token }"
      request.headers["Content-Type"] = "application/json"
    end
  end
end