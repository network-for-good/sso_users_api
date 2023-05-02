# frozen_string_literal: true

require 'sso_users_api/logger'

module SsoUsersApi
  # This class it's a wrapper to interact with Identity Server to create or update
  # User and set the sso_id that will be used as unique identifier across different apps.
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
      return if sso_id
      return if user_exists?
      response = SsoUsersApi::User.new(base_attrs).create
      # since the sso_id was nil, let's try to update it
      if user.respond_to?(:sso_id) && response&.ID
        user.update(sso_id: response.ID)
        NfgRestClient::Logger.info("---SsoUsersApi::Manager---User SSO-ID:#{user.sso_id} has been updated after create.")
      else
        # if .create method didn't return an ID with a value then we retry to find the record
        user_exists?
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
        claims: [
          {
            type: "nfg_account",
            value: nfg_account_id
          }
        ]
      }
    end

    def nfg_account_id
      user.respond_to?(:nfg_account_id) ? user.nfg_account_id : "0"
    end

    def sso_id
      return unless user.respond_to?(:sso_id)

      user.sso_id
    end

    def user_exists?
      response = SsoUsersApi::User.new(username: user.email).search
      return false unless response.items.any?

      if user.respond_to?(:sso_id)
        NfgRestClient::Logger.info("------User SSO-ID:#{user.sso_id} has been updated on an existing user.")
        user.update(sso_id: response.items.first.ID)
      end

      true
    end
  end

end
