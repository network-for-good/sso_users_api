$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sso_users_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sso_users_api"
  s.version     = SsoUsersApi::VERSION
  s.authors     = ["Thomas Hoen"]
  s.email       = ["tom@givecorps.om"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SsoUsersApi."
  s.description = "TODO: Description of SsoUsersApi."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7.1"
end
