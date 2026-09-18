# frozen_string_literal: true

class ExerciseJob < ApplicationJob
  queue_as :default

  def perform(widget_id = nil)
    Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")).get("exercise")
    Widget.find_by(id: widget_id) if widget_id
    Rails.logger.info("sidekiq/activejob perform widget_id=#{widget_id}")
  end
end
