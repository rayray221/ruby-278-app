# frozen_string_literal: true

Rails.application.routes.draw do
  get "/health", to: "health#show"
  get "/exercise", to: "exercise#show"
  root "health#show"
end
