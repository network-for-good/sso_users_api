require 'spec_helper'
require 'webmock/rspec'
require 'vcr'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
Rails.backtrace_cleaner.remove_silencers!

#
# Load support files
ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

RSpec.configure do |config|
  config.order = "random"
end

VCR.configure do |config|
 config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
 config.hook_into :webmock
end

require "sso_users_api"