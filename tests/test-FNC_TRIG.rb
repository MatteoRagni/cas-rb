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

# SIN ##########################################################################

class TestSin < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Sin.new(@x), CAS.sin(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.sin(@a), CAS.sin(@x).subs(s))
  end

  def test_to_code
    assert_equal("Math::sin(x)", CAS.sin(@x).to_code)
  end

  def test_to_s
    assert_equal("sin(x)", CAS.sin(@x).to_s)
  end

  def test_simplify
    assert_equal(CAS::Zero, CAS.sin(CAS::Zero).simplify)
    assert_equal(CAS::Zero, CAS.sin(CAS::Pi).simplify)
    assert_equal(CAS::One, (CAS.sin(CAS::Pi/2)).simplify)
  end

  def test_diff
    assert_equal(CAS.cos(@x), CAS.sin(@x).diff(@x).simplify)
  end
end

class TestAsin < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Asin.new(@x), CAS.asin(@x))
    assert_equal(CAS::Asin.new(@x), CAS.arcsin(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.asin(@a), CAS.asin(@x).subs(s))
  end

  def test_to_code
    assert_equal("Math::asin(x)", CAS.asin(@x).to_code)
  end

  def test_to_s
    assert_equal("asin(x)", CAS.asin(@x).to_s)
  end

  def test_simplify
    assert_equal(CAS::Zero, CAS.asin(CAS::Zero).simplify)
    assert_equal(CAS::Pi / 2, (CAS.asin(@a)).simplify)
  end

  def test_diff
    assert_equal(@a / (CAS.sqrt(@a - (@x ** @b))), CAS.asin(@x).diff(@x).simplify)
  end
end

# COS ##########################################################################

class TestCos < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Cos.new(@x), CAS.cos(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.cos(@a), CAS.cos(@x).subs(s))
  end

  def test_to_code
    assert_equal("Math::cos(x)", CAS.cos(@x).to_code)
  end

  def test_to_s
    assert_equal("cos(x)", CAS.cos(@x).to_s)
  end

  def test_simplify
    assert_equal(CAS::One, CAS.cos(CAS::Zero).simplify)
    assert_equal(CAS::One, CAS.cos(CAS::Pi).simplify)
    assert_equal(CAS::Zero, CAS.cos(CAS::Pi/2).simplify)
  end

  def test_diff
    assert_equal(-CAS.sin(@x), CAS.cos(@x).diff(@x).simplify)
  end
end

class TestAcos < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Acos.new(@x), CAS.acos(@x))
    assert_equal(CAS::Acos.new(@x), CAS.arccos(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.acos(@a), CAS.acos(@x).subs(s))
  end

  def test_to_code
    assert_equal("Math::acos(x)", CAS.acos(@x).to_code)
  end

  def test_to_s
    assert_equal("acos(x)", CAS.acos(@x).to_s)
  end

  def test_simplify
    assert_equal(CAS::Pi / 2, CAS.acos(CAS::Zero).simplify)
    assert_equal(CAS::Zero, CAS.acos(@a).simplify)
  end

  def test_diff
    assert_equal(-(@a / (CAS.sqrt(@a - (@x ** @b)))), CAS.acos(@x).diff(@x).simplify)
  end
end

################################################################################

class TestTan < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Tan.new(@x), CAS.tan(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.tan(@a), CAS.tan(@x).subs(s))
  end

  def test_to_code
    assert_equal("Math::tan(x)", CAS.tan(@x).to_code)
  end

  def test_to_s
    assert_equal("tan(x)", CAS.tan(@x).to_s)
  end

  def test_simplify
    assert_equal(CAS::Zero, CAS.tan(CAS::Zero).simplify)
    assert_equal(CAS::Zero, CAS.tan(CAS::Pi).simplify)
    assert_equal(CAS::Infinity, (CAS.tan(CAS::Pi/2)).simplify)
  end

  def test_diff
    assert_equal((@a / CAS.cos(@x)) ** @b, CAS.tan(@x).diff(@x).simplify)
  end
end

class TestAtan < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Atan.new(@x), CAS.atan(@x))
    assert_equal(CAS::Atan.new(@x), CAS.arctan(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.atan(@a), CAS.atan(@x).subs(s))
  end

  def test_to_code
    assert_equal("Math::atan(x)", CAS.atan(@x).to_code)
  end

  def test_to_s
    assert_equal("atan(x)", CAS.atan(@x).to_s)
  end

  def test_simplify
    assert_equal(CAS::Zero, CAS.atan(CAS::Zero).simplify)
    assert_equal(CAS::Pi / 4, CAS.atan(@a).simplify)
    assert_equal(CAS::Pi / 2, CAS.atan(CAS::Infinity).simplify)
  end

  def test_diff
    assert_equal(@a / ((@x ** 2) + 1), CAS.atan(@x).diff(@x).simplify)
  end
end
