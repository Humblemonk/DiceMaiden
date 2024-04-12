#!/usr/bin/ruby
# frozen_string_literal: true

# simple ruby script for starting dice maiden eye service and reporting basic result - used with systemd service
eye = system('eye load')

if eye
  puts 'eye is starting dice maiden shards!'
else
  puts 'eye failed to start dice maiden shards!'
end
