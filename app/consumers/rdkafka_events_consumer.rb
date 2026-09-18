# frozen_string_literal: true

class RdkafkaEventsConsumer < Racecar::Consumer
  subscribes_to "rdkafka-events"

  def process(message)
    Rails.logger.info("racecar consume topic=#{message.topic} value=#{message.value}")
  end
end
