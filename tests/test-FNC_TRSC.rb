#!/usr/bin/env ruby

require 'test/unit'
require_relative '../lib/Mr.CAS.rb'

# For each function:
#  - new: Creates a instance of the function
#  - subs: test substitution
#  - to_code: test code creation
#  - to_s: test creation of a string
#  - diff: test derivatives of a function
#  - simplify: test simplifications for a function


class TestExp < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Exp.new(@x), CAS.exp(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.exp(@a), CAS.exp(@x).subs(s))
  end

  def test_to_code
    assert_equal("Math::exp(x)", CAS.exp(@x).to_code)
  end

  def test_to_s
    assert_equal("exp(x)", CAS.exp(@x).to_s)
  end

  def test_simplify
    assert_equal(@a, CAS.exp(CAS::Zero).simplify)
    assert_equal(CAS::E, CAS.exp(@a).simplify)
    assert_equal(CAS::Infinity, CAS.exp(CAS::Infinity).simplify)
  end

  def test_diff
    assert_equal(CAS.exp(@x), CAS.exp(@x).diff(@x).simplify)
  end
end


class TestLn < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Ln.new(@x), CAS.ln(@x))
    assert_equal(CAS::Ln.new(@x), CAS.log(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.ln(@a), CAS.ln(@x).subs(s))
  end

  def test_to_code
    assert_equal("Math::log(x)", CAS.ln(@x).to_code)
  end

  def test_to_s
    assert_equal("log(x)", CAS.log(@x).to_s)
  end

  def test_simplify
    assert_equal(-CAS::Infinity, CAS.log(CAS::Zero).simplify)
    assert_equal(CAS::Zero, CAS.log(@a).simplify)
    assert_equal(@a, CAS.log(CAS::E).simplify)
  end

  def test_diff
    assert_equal(1 / @x, CAS.log(@x).diff(@x).simplify)
  end
end
