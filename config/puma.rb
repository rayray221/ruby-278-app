# frozen_string_literal: true

max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
threads max_threads, max_threads

port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "production")
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")
workers Integer(ENV.fetch("WEB_CONCURRENCY", 0))
preload_app!

plugin :tmp_restart
