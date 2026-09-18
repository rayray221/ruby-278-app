# frozen_string_literal: true

Delayed::Worker.max_attempts = 3
Delayed::Worker.sleep_delay = 2
