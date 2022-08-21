# Dice bot for Discord
# Author: Humblemonk
# Version: 8.0.1
# Copyright (c) 2017. All rights reserved.
# !/usr/bin/ruby
# If you wish to run a single instance of this bot, please follow the "Manual Install" section of the readme!
require_relative 'dice_maiden_logic'
require_relative 'earthdawn_logic'

require 'discordrb'
require 'dicebag'
require 'dotenv'
require 'rest-client'
require 'sqlite3'

Dotenv.load
@total_shards = ENV['SHARD'].to_i
# Add API token
@bot = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], num_shards: @total_shards, shard_id: ARGV[0].to_i,
                          intents: %i[servers server_messages direct_messages], ignore_bots: true, fancy_log: true
@bot.gateway.check_heartbeat_acks = false
@shard = ARGV[0].to_i
@launch_option = ARGV[1].to_s
@prefix = ''
@check = ''
@request_option = false

# open connection to sqlite db and set timeout to 10s if the database is busy
if @launch_option == 'lite'
  # do nothing
else
  $db = SQLite3::Database.new 'main.db'
  $db.busy_timeout = (10_000)
end

mutex = Mutex.new

if @shard == 0
  puts "Shard #{@shard} is registering commands"
  @bot.register_application_command(:roll, 'Ask Dice Maiden to roll some dice!') do |cmd|
    cmd.string('message', 'Roll syntax sent to Dice Maiden')
  end

  @bot.register_application_command(:r, 'Ask Dice Maiden to roll some dice!') do |cmd|
    cmd.string('message', 'Roll syntax sent to Dice Maiden')
  end
end

inc_cmd = ->(event) do
  # Locking the thread to prevent messages going to the wrong server
  mutex.lock
  begin
    @event_roll = event.options.values.join("")
    # handle !dm <command>. DEPRECATED WITH SLASH COMMANDS
    #next if check_server_options(@event_roll) == true

    # check what prefix the server should be using. DEPRECATED WITH SLASH COMMANDS
    #check_prefix(@event_roll)
    # check if input is even valid. DEPRECATED WITH SLASH COMMANDS
    # next if input_valid(@event_roll) == false

    check_request_option(event)
    @input = alias_input_pass(@event_roll) # Do alias pass as soon as we get the message
    @simple_output = false
    @wng = false
    @dh = false
    @do_tally_shuffle = false
    @ed = false

    check_roll_modes

    next if @ed && !replace_earthdawn(event)

    @roll_set = nil
    next unless roll_sets_valid(event)

    if @input =~ /^\s*d/
      roll_to_one = @input.lstrip
      roll_to_one.prepend('1')
      @input = roll_to_one
    end

    @roll = @input
    @check = @prefix + @roll
    @comment = ''
    @test_status = ''
    # check user
    check_user_or_nick(event) if !event.channel.pm?
    # check for comment
    check_comment
    # check for modifiers that should apply to everything
    check_universal_modifiers

    # Check for dn
    dnum = @input.scan(/dn\s?(\d+)/).first.join.to_i if @input.match?(/^(1dn)\d+/i)

    # Check for correct input
    if @roll.match?(/\dd\d/i)
      event.channel.start_typing
      next if check_roll(event) == true

      # Check for wrath roll
      check_wrath
      # Grab dice roll, create roll, grab results
      if @roll_set.nil?
        next if do_roll(event) == true
      else
        @roll_set_results = ''
        @error_check_roll_set = ''
        roll_count = 0
        error_encountered = false
        while roll_count < @roll_set.to_i
          if do_roll(event) == true
            error_encountered = true
            break
          end
          @tally = alias_output_pass(@tally)
          if @simple_output == true
            @roll_set_results << "#{@dice_result}\n"
          else
            @error_check_roll_set << "#{@dice_result}\n"
            @roll_set_results << "`#{@tally}` #{@dice_result}\n"
          end
          roll_count += 1
        end
        next if error_encountered

        log_roll(event) if @launch_option == 'debug'
        if @comment.to_s.empty? || @comment.to_s.nil?
          event.respond(content:"#{@user} Rolls:\n#{@roll_set_results}")
        else
          event.respond(content:"#{@user} Rolls:\n#{@roll_set_results} Reason: `#{@comment}`")
        end
        next
      end

      # Output aliasing
      @tally = alias_output_pass(@tally)

      # Grab event user name, server name and timestamp for roll and log it
      log_roll(event) if @launch_option == 'debug'

      # Print dice result to Discord channel
      @has_comment = !@comment.to_s.empty? && !@comment.to_s.nil?
      if check_wrath == true
        respond_wrath(event, dnum)
      else
        event.respond(content: build_response)
        check_fury(event)
      end
    end
    next if check_donate(event) == true
    next if check_help(event) == true
    next if check_bot_info(event) == true
    next if check_purge(event) == false
 rescue StandardError => e ## The worst that should happen is that we catch the error and return its message.
    e.message = 'NIL MESSAGE!' if e.message.nil?
     #Simplify roll and send it again if we error out due to character limit
    if (e.message.include? 'Message over the character limit') || (e.message.include? 'Invalid Form Body')
      if @roll_set.nil?
        event.respond(content:"#{@user} Roll #{@dice_result} Reason: `Simplified roll due to character limit`")
      else
        event.respond(content:"#{@user} Rolls:\n#{@error_check_roll_set}Reason: `Simplified roll due to character limit`")
      end
    elsif (e.message.include? "undefined method `join' for nil:NilClass") || (e.message.include? "The bot doesn't have the required permission to do this!") || (e.message.include? '500: Internal Server Error')
      time = Time.now.getutc
      File.open('dice_rolls.log', 'a') { |f| f.puts "#{time} ERROR: #{e.message}" }
    else
      event.respond(content:('Unexpected exception thrown! (' + e.message + ")\n\nPlease drop us a message in the #support channel on the dice maiden server, or create an issue on Github."))
    end
  end
  mutex.unlock
end

@bot.application_command(:roll, &inc_cmd)
@bot.application_command(:r, &inc_cmd)

if @launch_option == 'lite'
  @bot.run
else
  @bot.run :async

  # Sleep until bot is ready and then set listening status
  sleep(1) until @bot.ready
  @bot.update_status('online', '/roll', nil, since = 0, afk = false, activity_type = 2)
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
      # Bot died and cant connect to Discord. Kill the bot and have eye restart it
      exit!
    end
    # Limit HTTP POST to shard 0. We do not need every shard hitting the discordbots API
    next unless @shard == 0

    servers = $db.execute 'select sum(server_count) from shard_stats;'
    RestClient.post('https://top.gg/api/bots/377701707943116800/stats',
                    { "shard_count": @total_shards, "server_count": servers.join.to_i }, 'Authorization': ENV['API'], 'Content-Type': :json)
  end
end
