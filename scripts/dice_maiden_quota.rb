#!/usr/bin/ruby
# Check current session start quota. Helpful to check how close the API toke is from being reset by Discord

require 'dotenv'

Dotenv.load('../.env')
token = ENV['TOKEN']
exec("curl -s -H \"Authorization: Bot #{token}\" https://discordapp.com/api/v6/gateway/bot | jq")
