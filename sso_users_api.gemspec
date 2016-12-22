$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sso_users_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sso_users_api"
  s.version     = SsoUsersApi::VERSION
  s.authors     = ["Thomas Hoen"]
  s.email       = ["tom@givecorps.om"]
  s.homepage    = ""
  s.summary     = "Add, update, and query users on the sso server"
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.7.1"
  s.add_dependency "flexirest"

  s.add_development_dependency 'pry' # server side Rails debugging in terminal
  s.add_development_dependency 'pry-byebug' # provides stepper for pry
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'vcr'
end
