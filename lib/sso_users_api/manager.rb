module SsoUsersApi
  class Manager
    attr_accessor :user
    def initialize(user)
      @user = user
    end

    def call
      new_sso_user || update_sso_user
    end

    private

    def new_sso_user
      return nil if sso_id
      return nil if user_exists?
      response = SsoUsersApi::User.new(base_attrs).create
      # since the sso_id was nil, let's try to update it
      if user.respond_to?(:sso_id)
        user.update(sso_id: response.ID)
      end
      response
    end

    def update_sso_user
       SsoUsersApi::User.new({ id: sso_id }.merge(base_attrs)).update
    end

    def base_attrs
      {
        first_name: user.first_name,
        last_name: user.last_name,
        username: user.email,
        claims: [ { type: "nfg_account",
                    value: nfg_account_id }]
      }
    end

    def nfg_account_id
      user.respond_to?(:nfg_account_id) ? user.nfg_account_id : "0"
    end

    def sso_id
      return nil unless user.respond_to?(:sso_id)
      user.sso_id
    end

    def user_exists?
      response = SsoUsersApi::User.new(username: user.email).find
      if response.items.any?
        if user.respond_to?(:sso_id)
          user.update(sso_id: response.items.first.ID)
        end
        return true
      else
        return false
      end
    end
  end

end