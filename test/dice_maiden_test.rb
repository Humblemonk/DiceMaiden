#!/usr/bin/ruby
# frozen_string_literal: true

# test various dice maiden commands

# Test single die rolls

[
  'd5 + d6',
  '1d6 + 2d8 d1',
  '1d6 + 2d8 d1',
  'd6',
  'd5 + 2d6',
  '1d5 + d6',
  'd5 + d6 d1',
  'd20 d1'
].each do |s|
  print "#{s.ljust(16, ' ')}=> "
  print s.gsub(/(?<!\d)(^|[+-]\s?)d(\d+)/, '\11d\2')
  print "\n"
end
