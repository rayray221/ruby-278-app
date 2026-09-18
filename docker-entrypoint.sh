#!/usr/bin/env bash
set -euo pipefail

mkdir -p tmp/pids tmp/cache log /tmp/lmdb

if [[ "${1:-}" == "rails-server" ]]; then
  if [[ -n "${DATABASE_URL:-}" ]]; then
    host="$(ruby -ruri -e 'puts URI(ENV.fetch("DATABASE_URL")).host')"
    echo "waiting for postgres at ${host}..."
    until pg_isready -h "${host}" -q; do
      sleep 2
    done
  fi
  bundle exec rake db:prepare
  bundle exec rake que:migrate
  exec bundle exec puma -C config/puma.rb
fi

exec "$@"
