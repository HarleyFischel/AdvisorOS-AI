ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "factory_bot_rails"

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
end

module RequestSecurityHelpers
  def csrf_headers
    get "/api/v1/csrf", headers: { "Accept" => "application/json" }
    raise "CSRF endpoint failed: #{response.status} #{response.body[0, 200]}" unless response.successful?
    { "X-CSRF-Token" => JSON.parse(response.body).fetch("csrf_token") }
  end
end

RSpec.configure { |config| config.include RequestSecurityHelpers, type: :request }
