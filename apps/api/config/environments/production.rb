require_relative "../application"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.force_ssl = ENV.fetch("FORCE_SSL", "false") == "true"
  config.log_level = :info
  config.active_record.dump_schema_after_migration = false
  config.require_master_key = false
end
