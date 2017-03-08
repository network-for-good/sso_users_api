module SsoUsersApi
  class UserApplicationAccessList < Base
    verbose true
    base_url SsoOpenid::Urls.portal.fqdn

    get :list, "/api/v1/admins"
  end
end