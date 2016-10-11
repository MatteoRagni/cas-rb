#!/usr/bin/env ruby

require 'test/unit'
require_relative '../lib/ragni-cas.rb'

# Testing lib/numbers/constants.rb
class TestFunction < Test::Unit::TestCase
  # Preparing tested variables
  def setup
    @x, @y, @z = CAS::vars :x, :y, :z
    @f = CAS::Function.new :f, @x, @y, @z
  end
  
  def test_new
    assert_equal(@f, CAS.declare(:f, @x, @y, @z))
    assert_equal(@f, CAS::Function.new(:f))
    assert_equal(@f, CAS.declare(:f))            
  end
  
  def test_class_method
    assert_equal(CAS::Function.list, [@f], "Function.list failed")
    assert_equal(CAS::Function.exist?(:f), true, "Function.exist? failed")
    assert_equal(CAS::Function.size, 1, "Function.size failed")
  end
end
