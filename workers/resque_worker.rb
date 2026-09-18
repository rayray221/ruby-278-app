# frozen_string_literal: true

require_relative "../config/environment"

worker = Resque::Worker.new("exercise")
worker.prepare
Rails.logger.info("resque worker starting")
worker.work(5)
