# All bot logic that is not handled by Dice-Bag lives here

# Returns an input string after it's been put through the aliases
def alias_input_pass(input)
  # Each entry is formatted [/Alias match regex/, "Alias Name", /gsub replacement regex/, "replace with string"]
  alias_input_map = [
    [/\b\d+dF\b/i, 'Fudge', /\b(\d+)dF\b/i, '\\1d3 f1 t3'], # Fate fudge dice
    [/\bSNM\d+\b/i, 'Sunsails', /\bSNM(\d+)\b/i, '\\1d6 ie6 t4'], # Sunsails: New Milennium; Fourth Edition
    [/\b\d+wh\d+\+/i, 'Warhammer', /\b(\d+)wh(\d+)\+/i, '\\1d6 t\\2'], # Warhammer (AoS/40k)
    [/\b\d+WoD\d+\b/i, 'WoD', /\b(\d+)WoD(\d+)\b/i, '\\1d10 f1 t\\2'], # World of Darkness 4th edition (note: explosions are left off for now)
    [/\bdd\d\d\b/i, 'Double Digit', /\bdd(\d)(\d)\b/i, '(1d\\1 * 10) + 1d\\2'], # Rolling one dice for each digit
    [/\bage\b/i, 'AGE System Test', /\b(age)\b/i, '2d6 + 1d6'], # 2d6 plus one drama/dragon/stunt die
    [/\B\+d\d+\b/i, 'Advantage', /\B\+d(\d+)\b/i, '2d\\1 d1'], # Roll two dice of the specified size and keep the highest
    [/\B-d\d+\b/i, 'Disadvantage', /\B-d(\d+)\b/i, '2d\\1 kl1'], # Roll two dice of the specified size and keep the lowest
    [/\B\+d%\B/i, 'Advantage on percentile', /\B\+d%\B/i, '((2d10kl1-1) *10) + 1d10'], # Roll two d10s for the tens column and keep the lowest (roll under system) then add a d10 for the ones
    [/\B-d%\B/i, 'Disadvantage on percentile', /\B-d%\B/i, '((2d10k1-1) *10) + 1d10'], # Roll two d10s for the tens column and keep the highest (roll under system) then add a d10 for the ones
    [/\b\d+CoD\b/i, 'CoD', /\b(\d+)CoD\b/i, '\\1d10 ie10 t8'], # Chronicles of Darkness
    [/\bd6s\d+\b/i, 'The D6 System', /\bd6s(\d+)\b/i, '\\1d6 + 1d6 ie'], # The D6 System
    [/\bsr\d+\b/i, 'Shadowrun', /\bsr(\d+)\b/i, '\\1d6 t5'], # Shadowrun system
    [/\b\d+d%\B/i, 'Percentile roll', /\b(\d+)d%\B/i, '\\1d100'], # Roll a d100
    [/\bsp\d+\b/i, 'Storypath', /\bsp(\d+)\b/i, 'ul \\1d10 ie10 t8'], # storypath system
    [/\b\d+yz\b/i, 'Year Zero', /\b(\d+)yz\b/i, '\\1d6 t6'] # year zero system
  ]

  @alias_types = []
  new_input = input

  # Run through all aliases and record which ones we use
  alias_input_map.each do |alias_entry|
    if input.match?(alias_entry[0])
      @alias_types.append(alias_entry[1])
      new_input.gsub!(alias_entry[2], alias_entry[3])
    end
  end

  new_input
end

# Returns dice string after it's been put through the aliases
def alias_output_pass(roll_tally)
  # Each entry is formatted "Alias Name":[[]/gsub replacement regex/, "replace with string", etc]
  # Not all aliases will have an output hash
  alias_output_hash = {
    'Fudge' => [[/\b1\b/, '-'], [/\b2\b/, ' '], [/\b3\b/, '+']]
  }

  new_tally = roll_tally

  @alias_types.each do |alias_type|
    next unless alias_output_hash.has_key?(alias_type)

    alias_output = alias_output_hash[alias_type]
    alias_output.each do |replacement|
      new_tally.gsub!(replacement[0], replacement[1])
    end
  end

  new_tally
end

def check_user_or_nick(event)
  @user = if !event.user.nick.nil?
            event.user.nick
          else
            event.user.name
          end
end

def check_comment
  if @input.include?('!')
    @comment = @input.partition('!').last.lstrip
    # remove @ user ids from comments to prevent abuse
    @comment.gsub!(/<@!\d+>/, '')
    @do_tally_shuffle = true if @comment.include? 'unsort'
    @roll = @input[/(^.*)!/]
    @roll.slice! @comment
    @roll.slice! '!'
  end
end

def check_roll(event)
  dice_requests = @roll.scan(/\d+d\d+/i)

  dice_requests.each do |dice_request|
    @special_check = dice_request.scan(/d(\d+)/i).first.join.to_i
    @dice_check = dice_request.scan(/d(\d+)/i).first.join.to_i

    if @dice_check < 2
      event.respond 'Please roll a dice value 2 or greater'
      return true
    end
    if @dice_check > 100
      event.respond 'Please roll dice up to d100'
      return true
    end
    # Check for too large of dice pools
    @dice_check = dice_request.scan(/(\d+)d/i).first.join.to_i
    if @dice_check > 500
      event.respond 'Please keep the dice pool below 500'
      return true
    end
  end
end

def check_wrath
  if (@special_check == 6) && (@wng == true) && ((@comment.include? 'soak') || (@comment.include? 'exempt') || (@comment.include? 'dmg'))
  elsif (@special_check == 6) && (@wng == true)
    @roll = "#{@dice_check - 1}d6"
    wstr = '(Wrath Dice) 1d6'
    wroll = DiceBag::Roll.new(wstr)
    @wresult = wroll.result
    @wresult_convert = @wresult.to_s
    @wrath_value = @wresult_convert.scan(/\d+/).first
    true
  end
end

# Takes raw input and returns a reverse polish notation queue of operators and Integers
def convert_input_to_rpn_queue(event, input)
  split_input = input.scan(%r{\b(?:\d+d\d+(?:\s?[a-z]+\d+|\s?e+\d*|\s?[ie]+\d*)*)|[+\-*/]|(?:\b\d+\b)|[()]}i) # This is the tokenization string for our input
  # change to read left to right order
  input_queue = []
  input_queue.push(split_input.pop) while split_input.length > 0

  operator_priority = {
    '+' => 1,
    '-' => 1,
    '*' => 2,
    '/' => 2
  }

  output_queue = []
  operator_stack = []

  # Use the shunting yard algorithm to get our order of operations right
  while input_queue.length > 0
    input_queue_peek = input_queue.last

    if input_queue_peek.match?(/\b\d+\b/) # If constant in string form
      output_queue.prepend(Integer(input_queue.pop))

    elsif input_queue_peek.match?(/\b\d+d\w+/i) # If dice roll
      output_queue.prepend(process_roll_token(event, input_queue.pop))

    elsif input_queue_peek.match?(%r{[+\-*/]})
      # If the peeked operator is not higher priority than the top of the stack, pop the stack operator down
      if operator_stack.length == 0 || operator_stack.last == '(' || operator_priority[input_queue_peek] > operator_priority[operator_stack.last]
        operator_stack.push(input_queue.pop)
      else
        output_queue.prepend(operator_stack.pop)
        operator_stack.push(input_queue.pop)
      end

    elsif input_queue_peek == '('
      operator_stack.push(input_queue.pop)

    elsif input_queue_peek == ')'
      while operator_stack.last != '('
        output_queue.prepend(operator_stack.pop)

        raise "Extra ')' found!" if operator_stack.length == 0
      end
      operator_stack.pop # Dispose of the closed "("
      input_queue.pop # Dispose of the closing ")"
    else
      raise "Invalid token! (#{input_queue_peek})"
    end
  end

  while operator_stack.length > 0
    raise "Extra '(' found!" if operator_stack.last == '('

    output_queue.prepend(operator_stack.pop)
  end

  output_queue
end

# Process a stack of tokens in reverse polish notation completely and return the result
def process_rpn_token_queue(input_queue)
  output_stack = []

  while input_queue.length > 0
    input_queue_peek = input_queue.last

    if input_queue_peek.is_a?(Integer)
      output_stack.push(input_queue.pop)

    else # Must be an operator
      raise input_queue.pop + ' is not between two numbers!' if output_stack.length < 2

      operator = input_queue.pop
      operand_b = output_stack.pop
      operand_a = output_stack.pop
      output_stack.push(process_operator_token(operator, operand_a, operand_b))
    end
  end

  raise 'Extra numbers detected!' if output_stack.length > 1

  output_stack[0] # There can be only one!
end

# Takes a operator token (e.g. '+') and return the result of the operation on the given operands
def process_operator_token(token, operand_a, operand_b)
  if token == '+'
    operand_a + operand_b
  elsif token == '-'
    operand_a - operand_b
  elsif token == '*'
    operand_a * operand_b
  elsif token == '/'
    raise 'Tried to divide by zero!' if operand_b == 0

    operand_a / operand_b
  else
    raise "Invalid Operator: #{token}"
  end
end

# Takes a roll token, appends the roll results, and returns the total
def process_roll_token(_event, token)
  begin
    dice_roll = DiceBag::Roll.new(token + @dice_modifiers)
  # Rescue on bad dice roll syntax
  rescue Exception => e
    raise 'Roller encountered error with "' + token + @dice_modifiers + '": ' + e.message
  end
  token_total = dice_roll.result.total
  # Check for reroll or indefinite reroll
  reroll_check = dice_roll.result.sections[0].options[:reroll]
  reroll_indefinite_check = dice_roll.result.sections[0].options[:reroll_indefinite]
  if reroll_check > 0 || reroll_indefinite_check > 0
    @reroll_count = dice_roll.result.sections[0].reroll_count
    @show_rerolls = true
  else
    @show_rerolls = false
  end
  # Parse the roll and grab the total tally
  parse_roll = dice_roll.tree
  parsed = parse_roll.inspect
  roll_tally = parsed.scan(/tally=\[.*?, @/)
  roll_tally = String(roll_tally)
  roll_tally.gsub!(/\[*("tally=)|"\]|"|, @/, '')
  roll_tally.gsub!(/\[\[/, '[')
  roll_tally.gsub!(/\]\]/, ']')
  if @do_tally_shuffle == true
    roll_tally.gsub!('[', '')
    roll_tally_array = roll_tally.split(', ').map(&:to_i)
    roll_tally = roll_tally_array.shuffle!
    roll_tally = String(roll_tally)
  end
  @tally += roll_tally

  token_total
end

def do_roll(event)
  roll_result = nil
  @tally = ''
  begin
    roll_result = process_RPN_token_queue(convert_input_to_RPN_queue(event, @roll))
  rescue RuntimeError => e
    event.respond 'Error: ' + e.message
    return true
  end

  @dice_result = "Result: #{roll_result}"
end

def log_roll(event)
  @server = event.server.name
  @time = Time.now.getutc
  if @roll_set.nil?
    File.open('dice_rolls.log', 'a') do |f|
      f.puts "#{@time} Shard: #{@shard} |#{@server}| #{@user} Roll: #{@tally} #{@dice_result}"
    end
  else
    File.open('dice_rolls.log', 'a') do |f|
      f.puts "#{@time} Shard: #{@shard} | #{@server}| #{@user} Rolls:\n #{@roll_set_results}"
    end
  end
end

def check_fury(event)
  if (@special_check == 10) && (@tally.include? '10') && (@dh == true)
    event.respond '`Righteous Fury Activated!` Purge the Heretic!'
  end
end

def check_icons
  @fours = @tally.scan(/4/).count
  @fives = @tally.scan(/5/).count
  @exalted_icons = @tally.scan(/6/).count
  @exalted_icons += 1 if @wresult_convert.include? '6'
  @wrath_icon = if (@wresult_convert.include? '4') || (@wresult_convert.include? '5')
                  1
                else
                  0
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

def check_universal_modifiers
  # Read universal dice modifiers
  @dice_modifiers = @roll.scan(/(?:\s(?:\b[a-z]+\d+\s*))+$/i).first # Grab all options and whitespace at end of input and separated
  if @dice_modifiers.nil?
    @dice_modifiers = ''
  else
    @roll = @roll[0..-@dice_modifiers.length]
  end
end

def respond_wrath(event, dnum)
  if @roll == '0d6'
    event.respond "#{@user} Roll Wrath: `#{@wrath_value}`"
    event.respond "Roll Reason: `#{@comment}`" if @has_comment
  else
    check_icons
    if dnum.to_s.empty? || dnum.to_s.nil?
    else
      check_dn(dnum)
    end
    event.respond "#{@user} Roll: `#{@tally}` Wrath: `#{@wrath_value}` | #{@test_status} TOTAL - Icons: `#{@icons}` Exalted Icons: `#{@exalted_icons} (Value:#{@exalted_total})`"
    event.respond "Roll Reason: `#{@comment}`" if @has_comment
    if @wresult_convert.include? '6'
      event.respond 'Combat critical hit and one point of Glory!'
    elsif @wresult_convert.include? '1'
      event.respond 'Complication!'
    end
  end
end

def check_donate(event)
  # this is jank right now due to a bug I need to fix
  if @check =~ /^\s*(#{@prefix}1donate)\s*$/i
    event.respond "\n Care to support the bot? You can donate via Patreon https://www.patreon.com/dicemaiden \n You can also do a one time donation via donate bot located here https://donatebot.io/checkout/534632036569448458"
    true
  end
end

def check_help(event)
  if @check =~ /^\s*(#{@prefix} help)\s*$/i
    event.respond "``` Synopsis:\n\t!roll xdx [OPTIONS]\n\n\tDescription:\n\n\t\txdx : Denotes how many dice to roll and how many sides the dice have.\n\n\tThe following options are available:\n\n\t\t+ - / * : Static modifier\n\n\t\te# : The explode value.\n\n\t\tie# : The indefinite explode value.\n\n\t\tk# : How many dice to keep out of the roll, keeping highest value.\n\n\t\tr# : Reroll value.\n\n\t\tir# : Indefinite reroll value.\n\n\t\tt# : Target number for a success.\n\n\t\tf# : Target number for a failure.\n\n\t\t! : Any text after ! will be a comment.\n\n !roll donate : Care to support the bot? Get donation information here. Thanks!\n\n Find more commands at https://github.com/Humblemonk/DiceMaiden\n```"
    true
  end
end

def check_purge(event)
  if @check =~ /^\s*(#{@prefix} purge)\s*\d*$/i
    @roll.slice! 'purge'
    amount = @input.to_i
    if (amount < 2) || (amount > 100)
      event.respond 'Amount must be between 2-100'
      return false
    end
    if event.user.defined_permission?(:manage_messages) == true ||
       event.user.defined_permission?(:administrator) == true ||
       event.user.permission?(:manage_messages, event.channel) == true
      event.channel.prune(amount)
    else
      event.respond "#{@user} does not have permissions for this command"
    end
  end
end

def check_bot_info(event)
  if @check =~ /^\s*(#{@prefix} bot-info)\s*$/i
    if @launch_option == 'lite'
      event.respond 'This option is not supported with Dice Maiden Lite.'
      return true
    end
    servers = $db.execute 'select sum(server_count) from shard_stats;'
    event.respond "| Dice Maiden | - #{servers.join.to_i} active servers"
    true
  end
end

def check_prefix(event)
  if event.channel.pm? || @launch_option == 'lite'
    @prefix = '!roll'
    return
  end

  begin
    @server = event.server.id
    @row = $db.execute "select prefix from prefixes where server = #{@server}"
    @prefix = @row[0].join(', ')
    @prefix = '!roll' if @row.empty? == true
  rescue StandardError
    @prefix = '!roll'
  end
end

def handle_prefix(event)
  return false if event.channel.pm?

  @prefix_setcmd = event.content.strip.to_s
  @server = event.server.id
  check_user_or_nick(event)

  if @prefix_setcmd =~ /^(!dm prefix check)\s*$/i
    @prefix_check = $db.execute "select prefix from prefixes where server = #{@server}"
    if @prefix_check.empty?
      event.respond 'This servers prefix is set to:  !roll'
      return true
    else
      event.respond "This servers prefix is set to:  #{@prefix_check[0].join(', ')}"
      return true
    end
  end

  if @prefix_setcmd =~ /^(!dm prefix reset)\s*$/i
    if event.user.defined_permission?(:manage_messages) == true ||
       event.user.defined_permission?(:administrator) == true ||
       event.user.permission?(:manage_messages, event.channel) == true
      $db.execute "delete from prefixes where server = #{@server}"
      event.respond 'Prefix has been reset to !roll'
      return true
    else
      event.respond "#{@user} does not have permissions for this command"
      return true
    end
  end

  if @prefix_setcmd =~ /^(!dm prefix)/i
    if event.user.defined_permission?(:manage_messages) == true ||
       event.user.defined_permission?(:administrator) == true ||
       event.user.permission?(:manage_messages, event.channel) == true
      # remove command syntax and trailing which will be added later
      @prefix_setcmd.slice!(/!dm prefix\s*/i)

      if @prefix_setcmd.empty?
        # do nothing if the set command is empty
        return true
      end

      if @prefix_setcmd.size > 10
        event.respond 'Prefix too large. Keep it under 10 characters'
        return true
      end
      @prefix_prune = @prefix_setcmd.delete(' ')
      $db.execute "insert or replace into prefixes(server,prefix,timestamp) VALUES (#{@server},\"!#{@prefix_prune}\",CURRENT_TIMESTAMP)"
      event.respond "Prefix is now set to:  !#{@prefix_prune}"
      true
    else
      event.respond "#{@user} does not have permissions for this command"
      true
    end
  end
end

def check_server_options(event)
  if event.content =~ /(^!dm prefix)/i
    if @launch_option == 'lite'
      event.respond 'This option is not supported with Dice Maiden Lite.'
      return true
    end
    handle_prefix(event)
  elsif event.content =~ /(^!dm request)/i
    if @launch_option == 'lite'
      event.respond 'This option is not supported with Dice Maiden Lite.'
      return true
    end
    set_show_request(event)
  end
end

def set_show_request(event)
  return false if event.channel.pm?

  request_setcmd = event.content.delete_prefix('!dm request').strip
  server = event.server.id
  check_user_or_nick(event)

  if event.user.defined_permission?(:manage_messages) == true ||
     event.user.defined_permission?(:administrator) == true ||
     event.user.permission?(:manage_messages, event.channel) == true
    if request_setcmd == 'show'
      @request_option = true
      $db.execute "insert or replace into server_options(server,show_requests,timestamp) VALUES (#{server},\"#{@request_option}\",CURRENT_TIMESTAMP)"
    elsif request_setcmd == 'hide'
      $db.execute "delete from server_options where server = #{server}"
    else
      event.respond "'" + request_setcmd + "' is not a valid option. Please use 'show' or 'hide'."
      return true
    end
    event.respond 'Requests will now be ' + (@request_option ? 'shown' : 'hidden') + ' in responses.'
    true
  else
    event.respond "#{@user} does not have permissions for this command"
    true
  end
end

def check_request_option(event)
  if event.channel.pm? || @launch_option == 'lite'
    @request_option = false
    return
  end

  server = event.server.id
  @request_option = $db.execute "select show_requests from server_options where server = #{server}"
  @request_option = false if @request_option.empty?
end

def input_valid(event)
  event_input = event.content
  if event_input =~ /^(#{@prefix}\s)/i
    true
  else
    false
  end
end

def check_roll_modes
  # check for wrath and glory game mode for roll
  if @input.match(/#{@prefix}\s(wng)\s/i)
    @wng = true
    @input.sub!('wng', '')
  end

  # check for Dark heresy game mode for roll
  if @input.match(/#{@prefix}\s(dh)\s/i)
    @dh = true
    @input.sub!('dh', '')
  end

  # check for simple mode for roll
  if @input.match(/#{@prefix}\s(s)\s/i)
    @simple_output = true
    @input.sub!('s', '')
  end

  # check for roll having an unsorted tally list
  if @input.match(/#{@prefix}\s(ul)\s/i)
    @do_tally_shuffle = true
    @input.sub!('ul', '')
  end

  @ed = true if @input.match(/#{@prefix}\s(ed\d+)/i)
end

def roll_sets_valid(event)
  @roll_set = @input.scan(/#{@prefix}\s+(\d+)\s/i).first.join.to_i if @input.match(/#{@prefix}\s+(\d+)\s/i)

  if !@roll_set.nil? && ((@roll_set <= 1) || (@roll_set > 20))
    event.respond 'Roll set must be between 2-20'
    return false
  end

  if @roll_set.nil?
    @input.slice!(/^#{@prefix}/i)
  else
    @input.slice!(/^#{@prefix}\s*/i)
    @input.slice!(0..@roll_set.to_s.size)
  end
end

def build_response
  response = "#{@user} Roll"
  unless @simple_output
    response += ": `#{@tally}`"
    response += " Rerolls: `#{@reroll_count}`" if @show_rerolls
  end
  response += " #{@dice_result}"
  response += " Reason: `#{@comment}`" if @has_comment
  if @request_option
    # Alias parsed initial request
    request = @input.split('!')[0]
    response += " Request: `[#{request.strip}]`"
  end
  response
end
