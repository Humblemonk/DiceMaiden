#!/usr/bin/ruby
# simple init script for dice maiden shards
# Due to how long discordrb takes to start, starting multiple shards at once can cause them to hang
# This script spaces the shard inits out every minute to help prevent this

i = 0

loop do
  puts "Stopping dice_maiden#{i}"
  `bluepill dice_maiden stop dice_maiden#{i}`
  sleep 2
  puts "Starting dice_maiden#{i}"
  `bluepill dice_maiden start dice_maiden#{i}`
  i += 1
  puts "Stopping dice_maiden#{i}"
  `bluepill dice_maiden stop dice_maiden#{i}`
  sleep 2
  puts "Starting dice_maiden#{i}"
  `bluepill dice_maiden start dice_maiden#{i}`
  i += 1
  break if i == ARGV[0].to_i
  sleep 30
end
