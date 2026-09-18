# frozen_string_literal: true

class DelayedJobExerciseJob
  def perform
    Rails.logger.info("delayed_job perform")
  end
end
