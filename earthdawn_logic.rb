# Given how specific earthdawn logic is, the logic to convert the request to something parsable by dice-maiden is done here
@earthdawn_replacements = Array[
    '',
    '1d4 ie - 2',
    '1d4 ie - 1',
    '1d4 ie',
    '1d6 ie',
    '1d8 ie',
    '1d10 ie',
    '1d12 ie',
    '2d6 ie',
    '1d8 ie + 1d6 ie',
    '2d8 ie',
    '1d10 ie + 1d8 ie',
    '2d10 ie',
    '1d12 ie + 1d10 ie',
    '2d12 ie',
    '1d12 ie + 2d6 ie',
    '1d12 ie + 1d8 ie + 1d6 ie',
    '1d12 ie + 2d8 ie',
    '1d12 ie + 1d10 ie + 1d8 ie',
    '1d20 ie + 2d6 ie',
    '1d20 ie + 1d8 ie + 1d6 ie',
]

def replace_earthdawn(event)
  roll = @input.match(/^\s*ed(\d+)/i)
  step = roll[1].to_i
  if step.between?(1, 20)
    @input.sub!('ed' + roll[1], @earthdawn_replacements[step])
  else
    event.respond(content: 'Only steps 1-20 are implemented')
    false
  end
end
