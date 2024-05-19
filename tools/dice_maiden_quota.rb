#!/usr/bin/ruby
# Check current session start quota. Helpful to check how close the API token is from being reset by Discord

require 'dotenv'

cwd = File.expand_path(File.join(File.dirname(__FILE__), %w[../]))
Dotenv.load("#{cwd}/.env")
token = ENV['TOKEN']
exec("curl -s -H \"Authorization: Bot #{token}\" https://discordapp.com/api/v6/gateway/bot | jq")
