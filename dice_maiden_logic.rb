# All bot logic that is not handled by Dice-Bag lives here

# A Roll contains all the settings for that dice roll
class Roll
  def initialize(r_string)
    @roll_string = r_string

    parse_aliases

    @special_check = @roll_string.scan(/d(\d+)/i).first.join.to_i
    @dice_check = @roll_string.scan(/(\d+)d/i).first.join.to_i

    set_game_modes

    if @roll_string =~ /^\s*d\d+/
      @roll_string = preppend_one(@roll_string)
    end

    generate_comment

    @dnum = @roll_string.scan(/dn\s?(\d+)/).first.join.to_i if @roll_string.include?('dn')

    check_wrath
  end

  def set_game_modes
    @roll_string.strip!
    # check for wrath and glory game mode for roll
    if @roll_string.match(/^(wng)\s/i)
      @wng = true
      @roll_string.sub!("wng","")
    else
      @wng = false
    end

    # check for Dark heresy game mode for roll
    if @roll_string.match(/^(dh)\s/i)
      @dh = @special_check == 10
      @roll_string.sub!("dh","")
    else
      @dh = false
    end

    # check for simple mode for roll
    if @roll_string.match(/^(s)\s/i)
      @simple_output = true
      @roll_string.sub!("s","")
    else
      @simple_output = false
    end

    # check for roll having an unsorted tally list
    if @roll_string.match(/^(ul)\s/i)
      @do_tally_shuffle = true
      @roll_string.sub!("ul","")
    else
      @do_tally_shuffle = false
    end
  end

  def parse_aliases
      @output_hashes = []
      new_input = @roll_string

      # Run through all aliases and record which ones we use
      for alias_entry in $alias_input_map do
        if @roll_string.match?(alias_entry[0])
          # If a hash exists for the alias add it to our list of hashes to run
          if $alias_output_hash.has_key?(alias_entry[1])
            @output_hashes.append($alias_output_hash[alias_entry[1]])
          end
          new_input.gsub!(alias_entry[2], alias_entry[3])
        end
      end

      @roll_string = new_input
  end

  def hash_output(tally)
    new_tally = tally
    # Iterate over any output hashes and return tally
        for replacement in @output_hashes do
          new_tally.gsub!(replacement[0], replacement[1])
        end

    return new_tally
  end

  def generate_comment
    if @roll_string.include?('!')
      @comment = @roll_string.partition('!').last.lstrip
      if @comment.include? 'unsort'
        @do_tally_shuffle = true
      end
      @roll_string = @roll_string[/(^.*)!/]
      @roll_string.slice! @comment
      @roll_string.slice! '!'
    else
      @comment = ""
    end
  end

  def check_wrath
    if wrath_roll
      @roll_string = "#{@dice_check - 1}d6"
      wstr = '(Wrath Dice) 1d6'
      wroll = DiceBag::Roll.new(wstr)
      @wresult = wroll.result
      @wresult_convert = @wresult.to_s
      @wrath_value = @wresult_convert.scan(/\d+/).first
      return true
    end
    return false
  end

  def roll_string
    @roll_string
  end

  def wrath_roll
    (@special_check == 6) && (@wng == true) && !((@comment.include? 'soak') || (@comment.include? 'exempt') || (@comment.include? 'dmg'))
  end

  def wrath_value
    @wrath_value
  end

  def wrath_result
    @wresult_convert
  end

  def comment
    @comment
  end

  def has_comment
    !@comment.to_s.empty? && !@comment.to_s.nil?
  end

  def simple_output
    @simple_output
  end

  def wng
    @wng
  end

  def dh
    @dh
  end

  def do_tally_shuffle
    @do_tally_shuffle
  end

  def dnum
    @dnum
  end
end


  # Each entry is formatted [/Alias match regex/, "Alias Name", /gsub replacement regex/, "replace with string"]
$alias_input_map = [
      [/\b\d+WoD\d+\b/i, "WoD", /\b(\d+)WoD(\d+)\b/i, "\\1d10 f1 t\\2"], # World of Darkness 4th edition (note: explosions are left off for now)
      [/\b\d+dF\b/i, "Fudge", /\b(\d+)dF\b/i, "\\1d3 f1 t3"], # Fate fudge dice
      [/\b\d+wh\d+\+/i, "Warhammer", /\b(\d+)wh(\d+)\+/i, "\\1d6 t\\2"], # Warhammer (AoS/40k)
      [/\bdd\d\d\b/i, "Double Digit", /\bdd(\d)(\d)\b/i, "(1d\\1 * 10) + 1d\\2"], # Rolling one dice for each digit
      [/\bage\b/i, "AGE System Test", /\b(age)\b/i, "2d6 + 1d6"], # 2d6 plus one drama/dragon/stunt die
      [/\B\+d\d+\b/i, "Advantage", /\B\+d(\d+)\b/i, "2d\\1 d1"], # Roll two dice of the specified size and keep the highest
      [/\B\-d\d+\b/i, "Disadvantage", /\B\-d(\d+)\b/i, "2d\\1 kl1"], # Roll two dice of the specified size and keep the lowest
      [/\B\+d%\B/i, "Advantage on percentile", /\B\+d%\B/i, "((2d10kl1-1) *10) + 1d10"], # Roll two d10s for the tens column and keep the lowest (roll under system) then add a d10 for the ones
      [/\B\-d%\B/i, "Disadvantage on percentile", /\B\-d%\B/i, "((2d10k1-1) *10) + 1d10"], # Roll two d10s for the tens column and keep the highest (roll under system) then add a d10 for the ones
  ]

# Each entry is formatted "Alias Name":[[]/gsub replacement regex/, "replace with string", etc]
# Not all aliases will have an output hash
$alias_output_hash = {
    "Fudge" => [[/\b1\b/, "-"], [/\b2\b/, " "], [/\b3\b/, "+"]]
}

def check_user_or_nick(event)
  if event.user.nick != nil
    @user = event.user.nick
  else
    @user = event.user.name
  end
end

def check_roll(event, roll)
  dice_requests = roll.scan(/\d+d\d+/i)

  for dice_request in dice_requests
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

# Takes raw input and returns a reverse polish notation queue of operators and Integers
def convert_input_to_RPN_queue(event, input)
  split_input = input.scan(/\b(?:\d+[d]\d+(?:\s?[a-z]+\d+)*)|[\+\-\*\/]|(?:\b\d+\b)|[\(\)]/i)# This is the tokenization string for our input

  # change to read left to right order
  input_queue = []
  while split_input.length > 0
    input_queue.push(split_input.pop)
  end

  operator_priority = {
      "+" => 1,
      "-" => 1,
      "*" => 2,
      "/" => 2
  }

  output_queue = []
  operator_stack = []

  # Use the shunting yard algorithm to get our order of operations right
  while input_queue.length > 0
    input_queue_peek = input_queue.last

    if input_queue_peek.match?(/\b\d+\b/)# If constant in string form
      output_queue.prepend(Integer(input_queue.pop))

    elsif input_queue_peek.match?(/\b\d+[d]\w+/i)# If dice roll
      output_queue.prepend(process_roll_token(event, input_queue.pop))

    elsif input_queue_peek.match?(/[\+\-\*\/]/)
      # If the peeked operator is not higher priority than the top of the stack, pop the stack operator down
      if operator_stack.length == 0 || operator_stack.last == "(" || operator_priority[input_queue_peek] > operator_priority[operator_stack.last]
        operator_stack.push(input_queue.pop)
      else
        output_queue.prepend(operator_stack.pop)
        operator_stack.push(input_queue.pop)
      end

    elsif input_queue_peek == "("
      operator_stack.push( input_queue.pop )

    elsif input_queue_peek == ")"
      while operator_stack.last != '('
        output_queue.prepend(operator_stack.pop)

        if operator_stack.length == 0
          raise "Extra ')' found!"
        end
      end
      operator_stack.pop # Dispose of the closed "("
      input_queue.pop # Dispose of the closing ")"
    else
      raise "Invalid token! (#{input_queue_peek})"
    end
  end

  while operator_stack.length > 0
    if operator_stack.last == '('
      raise "Extra '(' found!"
    end
    output_queue.prepend(operator_stack.pop)
  end

  return output_queue
end

# Process a stack of tokens in reverse polish notation completely and return the result
def process_RPN_token_queue(input_queue)
  output_stack = []

  while input_queue.length > 0
    input_queue_peek = input_queue.last

    if input_queue_peek.is_a?(Integer)
      output_stack.push(input_queue.pop)

    else # Must be an operator
      if output_stack.length < 2
        raise input_queue.pop + " is not between two numbers!"
      end

      operator = input_queue.pop
      operand_B = output_stack.pop
      operand_A = output_stack.pop
      output_stack.push(process_operator_token(operator, operand_A, operand_B))
    end
  end

  if output_stack.length > 1
    raise "Extra numbers detected!"
  end

  return output_stack[0]# There can be only one!
end

# Takes a operator token (e.g. '+') and return the result of the operation on the given operands
def process_operator_token(token, operand_A, operand_B)
  if token == '+'
    return operand_A + operand_B
  elsif token == '-'
    return operand_A - operand_B
  elsif token == '*'
    return operand_A * operand_B
  elsif token == '/'
    if operand_B == 0
      raise 'Tried to divide by zero!'
    end
    return operand_A / operand_B
  else
    raise "Invalid Operator: #{token}"
  end
end

# Takes a roll token, appends the roll results, and returns the total
def process_roll_token(event, token)
  begin
    dice_roll = DiceBag::Roll.new(token + @dice_modifiers)
      # Rescue on bad dice roll syntax
  rescue Exception => error
    raise 'Roller encountered error with "' + token + @dice_modifiers + '": ' + error.message
  end
  token_total = dice_roll.result.total
  # Parse the roll and grab the total tally
  parse_roll = dice_roll.tree
  parsed = parse_roll.inspect
  roll_tally = parsed.scan(/tally=\[.*?\]/)
  roll_tally = String(roll_tally)
  roll_tally.gsub!(/\[*("tally=)|\"\]|\"/, '')
  if @do_tally_shuffle == true
    roll_tally.gsub!("[",'')
    roll_tally_array = roll_tally.split(', ').map(&:to_i)
    roll_tally = roll_tally_array.shuffle!
    roll_tally = String(roll_tally)
  end
  @tally += roll_tally

  return token_total
end

def do_roll(event, roll)
  roll_result = nil
  @tally = ""
  begin
    roll_result = process_RPN_token_queue(convert_input_to_RPN_queue(event, roll))
  rescue RuntimeError => error
    event.respond 'Error: ' + error.message
    return true
  end

  @dice_result = "Result: #{roll_result}"
end

def log_roll(event)
  @server = event.server.name
  @time = Time.now.getutc
  File.open('dice_rolls.log','a') { |f| f.puts "#{@time} Shard: #{@shard} | #{@server}| #{@user} Rolls:\n #{@roll_set_results}" }
end

def check_icons(wresult_convert)
  @fours = @tally.scan(/4/).count
  @fives = @tally.scan(/5/).count
  @exalted_icons = @tally.scan(/6/).count
  @exalted_icons += 1 if wresult_convert.include? '6'
  if (wresult_convert.include? '4') || (wresult_convert.include? '5')
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

def check_universal_modifiers(roll)
  # Read universal dice modifiers
  @dice_modifiers = roll.scan(/(?:\s(?:\b[a-z]+\d+\b))+$/i).first # Grab all options and whitespace at end of input and separated
  if @dice_modifiers == nil
    @dice_modifiers = ""
  else
    roll = roll.delete_suffix!(@dice_modifiers)
  end
end

def check_donate(event)
  # this is jank right now due to a bug I need to fix
  input = event.content
  if input =~ /^\s*(#{@prefix}1donate)\s*$/i
    event.respond "\n Care to support the bot? You can donate via Patreon https://www.patreon.com/dicemaiden \n You can also do a one time donation via donate bot located here https://donatebot.io/checkout/534632036569448458"
    return true
  end
  return false
end

def check_help(event)
  input = event.content
  if input =~ /^\s*(#{@prefix} help)\s*$/i
    event.respond """
```
Synopsis:
    !roll xdx [OPTIONS]

    Description:

        xdx : Denotes how many dice to roll and how many sides the dice have.

    The following options are available:

        + - / * : Static modifier

        e# : The explode value.

        k# : How many dice to keep out of the roll, keeping highest value.

        r# : Reroll value.

        t# : Target number for a success.

        f# : Target number for a failure.

        ! : Any text after ! will be a comment.

        & : Split multiple roll commands with &.

!roll donate : Care to support the bot? Get donation information here. Thanks!

Find more commands at https://github.com/Humblemonk/DiceMaiden
```
    """
    return true
  end
  return false
end

def check_purge(event)
  input = event.content
  if input =~ /^\s*(#{@prefix} purge)\s*\d*$/i
    input.slice! "#{@prefix} purge"
    event.respond input
    amount = input.to_i
    if (amount < 2) || (amount > 100)
      event.respond 'Amount must be between 2-100'
      return true
    end
    if event.user.defined_permission?(:manage_messages) == true || event.user.defined_permission?(:administrator) == true || event.user.permission?(:manage_messages, event.channel) == true
      event.channel.prune(amount)
    else
      event.respond "#{@user} does not have permissions for this command"
    end
    return true
  end
  return false
end

def check_bot_info(event)
  input = event.content
  if input =~ /^\s*(#{@prefix} bot-info)\s*$/i
    servers = $db.execute "select sum(server_count) from shard_stats;"
    event.respond "| Dice Maiden | - #{servers.join.to_i} active servers"
    return true
  end
  return false
end

def check_prefix(event)
  if event.channel.pm?
    @prefix = "!roll"
    return
  end

  begin
    @server = event.server.id
    @row = $db.execute"select prefix from prefixes where server = #{@server}"
    @prefix = @row[0].join(", ")
    if @row.empty? == true
      @prefix = "!roll"
    end
  rescue
    @prefix = "!roll"
  end
end

def handle_prefix(event)
  if event.channel.pm?
       return false
  end

  @prefix_setcmd = event.content.strip.to_s
  @server = event.server.id
  check_user_or_nick(event)

  if @prefix_setcmd =~ /^(!dm prefix check)\s*$/i
    @prefix_check = $db.execute "select prefix from prefixes where server = #{@server}"
    if @prefix_check.empty?
      event.respond "This servers prefix is set to:  !roll"
      return true
    else
      event.respond "This servers prefix is set to:  #{@prefix_check[0].join(", ")}"
      return true
    end
  end

  if @prefix_setcmd =~ /^(!dm prefix reset)\s*$/i
    if event.user.defined_permission?(:manage_messages) == true || event.user.defined_permission?(:administrator) == true || event.user.permission?(:manage_messages, event.channel) == true
      $db.execute "delete from prefixes where server = #{@server}"
      event.respond "Prefix has been reset to !roll"
      return true
    else
      event.respond "#{@user} does not have permissions for this command"
      return true
    end
  end

  if @prefix_setcmd =~ /^(!dm prefix)/i
    if event.user.defined_permission?(:manage_messages) == true || event.user.defined_permission?(:administrator) == true || event.user.permission?(:manage_messages, event.channel) == true
      #remove command syntax and trailing which will be added later
      @prefix_setcmd.slice! /!dm prefix\s*/i

      if @prefix_setcmd.empty?
        # do nothing if the set command is empty
        return true
      end

      if @prefix_setcmd.size > 10
        event.respond "Prefix too large. Keep it under 10 characters"
        return true
      end
      @prefix_prune = @prefix_setcmd.delete(' ')
      $db.execute "insert or replace into prefixes(server,prefix,timestamp) VALUES (#{@server},\"!#{@prefix_prune}\",CURRENT_TIMESTAMP)"
      event.respond "Prefix is now set to:  !#{@prefix_prune}"
      return true
    else
      event.respond "#{@user} does not have permissions for this command"
      return true
    end
  end
end

def input_valid(event)
  event_input = event.content
  if event_input =~ /^(#{@prefix})/i
    return true
  else
    return false
  end
end

def roll_sets_valid(event)
  @roll_set = @input.scan(/^(\d+)\s/i).first.join.to_i if @input.match(/^(\d+)\s/i)

  unless @roll_set.nil?
    if (@roll_set <=1) || (@roll_set > 20)
      event.respond "Roll set must be between 2-20"
      return false
    end
  end

  unless @roll_set.nil?
    @input.slice!(0..@roll_set.to_s.size)
  end

  return true
end

def build_response(roll)
   response = ""
  if !roll.simple_output
    response << "`#{@tally}` "
  end
  response << "#{@dice_result}"
  if roll.has_comment
    response << " Reason: `#{roll.comment}`"
  end
  response << "\n"
  if (@tally.include? '10') && (roll.dh == true)
    response << "`Righteous Fury Activated!` Purge the Heretic!\n"
  end
  return response
end

def build_wrath_response(roll)
  response = ''
  if roll.roll_string == '0d6'
    response << "#{@user} Roll Wrath: `#{roll.wrath_value}`"
    if roll.has_comment
      response << " Roll Reason: `#{roll.comment}`"
    end
    response << "\n"
  else
    check_icons(roll.wrath_result)
    unless roll.dnum.to_s.empty? || roll.dnum.to_s.nil?
      check_dn(roll.dnum)
    end
    response << "#{@user} Roll: `#{@tally}` Wrath: `#{roll.wrath_value}` | #{@test_status} TOTAL - Icons: `#{@icons}` Exalted Icons: `#{@exalted_icons} (Value:#{@exalted_total})`"
    if roll.has_comment
      response << " Roll Reason: `#{roll.comment}`\n"
    end
    if roll.wrath_result.include? '6'
      response << "Combat critical hit and one point of Glory!\n"
    elsif roll.wrath_result.include? '1'
      response << "Complication!\n"
    end
  end
  return response
end

def preppend_one(roll)
    roll_to_one = roll.lstrip
    roll_to_one.prepend("1")
    return roll_to_one
end

def number_of_rolls_in_set(roll)
  roll_num = roll.scan(/^(\d+)\s/i).first.join.to_i if roll.match(/^(\d+)\s/i)

  unless roll_num.nil?
    if (roll_num <=1) || (roll_num > 20)
      raise ArgumentError.new("Roll set must be between 2-20")
      return -1
    end
      roll.slice!(0..@roll_set.to_s.size)
      roll.strip!
    return roll_num
  end
  return 1
end

def create_rolls(input)
  raw_rolls = input.split("&")
  parsed_rolls = []
  for roll in raw_rolls do
    roll.strip!
    # Get number of rolls to create
      num_rolls = number_of_rolls_in_set(roll)
      curr_roll = 0
      while curr_roll < num_rolls.to_i do
        roll_object = Roll.new(roll)
        parsed_rolls.append(roll_object)
        curr_roll += 1
      end
  end
  return parsed_rolls
end
