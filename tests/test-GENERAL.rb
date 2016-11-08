#!/usr/bin/env ruby

require 'test/unit'
require_relative '../lib/ragni-cas.rb'

# Testing lib/numbers/constants.rb
class TestGeneral < Test::Unit::TestCase
  # Preparing tested variables
  def setup
    @x, @y, @z = CAS::vars :x, :y, :z
    @f = CAS::Function.new :f, @x, @y, @z
    @g = (CAS.sin(CAS.sqrt(@x)) ** 2 + CAS.cos(CAS.sqrt(@x)) ** 2)
    @h = @g + CAS.ln(CAS.exp(@y))
  end

  def test_subs
    h_ret = (CAS.sin(@f ** 5) ** 2 + CAS.cos(@f ** 5) ** 2) + (@z - @f)
    h_sub = {
      CAS.sqrt(@x) => @f ** 5,
      CAS.ln(CAS.exp(@y)) => (@z - @f)
    }

    assert_equal(h_ret.to_s, @h.subs(h_sub).to_s)
  end
end
