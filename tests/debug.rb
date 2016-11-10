#!/usr/bin/env ruby

require_relative '../lib/ragni-cas.rb'
require 'colorize'
require 'pry-byebug'


if __FILE__ == $0
  # x, y = CAS::vars :x, :y
  # f = CAS::sin(x ** 2) + y

  # h, s = f.to_c_lib("test")
  # puts f
  # puts "CREATING HEADER".green
  # puts h
  # puts "CREATING SOURCE".green
  # puts s

  # puts
  # puts
  @x, @y, @z = CAS::vars :x, :y, :z
  #@f = CAS::Function.new :f, @x, @y, @z
  #@g = (CAS.sin(CAS.sqrt(@x)) ** 2 + CAS.cos(CAS.sqrt(@x)) ** 2)
  #@h = @g + CAS.ln(CAS.exp(@y))

  #h_ret = (CAS.sin(@f ** 5) ** 2 + CAS.cos(@f ** 5) ** 2) + (@z - @f)
  #h_sub = {
  #  CAS.sqrt(@x) => @f ** 5,
  #  CAS.ln(CAS.exp(@y)) => (@z - @f)
  #}
  #@h.subs(h_sub).to_s
  #puts @h
  a = (@x * @x * @y * @y * @y)
  binding.pry
  a.subs({})
end
