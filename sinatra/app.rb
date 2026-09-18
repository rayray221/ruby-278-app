# frozen_string_literal: true

require "bundler/setup"
require "sinatra"
require "json"

set :bind, "0.0.0.0"
set :port, Integer(ENV.fetch("PORT", "4567"))
set :logging, true
set :show_exceptions, true

get "/ping" do
  content_type "text/plain"
  "ok"
end

get "/health" do
  content_type :json
  { status: "ok" }.to_json
end

# Koala Graph API mock: /me and /vX.Y/me
get "/*" do
  content_type :json
  { id: "123", name: "OTEL Test User" }.to_json
end

post "/*" do
  content_type :json
  { id: "123", name: "OTEL Test User" }.to_json
end
