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
    assert_equal(@f, CAS.declare(:f, @x, @y, @z), "CAS.declare with same order failed")
    assert_equal(@f, CAS.declare(:f, @z, @y, @x), "CAS.declare with different order failed")

    assert_equal(@f, CAS::Function.new(:f), "CAS.Function.new with only name failed")
    assert_equal(@f, CAS.declare(:f), "CAS.declare with only name failed")

    assert_raises CAS::CASError do
      CAS::Function.new(:f, @x)
    end
  end

  def test_class_method
    assert_equal(CAS::Function.list, {:f => @f}, "Function.list failed")
    assert_equal(CAS::Function.exist?(:f), true, "Function.exist? failed")
    assert_equal(CAS::Function.size, 1, "Function.size failed")
    assert_equal(CAS::Function[:f], @f, "Function.[] failed")
  end

  def test_args
    assert_equal([@x, @y, @z], @f.args)
  end

  def test_simplify
    assert_equal(@f, @f.simplify)
  end

  def test_diff
    df = @f.diff(@x)
    assert_equal(:"df[#{@x}]", df.name)
    assert_equal([@x, @y, @z], df.args)

    v = CAS::vars :v
    assert_equal(CAS::Zero, @f.diff(v))
  end

  def tes_to_s
    assert_equal("f(x, y, z)", @f.to_s, "Function#to_s failed")
    assert_equal("f(x, y, z)", @f.inspect, "Function#inspect failed")
  end

  def test_equal
    assert_true(@f == @f)
  end

  def test_call
    assert_raises CAS::CASError do
      @f.call nil
    end
  end

  def test_to_code
    assert_raises CAS::CASError do
       @f.to_code
    end
  end

  def test_subs
    assert_raises CAS::CASError do
      @f.subs(@x => @y ** 2)
    end
    assert_equal("f(y, z)", @f.subs({@x => @y}).inspect)
  end
end
