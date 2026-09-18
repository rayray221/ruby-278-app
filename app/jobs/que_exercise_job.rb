# frozen_string_literal: true

class QueExerciseJob < Que::Job
  def run
    Rails.logger.info("que perform")
  end
end
