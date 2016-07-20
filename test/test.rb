#!/usr/bin/env ruby

require 'ragni-cas'


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

pr = f_diff.as_proc
puts pr.inspect
puts pr.call([1.0])
puts CAS::Variable.all_variables

class Alpha
  def initialize(op, var)
    @f = op
    @df = op.diff(var).simplify
    self.create_method(:f, @f.as_proc)
    self.create_method(:df, @df.as_proc)
  end

  def create_method(name, block)
    self.class.send(:define_method, name, block)
  end
end

t = Alpha.new f, x
puts t.f([1.0]), t.df([1.0])
