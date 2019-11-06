# Dice bot for Discord
# Author: Humblemonk
# Version: 3.1.2
# Copyright (c) 2017. All rights reserved.
# !/usr/bin/ruby

require 'discordrb'
require '../Dice-Bag/lib/dicebag.rb'
require 'dotenv'
require 'net/ping'
require 'rest-client'
require 'sqlite3'

def check_user_or_nick(event)
  if event.user.nick != nil
    @user = event.user.nick
  else
    @user = event.user.name
  end
end

def check_comment
  if @input.include?('!')
    @comment = @input.partition('!').last
    @roll = @input[/(^.*)!/]
    @roll.slice! @comment
    @roll.slice! '!'
  end
end

def check_roll(event)
  # Check that the dice is not greater than D100
  @special_check = @roll.scan(/d(\d+)/).first.join.to_i
  @dice_check = @roll.scan(/d(\d+)/).first.join.to_i

  if @dice_check <= 1
    event.respond 'Please roll a dice value 2 or greater'
    return true
  end
  if @dice_check > 100
    event.respond 'Please roll dice up to d100'
    return true
  end
  # Check for too large of dice pools
  @dice_check = @roll.scan(/(\d+)d/).first.join.to_i
  if @dice_check > 500
    event.respond 'Please keep the dice pool below 500'
    return true
  end
end

def check_wrath
  if (@special_check == 6) && (@event_server_check.include? 'FMK') && ((@comment.include? 'soak') || (@comment.include? 'exempt') || (@comment.include? 'dmg'))
  elsif (@special_check == 6) && (@event_server_check.include? 'FMK')
    @roll = "#{@dice_check - 1}d6"
    wstr = '(Wrath Dice) 1d6'
    wroll = DiceBag::Roll.new(wstr)
    @wresult = wroll.result
    @wresult_convert = @wresult.to_s
    @wrath_value = @wresult_convert.scan(/\d+/).first
    true
  end
end

def do_roll(event)
  dstr = "(Result) #{@roll}"
  begin
    dice_roll = DiceBag::Roll.new(dstr)
    # Rescue on bad dice roll syntaxs
    rescue Exception
      event.respond 'Incorrect format'
      return true
  end
  @dice_result = dice_roll.result
  # Parse the roll and grab the total tally
  parse_roll = dice_roll.tree
  parsed = parse_roll.inspect
  @tally = parsed.scan(/tally=\[.*?\]/)
  @tally = String(@tally)
  @tally.gsub!(/\[*("tally=)|\"\]|\"/, '')
end

def log_roll(event)
  @server = event.server.name
  @time = Time.now.getutc
  unless @roll_set.nil?
    File.open('dice_rolls.log','a') { |f| f.puts "#{@time} Shard: #{@shard} | #{@server}| #{@user} Rolls:\n #{@roll_set_results}" }
  else
    File.open('dice_rolls.log', 'a') { |f| f.puts "#{@time} Shard: #{@shard} |#{@server}| #{@user} Roll: #{@tally} #{@dice_result}" }
  end
end

def check_fury(event)
  if (@special_check == 10) && (@tally.include? '10') && (@event_server_check.include? 'FMK')
    event.respond '`Righteous Fury Activated!` Purge the Heretic!'
  end
end

def check_icons
  @fours = @tally.scan(/4/).count
  @fives = @tally.scan(/5/).count
  @exalted_icons = @tally.scan(/6/).count
  @exalted_icons += 1 if @wresult_convert.include? '6'
  if (@wresult_convert.include? '4') || (@wresult_convert.include? '5')
    @wrath_icon = 1
  else
    @wrath_icon = 0
  end
  @exalted_total = @exalted_icons * 2
  @icons = @fours + @fives + @wrath_icon
end

def check_dn(dnum)
  icon_total = @icons + @exalted_total
  @test_status = if icon_total >= dnum
                   '**TEST PASSED!**'
                 else
                   '**TEST FAILED!**'
  end
end

def event_no_comment_wrath(event, dnum)
  if @roll == '0d6'
    event.respond "#{@user} Roll: Wrath: `#{@wrath_value}`"
  else
    check_icons
    if dnum.to_s.empty? || dnum.to_s.nil?
    else
      check_dn(dnum)
    end
    event.respond "#{@user} Roll: `#{@tally}` Wrath: `#{@wrath_value}` | #{@test_status} TOTAL - Icons: `#{@icons}` Exalted Icons: `#{@exalted_icons} (Value:#{@exalted_total})`"
    if @wresult_convert.include? '6'
      event.respond 'Combat critical hit and one point of Glory!'
    elsif @wresult_convert.include? '1'
      event.respond 'Complication!'
    end
  end
end

def event_comment_wrath(event, dnum)
  if @roll == '0d6'
    event.respond "#{@user} Roll Wrath: `#{@wrath_value}`"
    event.respond "Roll Reason: `#{@comment}`"
  else
    check_icons
    if dnum.to_s.empty? || dnum.to_s.nil?
    else
      check_dn(dnum)
    end
    event.respond "#{@user} Roll: `#{@tally}` Wrath: `#{@wrath_value}` | #{@test_status} TOTAL - Icons: `#{@icons}` Exalted Icons: `#{@exalted_icons} (Value:#{@exalted_total})`"
    event.respond "Roll Reason: `#{@comment}`"
    if @wresult_convert.include? '6'
      event.respond 'Combat critical hit and one point of Glory!'
    elsif @wresult_convert.include? '1'
      event.respond 'Complication!'
    end
  end
end

def check_donate(event)
  if @roll.include? 'donate'
    event.respond "\n Care to support the bot? You can donate via Patreon https://www.patreon.com/dicemaiden \n You can also do a one time donation via donate bot located here https://donatebot.io/checkout/534632036569448458"
  end
end

def check_help(event)
  if @roll.include? 'help'
    event.respond "``` Synopsis:\n\t!roll xdx [OPTIONS]\n\n\tDescription:\n\n\t\txdx : Denotes how many dice to roll and how many sides the dice have.\n\n\tThe following options are available:\n\n\t\t+ - / * : Static modifier\n\n\t\te# : The explode value.\n\n\t\tk# : How many dice to keep out of the roll, keeping highest value.\n\n\t\tr# : Reroll value.\n\n\t\tt# : Target number for a success.\n\n\t\t! : Any text after ! will be a comment.\n\n !roll donate : Care to support the bot? Get donation information here. Thanks!\n ```"
  end
end

def check_purge(event)
  if @roll.include? 'purge'
    @roll.slice! 'purge'
    amount = @input.to_i
    if (amount < 2) || (amount > 100)
      event.respond 'Amount must be between 2-100'
      return false
    end
    if event.user.defined_permission?(:manage_messages) == true || event.user.defined_permission?(:administrator) == true
      event.channel.prune(amount)
    else
      event.respond "#{@user} does not have permissions for this command"
    end
  end
end

def check_latency(event)
  if @roll.include? 'ping'
    @icmp = Net::Ping::ICMP.new('www.discordapp.com')
    if @icmp.ping
      @duration = @icmp.duration * 1000.0
      @round_trip = @duration.round(2)
      event.respond "Discord API endpoint replied in #{@round_trip} ms"
    else
      event.respond 'Discord API endpoint timedout'
    end
  end
end

def check_bot_info(event)
  if @roll.include? 'bot-info'
    servers = $db.execute "select sum(server_count) from shard_stats;"
    event.respond "| Dice Maiden | - #{servers.join.to_i} active servers"
  end
end

Dotenv.load
# Add API token
@bot = Discordrb::Bot.new token: ENV['TOKEN'], num_shards: 30 , shard_id: ARGV[0].to_i, compress_mode: :large, ignore_bots: true, fancy_log: true
@bot.gateway.check_heartbeat_acks = false
@shard = ARGV[0].to_i
$db = SQLite3::Database.new "main.db"
# Check for command
@bot.message(start_with: '!roll') do |event|
  @input = event.content
  @event_server_check = event.server.name
  @simple_output = false

  if @input.match(/!roll\s(s)\s/)
    @simple_output = true
    @input.sub!("s","")
  end

  @roll_set = nil
  @roll_set = @input.scan(/!roll\s(\d+)\s/).first.join.to_i if @input.match(/!roll\s(\d+)\s(\d+)d/)

  unless @roll_set.nil?
    if (@roll_set <=1) || (@roll_set > 20)
      event.respond "Roll set must be between 2-20"
      break
    end
  end

  unless @roll_set.nil?
    @input.slice! "!roll"
    @input.slice!(0..@roll_set.to_s.size)
  else
    @input.slice! "!roll"
  end

  if @input =~ /^\s+d/
    roll_to_one = @input.lstrip
    roll_to_one.prepend("1")
    @input = roll_to_one
  end

  @roll = @input
  @comment = ''
  @test_status = ''
  # check user
  check_user_or_nick(event)
  # check for comment
  check_comment
  # Check for dn
  dnum = @input.scan(/dn\s?(\d+)/).first.join.to_i if @input.include?('dn')

  # Check for correct input
  if @roll =~ /^\s*\d*[d]\d/
    break if check_roll(event) == true

    # Check for wrath roll
    check_wrath
    # Grab dice roll, create roll, grab results
    unless @roll_set.nil?
      @roll_set_results = ''
      roll_count= 0
      while roll_count < @roll_set.to_i
        do_roll(event)
        break if do_roll(event) == true
        @roll_set_results << "`#{@tally}` #{@dice_result}\n"
        roll_count += 1
      end
      log_roll(event)
      if @comment.to_s.empty? || @comment.to_s.nil?
        event.respond "#{@user} Rolls:\n #{@roll_set_results}"
      else
        event.respond "#{@user} Rolls:\n #{@roll_set_results} Reason: `#{@comment}`"
      end
      break
    else
      do_roll(event)
      break if do_roll(event) == true
    end

    # Grab event user name, server name and timestamp for roll and log it
    log_roll(event)
    # Print dice result to Discord channel
    if @comment.to_s.empty? || @comment.to_s.nil?
      if check_wrath == true
        event_no_comment_wrath(event, dnum)
      else
	if @simple_output == true
	  event.respond "#{@user} Roll #{@dice_result}"
	  check_fury(event)
	else
          event.respond "#{@user} Roll: `#{@tally}` #{@dice_result}"
          check_fury(event)
	end
      end
    else
      if check_wrath == true
        event_comment_wrath(event, dnum)
      else
        if @simple_output == true
	  event.respond "#{@user} Roll #{@dice_result} Reason: `#{@comment}`"
	  check_fury(event)
	else
        event.respond "#{@user} Roll: `#{@tally}` #{@dice_result}  Reason: `#{@comment}`"
        check_fury(event)
	end
      end
    end
  end
  check_donate(event)
  check_help(event)
  check_latency(event)
  check_bot_info(event)
  break if check_purge(event) == false
end

@bot.run :async
# Check every 5 minutes and log server count

loop do
  sleep 300
  time = Time.now.getutc
  if @bot.connected? == true
    server_parse = @bot.servers.count
    $db.execute "update shard_stats set server_count = #{server_parse}, timestamp = CURRENT_TIMESTAMP where shard_id = #{@shard}"
    File.open('dice_rolls.log', 'a') { |f| f.puts "#{time} Shard: #{@shard} Server Count: #{server_parse}" }
  else
    File.open('dice_rolls.log', 'a') { |f| f.puts "#{time} Shard: #{@shard} bot not ready!" }
  end
    RestClient.post("https://discordbots.org/api/bots/377701707943116800/stats", {'shard_id': ARGV[0].to_i , "shard_count": 30, "server_count": server_parse}, :'Authorization' => ENV['API'], :'Content-Type' => :json);
end
