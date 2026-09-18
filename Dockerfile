FROM ruby:2.7.8-bullseye
# Optional: docker build --platform linux/amd64

# Debian 11 (bullseye) is EOL; use the archive mirror and skip the removed security pocket.
RUN rm -f /etc/apt/sources.list.d/* \
    && printf 'deb http://archive.debian.org/debian bullseye main\ndeb http://archive.debian.org/debian bullseye-updates main\n' > /etc/apt/sources.list \
    && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid \
    && apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    libsasl2-dev \
    libzstd-dev \
    liblz4-dev \
    zlib1g-dev \
    libpq-dev \
    default-libmysqlclient-dev \
    liblmdb-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "development test" \
    && bundle install --jobs 4 --retry 3

COPY . .

RUN mkdir -p tmp/pids tmp/cache log /tmp/lmdb \
    && chmod +x docker-entrypoint.sh bin/rails bin/rake

ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development:test"

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["rails-server"]
