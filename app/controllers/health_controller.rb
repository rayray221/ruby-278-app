# frozen_string_literal: true

class HealthController < ApplicationController
  def show
    render plain: '{"status":"ok"}', content_type: "application/json"
  end
end
