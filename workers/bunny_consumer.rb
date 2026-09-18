# frozen_string_literal: true

require_relative "../config/environment"

conn = Bunny.new(ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@localhost:5672"),
                 automatically_recover: true)
conn.start
channel = conn.create_channel
queue = channel.queue("otel.exercise", durable: true)

Rails.logger.info("bunny consumer waiting on otel.exercise")
queue.subscribe(block: true, manual_ack: false) do |_delivery_info, _properties, body|
  Rails.logger.info("bunny consume body=#{body}")
end
