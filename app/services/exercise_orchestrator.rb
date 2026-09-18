# frozen_string_literal: true

require "aws-sdk-s3"
require "bunny"
require "concurrent"
require "dalli"
require "ethon"
require "excon"
require "faraday"
require "fileutils"
require "http"
require "httpclient"
require "kafka"
require "koala"
require "lmdb"
require "mongo"
require "mysql2"
require "net/http"
require "rdkafka"
require "redis"
require "redis-client"
require "restclient"
require "trilogy"
require "uri"

class ExerciseOrchestrator
  def call
    @steps = {}
    @errors = {}

    widget = step("activerecord_pg") { persist_widget }
    step("active_model_serializers") { serialize_widget(widget) }
    step("activesupport_cache") { rails_cache }
    step("graphql") { AppSchema.execute("{ health }").to_h }
    step("concurrent_ruby") { run_concurrent }
    step("mysql2") { mysql2_query }
    step("trilogy") { trilogy_query }
    step("mongo") { mongo_write }
    step("redis") { redis_write }
    step("redis_client") { redis_client_ping }
    step("dalli") { dalli_write }
    step("lmdb") { lmdb_write }
    step("koala_faraday_net_http") { koala_facebook }
    step("faraday") { Faraday.get(echo_url).status }
    step("excon") { Excon.get(echo_url, read_timeout: 2).status }
    step("ethon") { ethon_get }
    step("http") { HTTP.timeout(2).get(echo_url).status }
    step("httpclient") { HTTPClient.new.get(echo_url).status }
    step("rest_client") { RestClient::Request.execute(method: :get, url: echo_url, timeout: 2).code }
    step("aws_sdk_s3") { s3_put_get }
    step("activejob_sidekiq_client") { ExerciseJob.perform_later(widget&.id) }
    step("resque_client") { Resque.enqueue(ResqueExerciseJob) }
    step("delayed_job_client") { DelayedJobExerciseJob.new.delay.perform }
    step("que_client") { QueExerciseJob.enqueue }
    step("bunny_producer") { bunny_publish }
    step("ruby_kafka_producer") { ruby_kafka_produce }
    step("rdkafka_producer") { rdkafka_produce }

    {
      serialized_widget: @steps["active_model_serializers"],
      graphql: @steps["graphql"],
      steps: @steps,
      errors: @errors
    }
  end

  private

  def step(name)
    @steps[name] = yield
  rescue StandardError => e
    @errors[name] = "#{e.class}: #{e.message}"
    nil
  end

  def echo_url
    ENV.fetch("ECHO_URL", "http://echo:80/")
  end

  def persist_widget
    widget = Widget.create!(name: "exercise-#{Time.now.to_i}")
    Widget.find(widget.id)
  end

  def serialize_widget(widget)
    return nil unless widget

    ActiveModelSerializers::SerializableResource.new(widget, serializer: WidgetSerializer).as_json
  end

  def rails_cache
    Rails.cache.write("exercise", "1", expires_in: 5.minutes)
    Rails.cache.read("exercise")
  end

  def run_concurrent
    pool = Concurrent::FixedThreadPool.new(2)
    future = Concurrent::Promises.future_on(pool) { Rails.cache.read("exercise") }
    value = future.value!(5)
    pool.shutdown
    pool.wait_for_termination(5)
    value
  end

  def mysql_config
    {
      host: ENV.fetch("MYSQL_HOST", "mysql"),
      port: Integer(ENV.fetch("MYSQL_PORT", "3306")),
      username: ENV.fetch("MYSQL_USER", "otel"),
      password: ENV.fetch("MYSQL_PASSWORD", "otel"),
      database: ENV.fetch("MYSQL_DATABASE", "otel")
    }
  end

  def mysql2_query
    client = Mysql2::Client.new(mysql_config.merge(connect_timeout: 5, read_timeout: 5))
    row = client.query("SELECT 1 AS ok").first
    client.close
    row
  end

  def trilogy_query
    cfg = mysql_config
    client = Trilogy.new(
      host: cfg[:host],
      port: cfg[:port],
      username: cfg[:username],
      password: cfg[:password],
      database: cfg[:database],
      connect_timeout: 5,
      read_timeout: 5
    )
    result = client.query("SELECT 1 AS ok")
    rows = result.to_a
    client.close
    rows
  end

  def mongo_write
    client = Mongo::Client.new(ENV.fetch("MONGO_URL", "mongodb://mongo:27017/otel"), server_selection_timeout: 5)
    coll = client[:widgets]
    coll.insert_one(name: "exercise", at: Time.now)
    doc = coll.find.first
    client.close
    doc && doc["name"]
  end

  def redis_write
    redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
    redis.set("exercise", "1")
    value = redis.get("exercise")
    redis.close
    value
  end

  def redis_client_ping
    client = RedisClient.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
    pong = client.call("PING")
    client.close
    pong
  end

  def dalli_write
    dc = Dalli::Client.new(ENV.fetch("MEMCACHED_URL", "memcached:11211"), socket_timeout: 2)
    dc.set("exercise", "1")
    value = dc.get("exercise")
    dc.close
    value
  end

  def lmdb_write
    dir = ENV.fetch("LMDB_PATH", "/tmp/lmdb")
    FileUtils.mkdir_p(dir)
    env = LMDB.new(dir)
    db = env.database
    db["exercise"] = "1"
    value = db["exercise"]
    env.close
    value
  end

  def koala_facebook
    uri = URI(ENV.fetch("SINATRA_URL", "http://sinatra:4567"))
    # Koala 3.5 ignores a per-call :server option and always uses graph_server.
    Koala.configure do |config|
      config.graph_server = "#{uri.host}:#{uri.port}"
    end
    api = Koala::Facebook::API.new("test-token")
    api.get_object("me", {}, use_ssl: false)
  end

  def ethon_get
    easy = Ethon::Easy.new(url: echo_url, timeout: 2)
    easy.perform
    easy.response_code
  end

  def s3_put_get
    client = Aws::S3::Client.new(
      endpoint: ENV.fetch("AWS_ENDPOINT", "http://localstack:4566"),
      region: ENV.fetch("AWS_REGION", "us-east-1"),
      access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID", "test"),
      secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY", "test"),
      force_path_style: true,
      http_open_timeout: 5,
      http_read_timeout: 5
    )
    bucket = ENV.fetch("S3_BUCKET", "otel-exercise")
    client.create_bucket(bucket: bucket)
    client.put_object(bucket: bucket, key: "hello.txt", body: "hello")
    body = client.get_object(bucket: bucket, key: "hello.txt").body.read
    body
  rescue Aws::S3::Errors::BucketAlreadyOwnedByYou, Aws::S3::Errors::BucketAlreadyExists
    client.put_object(bucket: bucket, key: "hello.txt", body: "hello")
    client.get_object(bucket: bucket, key: "hello.txt").body.read
  end

  def bunny_publish
    conn = Bunny.new(ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@localhost:5672"),
                     connection_timeout: 5, automatically_recover: false)
    conn.start
    ch = conn.create_channel
    q = ch.queue("otel.exercise", durable: true)
    q.publish("exercise", persistent: true)
    conn.close
    true
  end

  def ruby_kafka_produce
    kafka = Kafka.new(
      [ENV.fetch("KAFKA_BROKERS", "localhost:9092")],
      client_id: "otel-rails",
      connect_timeout: 5,
      socket_timeout: 5
    )
    kafka.deliver_message("exercise", topic: "ruby-kafka-events")
    kafka.close
    true
  end

  def rdkafka_produce
    producer = Rdkafka::Config.new(
      "bootstrap.servers": ENV.fetch("KAFKA_BROKERS", "localhost:9092"),
      "socket.timeout.ms": 5000
    ).producer
    producer.produce(topic: "rdkafka-events", payload: "exercise").wait(max_wait_timeout: 5)
    producer.close
    true
  end
end
