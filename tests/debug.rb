#!/usr/bin/env ruby

require_relative '../lib/ragni-cas.rb'
unless require 'pry-byebug'
  puts "Please install pry-byebug"
  exit 1
end

if __FILE__ == $0
  @x, @y, @z = CAS::vars :x, :y, :z
  f = CAS.declare :f, @x, @y, @z
  binding.pry
  f = CAS.declare :f, @z, @y, @x
end
