# frozen_string_literal: true

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = true
  config.public_file_server.enabled = true
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
  config.hosts.clear
end
