# frozen_string_literal: true

# godbound roll logic

def godbound_damage_total(results)
  results.reduce(0) do |sum, n|
    sum + godbound_damage_conversion(n)
  end
end

def godbound_damage_conversion(raw_number)
  case [raw_number, 10].min
  when 10
    4
  when 6..9
    2
  when 2..5
    1
  when 1
    0
  end
end
