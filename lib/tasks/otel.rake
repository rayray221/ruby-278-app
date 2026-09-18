# frozen_string_literal: true

namespace :otel do
  desc "Trigger the multi-library exercise via Net::HTTP"
  task exercise: :environment do
    require "net/http"
    require "uri"

    uri = URI(ENV.fetch("RAILS_URL", "http://rails:3000/exercise"))
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10
    http.read_timeout = 60
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    response = http.request(request)
    puts response.body
    raise "exercise failed: #{response.code}" unless response.is_a?(Net::HTTPSuccess)
  end
end

namespace :que do
  desc "Migrate Que tables"
  task migrate: :environment do
    Que.connection = ActiveRecord
    Que.migrate!(version: Que::Migrations::CURRENT_VERSION)
  end
end
