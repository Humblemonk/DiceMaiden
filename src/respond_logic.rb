# frozen_string_literal: true

def build_response
  response = "#{@user} Request: `[#{@roll_request.strip}]`"
  if @roll_set
    response += if @comment.to_s.empty? || @comment.to_s.nil?
                  " Rolls:\n#{@roll_set_results}Results Total: `#{@roll_set_total}`"
                else
                  " Rolls:\n#{@roll_set_results}Results Total: `#{@roll_set_total}`\nReason: `#{@comment}`"
                end
    return response
  end
  unless @simple_output
    response += " Roll: `#{@tally}`"
    response += " Rerolls: `#{@reroll_count}`" if @show_rerolls
  end
  response += botch_counter if @show_botch
  response += " #{@dice_result}" unless @no_result

  response += " Body: `#{@hsn_body}`, Stun: `#{@hsn_stun}`" if @hsn

  response += " Body: `#{@hsk_body}`, Stun Multiplier: `#{@hsk_multiplier}`, Stun: `#{@hsk_stun}`" if @hsk

  response += " Hits DCV `#{@dice_result.scan(/\d+/)}`" if @hsh

  response += " Reason: `#{@comment}`" if @has_comment
  response
end

def send_response(event)
  # Print dice results to Discord channel
  # reduce noisy errors by checking if response array is empty due to responding earlier
  if @response_array.empty?
    # do nothing
  elsif check_wrath == true
    respond_wrath(event, @dnum)
  elsif @private_roll
    event.respond(content: @response_array.join("\n").to_s, ephemeral: true)
  else
    event.respond(content: @response_array.join("\n").to_s)
    check_fury(event)
  end
end
