#!/usr/bin/env ruby

require 'test/unit'
require_relative '../lib/Mr.CAS.rb'
require 'pry'

# Testing lib/numbers/constants.rb
class TestFunction < Test::Unit::TestCase
  # Preparing tested variables
  def setup
    @x, @y, @z = CAS::vars :x, :y, :z
    @f = CAS::Function.new :f, @x, @y, @z
    @l = CAS::Function.new(:l, CAS.sin(@x + @y), @x ** 2)
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
    assert_equal(CAS::Function.list, {:f => @f, :l => @l}, "Function.list failed")
    assert_equal(CAS::Function.exist?(:f), true, "Function.exist? failed")
    assert_equal(CAS::Function.size, 2, "Function.size failed")
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
    assert_equal([@x, @y, @z], df.args)

    dl = @l.diff(@x).simplify
    assert_equal(CAS.cos(@x + @y) * CAS::Function[:"Dl[0]"] +
                (2 * @x) * CAS::Function[:"Dl[1]"] , dl)

    v = CAS::vars :v
    assert_equal(CAS::Zero, @f.diff(v).simplify)
  end

  def test_diff_combined
    a = CAS.declare :a, @x
    b = CAS.declare :b, a
    bd = b.diff(@x)

    bd0 = CAS::Function[:"Db[0]"]
    ad0 = CAS::Function[:"Da[0]"]
    assert_equal(bd, (CAS::One * ad0 * bd0))
  end

  def tes_to_s
    assert_equal("f(x, y, z)", @f.to_s, "Function#to_s failed")
    assert_equal("f(x, y, z)", @f.inspect, "Function#inspect failed")
  end

  def test_equal
    assert_equal(true, @f == @f)
  end

  def test_call
    assert_raises CAS::CASError do
      @f.call @x => @y
    end
  end

  def test_to_code
    assert_raises CAS::CASError do
       @f.to_code
    end
  end

  def test_subs
    # assert_raises CAS::CASError do
    #   @f.subs(@x => @y ** 2)
    # end
    g = CAS.declare :sub_test, CAS.sin(@x + @y), @x ** 2
    assert_equal("sub_test(sin((y + y)), (y)^(2))", g.subs({@x => @y}).to_s)
  end
end
