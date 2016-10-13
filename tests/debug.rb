#!/usr/bin/env ruby

require_relative '../lib/ragni-cas.rb'
require_relative '../lib/ragni-cas/c.rb'
require 'colorize'


if __FILE__ == $0
  x, y = CAS::vars :x, :y
  f = CAS::sin(x ** 2) + y

  h, s = f.to_c_lib("test")
  puts f
  puts "CREATING HEADER".green
  puts h
  puts "CREATING SOURCE".green
  puts s
end
