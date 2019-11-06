# Dice bot for Discord lite
# Author: Humblemonk
# Version: 2.7.1 
# Copyright (c) 2018. All rights reserved.
# This version is designed to be run for a single instance
# !/usr/bin/ruby

require 'discordrb'
require 'dicebag'
require 'dotenv'
require 'net/ping'

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
    File.open('dice_maiden.log','a') { |f| f.puts "#{@time} | #{@server}| #{@user} Rolls:\n #{@roll_set_results}" }
  else
    File.open('dice_maiden.log', 'a') { |f| f.puts "#{@time} |#{@server}| #{@user} Roll: #{@tally} #{@dice_result}" }
  end
end

def check_help(event)
  if @roll.include? 'help'
    event.respond "``` Synopsis:\n\t!roll xdx [OPTIONS]\n\n\tDescription:\n\n\t\txdx : Denotes how many dice to roll and how many sides the dice have.\n\n\tThe following options are available:\n\n\t\t+ - / * : Static modifier\n\n\t\te# : The explode value.\n\n\t\tk# : How many dice to keep out of the roll, keeping highest value.\n\n\t\tr# : Reroll value.\n\n\t\tt# : Target number for a success.\n\n\t\t! : Any text after ! will be a comment.\n ```"
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


Dotenv.load
# Add API token
@bot = Discordrb::Bot.new token: ENV['TOKEN']

# Check for command
@bot.message(start_with: '!roll') do |event|
  @input = event.content
  @event_server_check = event.server.name
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
        event.respond "#{@user} Roll: `#{@tally}` #{@dice_result}"
    else
        event.respond "#{@user} Roll: `#{@tally}` #{@dice_result}  Reason: `#{@comment}`"
    end
  end
  check_help(event)
  check_latency(event)
  break if check_purge(event) == false
end

@bot.run
