#!/usr/bin/ruby
# frozen_string_literal: true

# script for top.gg stat uploads for Dice Maiden

require 'dotenv'
require 'json'
require 'rest-client'
require 'sqlite3'

cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[../]))

Dotenv.load("#{cwd}/.env")

total_shards = ENV['SHARD'].to_i

db = SQLite3::Database.new "#{cwd}/main.db"
db.busy_timeout = (10_000)

servers = db.execute 'select sum(server_count) from shard_stats;'
puts "Current server count being submitted to topgg - #{servers}"

RestClient.post('https://top.gg/api/bots/377701707943116800/stats', { "shard_count": total_shards, "server_count": servers.join.to_i }.to_json, { Authorization: ENV['API'], content_type: :json }) do |response, _request, _result, &block|
  case response.code
  when 200
    puts 'Bot stats update successful!'
    response
  else
    puts 'Bot stat update failed!'
    response.return!(&block)
  end
end
