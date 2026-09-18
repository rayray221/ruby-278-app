# frozen_string_literal: true

class ResqueExerciseJob
  @queue = :exercise

  def self.perform
    Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")).ping
    Rails.logger.info("resque perform")
  end
end
