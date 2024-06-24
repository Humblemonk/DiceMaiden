# All bot logic that is not handled by Dice-Bag lives here
require_relative 'godbound_logic'

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
    [/\b\d+CoD\b/i, 'CoD 10-again', /\b(\d+)CoD\b/i, '\\1d10 ie10 t8'], # Chronicles of Darkness (default, 10-again)
    [/\b\d+CoD8\b/i, 'CoD 8-again', /\b(\d+)CoD8\b/i, '\\1d10 ie8 t8'], # Chronicles of Darkness (8-again)
    [/\b\d+CoD9\b/i, 'CoD 9-again', /\b(\d+)CoD9\b/i, '\\1d10 ie9 t8'], # Chronicles of Darkness (9-again)
    [/\b\d+CoDR\b/i, 'CoD rote quality', /\b(\d+)CoDR\b/i, '\\1d10 r7 t8'], # Chronicles of Darkness (Rote quality, reroll all failed)
    [/\bd6s\d+\b/i, 'The D6 System', /\bd6s(\d+)\b/i, '\\1d6 + 1d6 ie'], # The D6 System
    [/\bd6s\b/i, '1 die D6 System', /\bd6s\b/i, '\\1d6ie'], # Single die role for the D6 System
    [/\bsr\d+\b/i, 'Shadowrun', /\bsr(\d+)\b/i, '\\1d6 t5'], # Shadowrun system
    [/\b\d+d%\B/i, 'Percentile roll', /\b(\d+)d%\B/i, '\\1d100'], # Roll a d100
    [/\bsp\d+\b/i, 'Storypath', /\bsp(\d+)\b/i, '\\1d10 ie10 t8'], # storypath system
    [/\b\d+yz\b/i, 'Year Zero', /\b(\d+)yz\b/i, '\\1d6 t6'], # year zero system
    [/\bdndstats\b/i, 'DnD Stat-roll', /\b(dndstats)\b/i, '6 4d6 k3'], # DnD character stats - 4d6 drop lowest 6 times
    [/\battack\b/i, 'DnD attack roll', /\b(attack)\b/i, '1d20'], # DnD attack roll
    [/\bskill\b/i, 'DnD skill check', /\b(skill)\b/i, '1d20'], # DnD skill check
    [/\bsave\b/i, 'DnD saving throw', /\b(save)\b/i, '1d20'], # DnD saving throw
    [/\b\d+hsn\b/i, 'Hero System Normal', /\b(\d+)hsn\b/i, 'hsn nr \\1d6'], # Hero System 5e Normal Damage
    [/\b\d+hsk\d*\b/i, 'Hero System Killing', /\b(\d+)hsk(\d*)\b/i, 'nr hsk\\2 \\1d6'], # Hero System 5e Killing Damage
    [/\b\d+hsh\b/i, 'Hero System to Hit', /\b(\d+)hsh\b/i, 'hsh nr 11+\\1 -3d6'] # Hero System 5e to Hit
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
    'Fudge' => [[/\b1\b/, '-'], [/\b2\b/, ' '], [/\b3\b/, '+']],
    'Hero System Normal' => [[/\b1\b/, '1 (+0)'], [/\b([2-5])\b/, '\\1 (+1)'], [/\b6\b/, '6 (+2)']]
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
  if event.channel.pm?
    @user = nil
    return
  end

  @user = if !event.user.nick.nil?
            event.user.nick
          else
            event.user.display_name
          end
end

def check_comment(event_roll)
  @comment = ''
  if event_roll.include?('!')
    @comment = event_roll.partition('!').last.lstrip
    # remove @ user ids from comments to prevent abuse
    @comment.gsub!(/<@!\d+>/, '')
    @do_tally_shuffle = true if @comment.include? 'unsort'
    event_roll = event_roll[/(^.*)!/]
    event_roll.slice! @comment
    event_roll.slice! '!'
  end
  @parsed_event_roll = event_roll
end

def check_roll(event)
  dice_requests = @roll.scan(/\d+d\d+/i)

  dice_requests.each do |dice_request|
    @special_check = dice_request.scan(/d(\d+)/i).first.join.to_i
    @dice_check = dice_request.scan(/d(\d+)/i).first.join.to_i

    if @dice_check < 2
      event.respond(content: 'Please roll a dice value 2 or greater')
      return true
    end
    if @dice_check > 1000
      event.respond(content: 'Please roll dice up to d1000')
      return true
    end
    # Check for too large of dice pools
    @dice_check = dice_request.scan(/(\d+)d/i).first.join.to_i
    if @dice_check > 500
      event.respond(content: 'Please keep the dice pool below 500')
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

    # raise an error if input queue starts with a 0 followed by an int
    raise 'Invalid dice format!' if input_queue_peek.match?(/\A0\d+/)

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

  return godbound_damage_conversion(output_stack[0]) if @godbound == true # allow stuff like 1d12+4 to be summed before converting

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
  @reroll_check += dice_roll.result.sections[0].options[:reroll]
  @reroll_indefinite_check += dice_roll.result.sections[0].options[:reroll_indefinite]
  @botch += dice_roll.result.sections[0].options[:botch]
  @show_botch = @botch > 0
  if @reroll_check > 0 || @reroll_indefinite_check > 0
    @reroll_count += dice_roll.result.sections[0].reroll_count
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

  if @godbound == true
    t = dice_roll.result.sections[0].tally
    if t.length > 1
      # for something like 5d8, just add it up and don't process afterwards
      @godbound = false
      return godbound_damage_total(t)
    end
  end

  token_total
end

def do_roll(event)
  roll_result = nil
  @tally = ''
  begin
    roll_result = process_rpn_token_queue(convert_input_to_rpn_queue(event, @roll))
  rescue RuntimeError => e
    event.respond(content: 'Error: ' + e.message)
    return true
  end

  if @roll_set.nil?
    @dice_result = "Result: `#{roll_result}`"
  else
    @roll_set_total += roll_result
    @dice_result = "Result: `#{roll_result}`"
  end
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
      f.puts "#{@time} Shard: #{@shard} | #{@server}| #{@user} Rolls:\n #{@roll_set_results}Results Total:`#{@roll_set_total}`"
    end
  end
end

def check_fury(event)
  if (@special_check == 10) && (@tally.include? '10') && (@dh == true)
    event.send_message(content: '`Righteous Fury Activated!` Purge the Heretic!')
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
    event.respond(content: "#{@user} Roll Wrath: `#{@wrath_value}`")
  else
    check_icons
    if dnum.to_s.empty? || dnum.to_s.nil?
    else
      check_dn(dnum)
    end
    event.respond(content: "#{@user} Roll: `#{@tally}` Wrath: `#{@wrath_value}` | #{@test_status} TOTAL - Icons: `#{@icons}` Exalted Icons: `#{@exalted_icons} (Value:#{@exalted_total})`")
    if @wresult_convert.include? '6'
      event.send_message(content: 'Combat critical hit and one point of Glory!')
    elsif @wresult_convert.include? '1'
      event.send_message(content: 'Complication!')
    end
  end
end

def check_donate(event)
  if @check =~ /^\s*(donate)\s*$/i
    event.respond(content: "\n Care to support the bot? You can donate via Patreon https://www.patreon.com/dicemaiden \n Another option is join the dedicated Dice Maiden Discord server and subscribe! https://discord.gg/4T3R5Cb")
    true
  end
end

def check_help(event)
  case @check
  when /^\s*(help)\s*$/i
    event.respond(content: @basic_help.to_s)
    true
  # I do not know when this bug occurred where the p is stripped. Check for hel instea of help
  when /^\s*hel.\s*(alias)\s*$/i
    event.respond(content: @alias_help.to_s)
    true
  when /^\s*hel.\s*(system)\s*$/i
    event.respond(content: @system_help.to_s)
    true
  end
end

@basic_help = "
```
Synopsis:
\t/roll xdx [OPTIONS]

\tDescription:
\t\#d# : The number before 'd' denotes how many dice to roll and the number following how many sides the dice should have.

\tThe following options are available:

\t\t+ - / * : Static modifier

\t\te# : The explode value.

\t\tie# : The indefinite explode value.

\t\tk# : How many dice to keep out of the roll, keeping highest value.

\t\tr# : Reroll value.

\t\tir# : Indefinite reroll value.

\t\tt# : Target number for a success.

\t\tf# : Target number for a failure.

\t\t! : Any text after ! will be a comment.

\tAdditional Help:

\t\t/roll 6 4d6 : Roll 6 sets of four six-sided dice. A size of a set can be between 2 and 20

\t\t/roll help alias: Show a list of basic dice aliases

\t\t/roll help system: Show a list of system-specific aliases and commands

/roll donate : Care to support the bot? Get donation information here: https://www.patreon.com/dicemaiden Thanks!

Find more commands at https://github.com/Humblemonk/DiceMaiden or join the Dice Maiden discord server and ask for help! https://discord.gg/4T3R5Cb```
"

@alias_help = "
```
  Full list of aliases can be found on github.

  Example Supported Aliases:

\t/roll dd## — Double Digits
\t\tRolls a die of the given size for each digit of the result.

\t/roll +d# — Advantage
\t\tRolls two dice of the given size and keeps the highest result.

\t/roll -d# — Disadvantage
\t\tRolls two dice of the given size and keeps the lowest result.

\t/roll #d% — Percetile Roll
\t\tRolls the given number of d100s.

\t/roll +d% — Percentile Advantage
\t\tRolls two d10s for the 10s digit and one for the ones digit keeping the lowest value tens digit.

\t/roll -d% — Percentile Disadvantage
\t\tRolls two d10s for the 10s digit and one for the ones digit keeping the highest value tens digit.
```
"

@system_help = "
```
  Full list of game systems can be found on github.

  Example Supported Game Systems:

\t/roll age — AGE System Test
\t\tRolls 2d6 plus one drama/dragon/stunt die.

\t/roll #cod — Chronicles of Darkness
\t\tRolls the given number of d10s, indefinitely exploding on tens, with a target of eight.

\t/roll dndstats — D&D Stats
\t\tRolls 4d6s dropping the lowest 6 times

\t/roll d6s# — D6 System
\t\tRolls the given number of d6s plus a wild die that indefinitely explodes on sixes.

\t/roll #df — Fudge Dice Roll
\t\tRolls the given number of fudge dice. Output shown as fudge faces: -/ /+

\t/roll sr# — Shadowrun
\t\tRolls the given number of d6s with a traget of five.

\t/roll sp# — Storypath
\t\tRolls the given number of d10s, indefinitely exploding on tens, with a target of eight.

\t/roll snm# — Sunsails: New Milennium; Fourth Edition
\t\tRolls the given number of d6s, indefinitely explodes on sixes, with a target of four.

\t/roll #wh#+ — Warhammer (AoS/40k)
\t\tRolls the first given number of d6s with a target of the second number.

\t/roll #wod# — World of darkness 4th edition
\t\tThe first number is the number of dice to roll and the second is the toughness of the check (does not currently explode).

\t/roll #yz — Year Zero
\t\tRolls the given number of d6s with a target of six.
```
"

def check_purge(event)
  if @check =~ /^\s*(purge)\s*\d*$/i
    @roll.slice! 'purge'
    amount = @input.to_i
    if (amount < 2) || (amount > 100)
      event.respond(content: 'Amount must be between 2-100')
      return false
    end
    if event.user.defined_permission?(:manage_messages) == true ||
       event.user.defined_permission?(:administrator) == true ||
       event.user.permission?(:manage_messages, event.channel) == true
      event.defer
      event.channel.prune(amount)
      event.send_message(content: "`#{@user}` deleted #{amount} messages from channel")
    else
      event.respond(content: "#{@user} does not have permissions for this command")
    end
  end
end

def check_bot_info(event)
  if @check =~ /^\s*(bot-info)\s*$/i
    if @launch_option == 'lite'
      event.respond(content: 'This option is not supported with Dice Maiden Lite.')
      return true
    end
    servers = $db.execute 'select sum(server_count) from shard_stats;'
    event.respond(content: "| Dice Maiden | - #{servers.join.to_i} active servers")
    true
  end
end

def input_valid(event)
  event_input = event.content
  if event_input =~ /\A^(#{@prefix}\s)/i
    true
  else
    false
  end
end

def check_roll_modes
  case @input
  when /^\s?(wng)\s/i
    @wng = true
    @input.sub!('wng', '')
  when /^\s?(dh)\s/i
    @dh = true
    @input.sub!('dh', '')
  when /^\s?(s)\s/i
    @simple_output = true
    @input.sub!('s', '')
  when /\s?(ul)\s/i
    @do_tally_shuffle = true
    @input.sub!('ul', '')
  when /\s?(p)\s/i
    @private_roll = true
    @input.sub!('p', '')
  when /\s?(gb)\s/i
    @godbound = true
    @input.sub!('gb', '')
  when /\s?(hsn)\s/i
    @hsn = true
    @input.sub!('hsn', '')
  when /\s?(hsk)\s?/i
    @hsk = true
    if @input.match(/hsk\d+/i)
      multiplier_string = @input.scan(/hsk\d+/i).join.to_s
      @hsk_multiplier_modifier = multiplier_string.scan(/\d+/).join.to_i
      @input.sub!(/hsk\d+/i, '')
    else
      @hsk_multiplier_modifier = 0
      @input.sub!('hsk', '')
    end
  end

  # check for Hero System 5e to hit mode for roll
  if @input.match(/\s?(hsh)\s?/i)
    @hsh = true
    @input.sub!('hsh', '')
  end

  # check for no total mode for roll
  if @input.match(/\s?(nr)\s/i)
    @no_result = true
    @input.sub!('nr', '')
  end

  @ed = true if @input.match(/^\s?(ed\d+)/i) || @input.match(/^\s?(ed4e\d+)/i)
end

def roll_sets_valid(event)
  @roll_set = @input.scan(/^\s?(\d+)\s/i).first.join.to_i if @input.match(/^\s?(\d+)\s/i)

  if !@roll_set.nil? && ((@roll_set <= 1) || (@roll_set > 20))
    event.respond(content: 'Roll set must be between 2-20')
    return false
  end

  if @roll_set.nil?
    @input.slice!(/^#{@prefix}/i)
  else
    @input.slice!(/^#{@prefix}\s*/i)
    @input.slice!(0..@roll_set.to_s.size)
  end
end

def hero_system_math
  if @hsn
    @hsn_body = 0
    @hsn_body += @tally.scan(/\+2\D/).count
    @hsn_body *= 2
    @hsn_body += @tally.scan(/\+1\D/).count
    @hsn_stun = @dice_result.scan(/\d+/)
  end

  if @hsk
    @hsk_body = @dice_result.scan(/\d+/)
    @hsk_stun_roll = DiceBag::Roll.new('1d6').result.total
    @hsk_multiplier = @hsk_stun_roll - 1 + @hsk_multiplier_modifier
    if @hsk_multiplier.zero?
      @hsk_multiplier = 1
    end
    @hsk_stun = @hsk_body.join.to_i * @hsk_multiplier
  end
end

def botch_counter
  @botch_count = 0
  while @botch > 0
    @botch_count += @tally.scan(/\D#{@botch}\D/).count
    @botch -= 1
  end
  " Botches: `#{@botch_count}`"
end

def build_response
  response = "#{@user} Request: `[#{@roll_request.strip}]`"
  unless @simple_output
    response += " Roll: `#{@tally}`"
    response += " Rerolls: `#{@reroll_count}`" if @show_rerolls
  end
  response += botch_counter if @show_botch
  response += " #{@dice_result}" unless @no_result

  if @hsn
    response += " Body: `#{@hsn_body}`, Stun: `#{@hsn_stun}`"
  end

  if @hsk
    response += " Body: `#{@hsk_body}`, Stun Multiplier: `#{@hsk_multiplier}`, Stun: `#{@hsk_stun}`"
  end

  if @hsh
    response += " Hits DCV `#{@dice_result.scan(/\d+/)}`"
  end

  response += " Reason: `#{@comment}`" if @has_comment
  response
end
