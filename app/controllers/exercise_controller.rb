# frozen_string_literal: true

class ExerciseController < ApplicationController
  def show
    @results = ExerciseOrchestrator.new.call
    respond_to do |format|
      format.html
      format.json { render plain: @results.to_json, content_type: "application/json" }
    end
  end
end
