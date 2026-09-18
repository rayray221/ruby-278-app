# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module OtelRubyApp
  class Application < Rails::Application
    config.load_defaults 7.1
    config.require_master_key = false
    config.secret_key_base = ENV.fetch("SECRET_KEY_BASE", "x" * 128)

    config.eager_load = true
    config.cache_classes = true
    config.consider_all_requests_local = true
    config.hosts.clear

    config.active_job.queue_adapter = :sidekiq
    config.cache_store = :redis_cache_store, {
      url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
    }

    config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym
    config.log_tags = [:request_id]
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = ::Logger::Formatter.new
    config.logger = ActiveSupport::TaggedLogging.new(logger)

    config.autoload_lib(ignore: %w[assets tasks])
  end
end
