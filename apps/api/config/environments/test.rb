require_relative "../application"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_dispatch.show_exceptions = false
  config.action_controller.perform_caching = false
  config.cache_store = :null_store
  config.active_job.queue_adapter = :test
  config.active_support.deprecation = :stderr
end
