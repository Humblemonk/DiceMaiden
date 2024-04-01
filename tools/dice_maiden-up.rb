#!/usr/bin/ruby
# frozen_string_literal: true

# simple ruby script for starting dice maiden eye service and reporting basic result - used with systemd service
eye = system('eye load')

if eye
  puts 'eye is loading dice maiden service'
else
  puts 'eye failed to load dice maiden service!'
end
