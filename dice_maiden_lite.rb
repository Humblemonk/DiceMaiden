# Dice bot for Discord lite
# Author: Humblemonk
# Version: 4.0.6
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
    @input = alias_input_pass(event.content) # Do alias pass as soon as we get the message
    @simple_output = false
    @wng = false
    @dh = false
    @prefix = "!roll"

    check_roll_modes()

    @roll_set = nil
    next unless roll_sets_valid(event)

    if @input =~ /^\s+d/
      roll_to_one = @input.lstrip
      roll_to_one.prepend("1")
      @input = roll_to_one
    end

    @roll = @input
    @comment = ''
    @test_status = ''
    @do_tally_shuffle = 0
    # check user
    check_user_or_nick(event)
    # check for comment
    check_comment
    # check for modifiers that should apply to everything
    check_universal_modifiers

    # Check for dn
    dnum = @input.scan(/dn\s?(\d+)/).first.join.to_i if @input.include?('dn')

    # Check for correct input
    if @roll.match?(/\dd\d/i)
      next if check_roll(event) == true

      # Check for wrath roll
      check_wrath
      # Grab dice roll, create roll, grab results
      unless @roll_set.nil?
        @roll_set_results = ''
        roll_count= 0
        error_encountered = false
        while roll_count < @roll_set.to_i
          if do_roll(event) == true
            error_encountered = true
            break
          end
          @tally = alias_output_pass(@tally)
          @roll_set_results << "`#{@tally}` #{@dice_result}\n"
          roll_count += 1
        end
        next if error_encountered

        if @comment.to_s.empty? || @comment.to_s.nil?
          event.respond "#{@user} Rolls:\n#{@roll_set_results}"
        else
          event.respond "#{@user} Rolls:\n#{@roll_set_results} Reason: `#{@comment}`"
        end
        next
      else
        next if do_roll(event) == true
      end

      # Output aliasing
      @tally = alias_output_pass(@tally)

      # Print dice result to Discord channel
      @has_comment = !@comment.to_s.empty? && !@comment.to_s.nil?
      if check_wrath == true
        respond_wrath(event, dnum)
      else
        event.respond build_response
        check_fury(event)
      end
    end
    check_donate(event)
    check_help(event)
    next if check_purge(event) == false
  rescue StandardError => error ## The worst that should happen is that we catch the error and return its message.
    if(error.message == nil )
      error.message = "NIL MESSAGE!"
    end
    event.respond("Unexpected exception thrown! (" + error.message + ")\n\nPlease drop us a message in the #support channel on the dice maiden server, or create an issue on Github.")
  end
end

@bot.run
