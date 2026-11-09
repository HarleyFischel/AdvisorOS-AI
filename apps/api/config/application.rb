require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module AdvisorOs
  class Application < Rails::Application
    config.load_defaults 8.1
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
    config.autoload_lib(ignore: %w[assets tasks])
    config.generators.system_tests = nil
    config.action_dispatch.cookies_same_site_protection = :lax
    config.action_dispatch.use_authenticated_cookie_encryption = true
    config.session_store :cookie_store, key: "_advisor_os_session", secure: Rails.env.production?, httponly: true, same_site: :lax
    config.middleware.use Rack::Cors do
      allow do
        origins(*ENV.fetch("FRONTEND_ORIGINS", "http://localhost:5173").split(","))
        resource "/api/*", headers: :any, methods: %i[get post patch delete options], credentials: true
      end
    end
    config.action_controller.default_protect_from_forgery = true
  end
end
