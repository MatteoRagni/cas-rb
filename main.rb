#!/usr/bin/env ruby

require './lib/cas.rb'


x = CAS::Variable.new("x")
two = CAS::Two

f = CAS::sqrt(CAS::pow(x, two) + two * x + two)

f_diff = f.diff(x)
f_diff_value = f_diff.call({
    x => 1.0
  })

puts "#{f_diff} = #{f_diff_value}"
