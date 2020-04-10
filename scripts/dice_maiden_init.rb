#!/usr/bin/ruby
# simple init script for dice maiden shards
# Due to how long discordrb takes to start, starting too many shards at once can cause them to hang
# This script spaces the shard inits out to help prevent this

shard_count = 0

loop do
  10.times { puts "Restarting dice_maiden#{shard_count}"; `bundle exec bluepill dice_maiden restart dice_maiden#{shard_count}`; shard_count +=1}
  break if shard_count == ARGV[0].to_i
  sleep 30
end
