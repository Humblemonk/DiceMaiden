# Given how specific earthdawn logic is, the logic to convert the request to something parsable by dice-maiden is done here
@earthdawn_replacements = Array[
    '',
    '1d4 ie - 2',                          # Step 1
    '1d4 ie - 1',                          # Step 2
    '1d4 ie',                              # Step 3
    '1d6 ie',                              # Step 4
    '1d8 ie',                              # Step 5
    '1d10 ie',                             # Step 6
    '1d12 ie',                             # Step 7
    '2d6 ie',                              # Step 8
    '1d8 ie + 1d6 ie',                     # Step 9
    '2d8 ie',                              # Step 10
    '1d10 ie + 1d8 ie',                    # Step 11
    '2d10 ie',                             # Step 12
    '1d12 ie + 1d10 ie',                   # Step 13
    '2d12 ie',                             # Step 14
    '1d12 ie + 2d6 ie',                    # Step 15
    '1d12 ie + 1d8 ie + 1d6 ie',           # Step 16
    '1d12 ie + 2d8 ie',                    # Step 17
    '1d12 ie + 1d10 ie + 1d8 ie',          # Step 18
    '1d20 ie + 2d6 ie',                    # Step 19
    '1d20 ie + 1d8 ie + 1d6 ie',           # Step 20
    '1d20 ie + 1d10 ie + 1d6 ie',          # Step 21
    '1d20 ie + 1d10 ie + 1d8 ie',          # Step 22
    '1d20 ie + 2d10 ie',                   # Step 23
    '1d20 ie + 1d12 ie + 1d10 ie',         # Step 24
    '1d20 ie + 1d12 ie + 1d8 ie + 1d4 ie', # Step 25
    '1d20 ie + 1d12 ie + 1d8 ie + 1d6 ie', # Step 26
    '1d20 ie + 1d12 ie + 2d8 ie',          # Step 27
    '1d20 ie + 2d10 ie + 1d8 ie',          # Step 28
    '1d20 ie + 1d12 ie + 1d10 ie + 1d8 ie',  # Step 29
    '1d20 ie + 1d12 ie + 1d10 ie + 1d8 ie',  # Step 30
    '1d20 ie + 1d10 ie + 2d8 ie + 1d6 ie', # Step 31
    '1d20 ie + 2d10 ie + 1d8 ie + 1d6 ie', # Step 32
    '1d20 ie + 2d10 ie + 2d8 ie',          # Step 33
    '1d20 ie + 3d10 ie + 1d8 ie',          # Step 34
    '1d20 ie + 1d12 ie + 2d10 ie + 1d8 ie', # Step 35
    '2d20 ie + 1d10 ie + 1d8 ie + 1d4 ie', # Step 36
    '2d20 ie + 1d10 ie + 1d8 ie + 1d6 ie', # Step 37
    '2d20 ie + 1d10 ie + 2d8 ie',          # Step 38
    '2d20 ie + 2d10 ie + 1d8 ie',          # Step 39
    '2d20 ie + 1d12 ie + 1d10 ie + 1d8 ie', # Step 40
    '2d20 ie + 1d10 ie + 1d8 ie + 2d6 ie', # Step 41
    '2d20 ie + 1d10 ie + 2d8 ie + 1d6 ie', # Step 42
    '2d20 ie + 2d10 ie + 1d8 ie + 1d6 ie', # Step 43
    '2d20 ie + 2d10 ie + 2d8 ie',          # Step 44
    '2d20 ie + 3d10 ie + 1d8 ie',          # Step 45
    '2d20 ie + 1d12 ie + 2d10 ie + 1d8 ie', # Step 46
    '2d20 ie + 2d10 ie + 2d8 ie + 1d4 ie', # Step 47
    '2d20 ie + 2d10 ie + 2d8 ie + 1d6 ie', # Step 48
    '2d20 ie + 2d10 ie + 3d8 ie',          # Step 49
    '2d20 ie + 3d10 ie + 2d8 ie' # Step 50
]

@earthdawn4_replacements = Array[
'',
'1d4 - 2 ie',               # Step 1
'1d4 - 1 ie',               # Step 2
'1d4 ie',                   # Step 3
'1d6 ie',                   # Step 4
'1d8 ie',                   # Step 5
'1d10 ie',                  # Step 6
'1d12 ie',                  # Step 7
'2d6 ie',                   # Step 8
'1d8 ie + 1d6 ie',          # Step 9
'2d8 ie ',                  # Step 10
'1d10 ie + 1d8 ie',         # Step 11
'2d10 ie',                  # Step 12
'1d12 ie + 1d10 ie',        # Step 13
'2d12 ie',                  # Step 14
'1d12 + ie 2d6 ie',         # Step 15
'1d12 + ie 1d8 ie + 1d6 ie', # Step 16
'1d12 + ie 2d8 ie', # Step 17
'1d12 + ie 1d10 ie + 1d8 ie ', # Step 18
'1d20 + ie 2d6 ie',            # Step 19
'1d20 + ie 1d8 + 1d6 ie',      # Step 20
'1d20 + ie 2d8 ie',            # Step 21
'1d20 + ie 1d10 ie + 1d8 ie',  # Step 22
'1d20 + ie 2d10 ie',           # Step 23
'1d20 + ie 1d12 ie + 1d10 ie', # Step 24
'1d20 + ie 2d12 ie',           # Step 25
'1d20 + ie 1d12 ie + 2d6 ie',  # Step 26
'1d20 + ie 1d12 ie + 1d8 ie + 1d6 ie',  # Step 27
'1d20 + ie 1d12 ie + 2d8 ie',           # Step 28
'1d20 + ie 1d12 ie + 1d10 ie + 1d8 ie', # Step 29
'2d20 + ie 2d6 ie',                     # Step 30
'2d20 + ie 1d8 ie + 1d6 ie',            # Step 31
'2d20 + ie 2d8 ie',                     # Step 32
'2d20 + ie 1d10 ie + 1d8 ie',           # Step 33
'2d20 + ie 2d10 ie',                    # Step 34
'2d20 + ie 1d12 ie + 1d10 ie',          # Step 35
'2d20 + ie 2d12 ie',                    # Step 36
'2d20 + ie 1d12 ie + 2d6 ie',           # Step 37
'2d20 + ie 1d12 ie + 1d8 ie + 1d6',     # Step 38
'2d20 + ie 1d12 ie + 2d8 ie',           # Step 39
'2d20 + ie 1d12 ie + 1d10 ie + 1d8 ie'  # Step 40
]

def replace_earthdawn(event)
  # check for earth dawn 4th edition first
  if (roll = @input.match(/^\s*ed4e(\d+)/i))
    step = roll[1].to_i
    if step.between?(1, 40)
      @input.sub!('ed4e' + roll[1], @earthdawn4_replacements[step])
      true
    else
      event.respond(content: 'Only steps 1-40 are implemented')
      false
    end
  # check other earth dawn editions next
  elsif (roll = @input.match(/^\s*ed(\d+)/i))
    step = roll[1].to_i
    if step.between?(1, 50)
      @input.sub!('ed' + roll[1], @earthdawn_replacements[step])
      true
    else
      event.respond(content: 'Only steps 1-50 are implemented')
      false
    end
  end
end
