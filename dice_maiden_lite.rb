# Dice bot for Discord lite
# Author: Humblemonk
# Version: 6.0.0
# Copyright (c) 2017. All rights reserved.
# This version is designed to be run for a single instance
# !/usr/bin/ruby
require_relative 'dice_maiden_logic'

require 'discordrb'
require 'dicebag'
require 'dotenv'

Dotenv.load
# Add API token
@bot = Discordrb::Bot.new token: ENV['TOKEN'], ignore_bots: true, fancy_log: true

# Check for command
@bot.message(start_with: /^(!roll)/i) do |event|
  begin
    @prefix = "!roll"

    next if check_donate(event)
    next if check_help(event)
    next if check_purge(event)
    raw_input = event.content.delete_prefix(@prefix)
    # check user
    check_user_or_nick(event)

    @rolls = create_rolls(raw_input)
    @roll_set_results = ''
    for roll in @rolls do
      @test_status = ''
      @do_tally_shuffle = 0
      # check for modifiers that should apply to everything
      check_universal_modifiers(roll.roll_string)

      # Check for dn
      dnum = roll.roll_string.scan(/dn\s?(\d+)/).first.join.to_i if roll.roll_string.include?('dn')

      # Check for correct input
      next unless roll.roll_string.match?(/\dd\d/i)
      next if check_roll(event, roll.roll_string) == true

      if do_roll(event, roll.roll_string) == true
        error_encountered = true
        break
      end
      @tally = roll.hash_output(@tally)

      next if error_encountered

      if roll.wrath_roll
        @roll_set_results << build_wrath_response(roll)
      else
        @roll_set_results << build_response(roll)
      end
    end
    event.respond "#{@user} Rolls:\n#{@roll_set_results}"
  rescue ArgumentError => error ## Catch any errors that were thrown by bad argument and send back to user
    event.respond(error.message)
  rescue StandardError => error ## The worst that should happen is that we catch the error and return its message.
    if(error.message == nil )
      error.message = "NIL MESSAGE!"
    end
    event.respond("Unexpected exception thrown! (" + error.message + ")\n\nPlease drop us a message in the #support channel on the dice maiden server, or create an issue on Github.")
  end
end

@bot.run
