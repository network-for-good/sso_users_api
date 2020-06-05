source 'https://rubygems.org'

# Declare your gem's dependencies in sso_users_api.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :test, :development do
  #since this is only available through github, we can't add it as a development dependency
  # in the gem spec
  gem 'sso_openid', git: 'https://github.com/network-for-good/sso_openid.git', branch: 'rails_5'
end


# To use a debugger
# gem 'byebug', group: [:development, :test]
