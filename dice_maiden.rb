# Dice bot for Discord
# Author: Humblemonk
# Version: 6.0.1
# Copyright (c) 2017. All rights reserved.
# !/usr/bin/ruby
require_relative 'dice_maiden_logic'

require 'discordrb'
require 'dicebag'
require 'dotenv'
require 'rest-client'
require 'sqlite3'

Dotenv.load
@total_shards = ENV['SHARD'].to_i
# Add API token
@bot = Discordrb::Bot.new token: ENV['TOKEN'], num_shards: @total_shards, shard_id: ARGV[0].to_i, ignore_bots: true, fancy_log: true
@shard = ARGV[0].to_i
@logging = ARGV[1].to_i
@prefix = ''
@check = ''

# open connection to sqlite db and set timeout to 10s if the database is busy
$db = SQLite3::Database.new "main.db"
$db.busy_timeout=(10000)

mutex = Mutex.new

@bot.message do |event|
  # Locking the thread to prevent messages going to the wrong server
  mutex.lock

  begin
    # handle !dm prefix command
    next if handle_prefix(event) == true
    # check what prefix the server should be using
    check_prefix(event)
    # check if input is even valid
    next if input_valid(event) == false

    # check for non-roll commands
    next if check_donate(event) == true
    next if check_help(event) == true
    next if check_bot_info(event) == true
    next if check_purge(event) == false
    raw_input = event.content.delete_prefix(@prefix)

    # check user
    check_user_or_nick(event)

    @rolls = create_rolls(raw_input)
    @roll_set_results = ''
    @error_check_roll_set = ''

    # process rolls
    for roll in @rolls do
      @test_status = ''
      @do_tally_shuffle = 0
      # check for modifiers that should apply to everything
      check_universal_modifiers(roll.roll_string)

      # Check for dn
      dnum = @input.scan(/dn\s?(\d+)/).first.join.to_i if @input.include?('dn')

      # Check for correct input
      next unless roll.roll_string.match?(/\dd\d/i)
      event.channel.start_typing()

      next if check_roll(event, roll.roll_string) == true

      # Do the actual roll
      if do_roll(event, roll.roll_string) == true
        error_encountered = true
        break
      end

      #Get the hashed roll result from the Roll object
      @tally = roll.hash_output(@tally)

      next if error_encountered

      if roll.wrath_roll
        @roll_set_results << build_wrath_response(roll)
      else
        @roll_set_results << build_response(roll)
      end
    end

    #log roll if applicable
    if @logging == "debug"
      log_roll(event)
    end

    # Print dice result to Discord channel
    event.respond "#{@user} Rolls:\n#{@roll_set_results}"

  rescue ArgumentError => error ## Catch any errors that were thrown by bad argument and send back to user
    event.respond(error.message)
  rescue StandardError => error ## The worst that should happen is that we catch the error and return its message.
    if(error.message == nil )
      error.message = "NIL MESSAGE!"
    end
    # Simplify roll and send it again if we error out due to character limit
    if error.message.include? "Message over the character limit"
      unless @roll_set.nil?
        event.respond "#{@user} Rolls:\n#{@error_check_roll_set}Reason: `Simplified roll due to character limit`"
      else
        event.respond "#{@user} Roll #{@dice_result} Reason: `Simplified roll due to character limit`"
      end
    elsif (error.message.include? "undefined method `join' for nil:NilClass") || (error.message.include? "The bot doesn't have the required permission to do this!")
      # do nothing
    else
      event.respond("Unexpected exception thrown! (" + error.message + ")\n\nPlease drop us a message in the #support channel on the dice maiden server, or create an issue on Github.")
    end
  end
  mutex.unlock
end

@bot.run :async

# Sleep until bot is ready and then set listening status
sleep(1) until @bot.ready
@bot.update_status("online", "!roll", nil, since = 0, afk = false, activity_type = 2)

# Check every 5 minutes and log server count
loop do
  sleep 300
  time = Time.now.getutc
  if @bot.connected? == true
    server_parse = @bot.servers.count
    $db.execute "update shard_stats set server_count = #{server_parse}, timestamp = CURRENT_TIMESTAMP where shard_id = #{@shard}"
    File.open('dice_rolls.log', 'a') { |f| f.puts "#{time} Shard: #{@shard} Server Count: #{server_parse}" }
  else
    $db.execute "update shard_stats set server_count = 0, timestamp = CURRENT_TIMESTAMP where shard_id = #{@shard}"
    File.open('dice_rolls.log', 'a') { |f| f.puts "#{time} Shard: #{@shard} bot not ready!" }
  end
  # Limit HTTP POST to shard 0. We do not need every shard hitting the discordbots API
  if @shard == 0
    servers = $db.execute "select sum(server_count) from shard_stats;"
    RestClient.post("https://discordbots.org/api/bots/377701707943116800/stats", {"shard_count": @total_shards, "server_count": servers.join.to_i}, :'Authorization' => ENV['API'], :'Content-Type' => :json);
  end
end
