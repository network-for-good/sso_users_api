module SsoUsersApi
  class UserApplicationAccessList < Base
    # returns a list of all of the access records
    # for the user across all apps. It uses the email
    # address of the user to do the lookup
    #
    # SsoUsersApi::UserApplicationAccessList.list email: this@that.com

    verbose true
    base_url SsoOpenid::Urls.portal.fqdn

    get :list, "/api/v1/admins"
  end
end