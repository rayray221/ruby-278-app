# frozen_string_literal: true

Racecar.configure do |config|
  config.brokers = ENV.fetch("KAFKA_BROKERS", "localhost:9092").split(",")
  config.client_id = "otel-racecar"
  config.group_id = "otel-racecar"
  config.consumer << "auto.offset.reset=earliest"
end
