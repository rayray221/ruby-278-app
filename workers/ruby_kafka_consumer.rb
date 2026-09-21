# frozen_string_literal: true

require_relative "../config/environment"

brokers = ENV.fetch("KAFKA_BROKERS", "localhost:9092")
kafka = Kafka.new([brokers], client_id: "ruby-kafka-consumer")

Rails.logger.info("ruby-kafka consumer waiting on ruby-kafka-events")
kafka.each_message(topic: "ruby-kafka-events", start_from_beginning: false) do |message|
  Rails.logger.info("ruby-kafka consume offset=#{message.offset} value=#{message.value}")
end
