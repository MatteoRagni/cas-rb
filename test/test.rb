#!/usr/bin/env ruby

require '../lib/cas.rb'


x = CAS::Variable.new("x")
two = CAS::Two

f = CAS::sqrt(CAS.pow(x, two) +  CAS::sin(x) * 2.0 + CAS::exp(x) * 3.0)

f_diff = f.diff(x)
f_diff_value = f_diff.call({
    x => 1.0
  })

puts "#{f_diff} = #{f_diff_value}"

f_diff.simplify
puts "#{f_diff} = #{f_diff.call({x => 1.0})}"
