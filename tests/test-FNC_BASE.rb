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

class TestSum < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Sum.new(@x, @b), (@x + @b))
  end

  def test_subs
    s = {@x => @a, @y => @b}
    assert_equal(@a + @b, (@x + @b).subs(s))
    assert_equal(@a + @b, (@a + @y).subs(s))
  end

  def test_to_code
    assert_equal("(x + y)", (@x + @y).to_code)
  end

  def test_to_s
    assert_equal("(x + y)", "#{@x + @y}")
  end

  def test_simplify
    assert_equal(CAS::Zero, (CAS::Zero + CAS::Zero).simplify)
    assert_equal(@x, (@x + CAS::Zero).simplify)
    assert_equal(@x, (CAS::Zero + @x).simplify)
  end

  def test_diff
    assert_equal(@a, (@x + @y).diff(@x).simplify)
    assert_equal(@a, (@x + @y).diff(@y).simplify)
    assert_equal(@a, (@x + @b).diff(@x).simplify)
    assert_equal(@a, (@b + @y).diff(@y).simplify)
    assert_equal(CAS::Zero, (@x + @y).diff(@z).simplify)
  end
end

class TestDiff < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Diff.new(@x, @b), (@x - @b))
  end

  def test_subs
    s = {@x => @a, @y => @b}
    assert_equal(@a - @b, (@x - @b).subs(s))
    assert_equal(@a - @b, (@a - @y).subs(s))
  end

  def test_to_code
    assert_equal("(x - y)", (@x - @y).to_code)
  end

  def test_to_s
    assert_equal("(x - y)", "#{@x - @y}")
  end

  def test_simplify
    assert_equal(CAS::Zero, (CAS::Zero + CAS::Zero).simplify)
    assert_equal(@a, (@a + CAS::Zero).simplify)
    assert_equal(-@a, (CAS::Zero - @a).simplify)
  end

  def test_diff
    assert_equal(@a, (@x - @y).diff(@x).simplify)
    assert_equal(-@a, (@x - @y).diff(@y).simplify)
    assert_equal(@a, (@x - @b).diff(@x).simplify)
    assert_equal(-@a, (@b - @y).diff(@y).simplify)
    assert_equal(CAS::Zero, (@x - @y).diff(@z).simplify)
  end
end

class TestProd < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_new
    assert_equal(CAS::Prod.new(@b, @a), (@b * @a))
  end

  def test_subs
    s = {@x => @a, @y => @b}
    assert_equal(@a * @b, (@x * @b).subs(s))
    assert_equal(@a * @b, (@a * @y).subs(s))
    assert_equal(@a * @b, (@x * @y).subs(s))
  end

  def test_to_code
    assert_equal("(x * y)", (@x * @y).to_code)
  end

  def test_to_s
    assert_equal("(x * y)", "#{@x * @y}")
  end

  def test_simplify
    assert_equal(CAS::Zero, (CAS::Zero * CAS::Zero).simplify)
    assert_equal(CAS::Zero, (@x * CAS::Zero).simplify)
    assert_equal(CAS::Zero, (CAS::Zero * @x).simplify)
    assert_equal(@x, (CAS::One * @x).simplify)
    assert_equal(@x, (@x * CAS::One).simplify)
  end

  def test_diff
    assert_equal(@y, (@x * @y).diff(@x).simplify)
    assert_equal(@x, (@x * @y).diff(@y).simplify)
    assert_equal(@b, (@b * @x).diff(@x).simplify)
    assert_equal(@b, (@y * @b).diff(@y).simplify)
    assert_equal(CAS::Zero, (@x * @y).diff(@z).simplify)
    assert_equal(@a, (@x * @y).diff(@x).diff(@y).simplify)
    assert_equal(@a, (@x * @y).diff(@y).diff(@x).simplify)
  end
end

class TestDiv < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_init
    assert_equal(CAS::Div.new(@a, @x), (@a / @x))
  end

  def test_subs
    s = {@x => @a, @y => @b}
    assert_equal(@b / @z, (@y / @z).subs(s))
    assert_equal(@z / @a, (@z / @x).subs(s))
    assert_equal(@b / @a, (@y / @x).subs(s))
  end

  def test_to_code
    assert_equal("(x / y)", (@x / @y).to_code)
  end

  def test_to_s
    assert_equal("(x) / (y)", "#{@x / @y}")
  end

  def test_call
    s = {@x => 1.0, @y => 2.0}
    assert_equal(0.5, (@x / @y).call(s))
  end

  def test_simplify
    assert_equal(CAS::Infinity, (@x / CAS::Zero).simplify)
    assert_equal(CAS::Zero, (CAS::Zero / @x).simplify)
    assert_equal(CAS::Zero, (@x / CAS::Infinity).simplify)
    assert_equal(CAS::One, (@x / @x).simplify)
    assert_equal(CAS::Zero / CAS::Zero, (CAS::Zero / CAS::Zero).simplify)
    assert_equal(CAS::Infinity / CAS::Infinity, (CAS::Infinity / CAS::Infinity).simplify)
    assert_equal(CAS::Zero / CAS::Infinity, (CAS::Zero / CAS::Infinity).simplify)
    assert_equal(CAS::Infinity / CAS::Zero, (CAS::Infinity / CAS::Zero).simplify)
  end

  def test_diff
    assert_equal(@a / @y, (@x / @y).diff(@x).simplify)
    assert_equal(-(@b / (@y ** 2)), (@b / @y).diff(@y).simplify)
  end
end

class PowTest < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_init
    assert_equal(CAS::Pow.new(@x, @y), @x ** @y)
  end

  def test_subs
    s = {@x => @a, @y => @b}
    assert_equal(@a ** @b, (@x ** @y).subs(s))
    assert_equal(@z ** @b, (@z ** @y).subs(s))
    assert_equal(@a ** @z, (@x ** @z).subs(s))
  end

  def test_to_code
    assert_equal("(x ** y)", (@x ** @y).to_code)
  end

  def test_to_s
    assert_equal("(x)^(y)", (@x ** @y).to_s)
  end

  def test_call
    s = {@x => 1.0, @y => 2.0}
    assert_equal(1.0, (@x ** @y).call(s))
  end

  def test_simplify
    assert_equal(CAS::Zero, (CAS::Zero ** @y).simplify)
    assert_equal(CAS::One, (@x ** CAS::Zero).simplify)
    assert_equal(CAS::One, (CAS::One ** CAS::One).simplify)
    assert_equal(@x, (@x ** CAS::One).simplify)
    assert_equal(CAS::Zero ** CAS::Zero, (CAS::Zero ** CAS::Zero).simplify)
    assert_equal(CAS::Infinity ** CAS::Infinity, (CAS::Infinity ** CAS::Infinity).simplify)
    assert_equal(CAS::Zero ** CAS::Infinity, (CAS::Zero ** CAS::Infinity).simplify)
    assert_equal(CAS::Infinity ** CAS::Zero, (CAS::Infinity ** CAS::Zero).simplify)
  end

  def test_diff
    assert_equal((@x ** (@y - 1)) * @y, (@x ** @y).diff(@x).simplify)
    assert_equal((@x ** @y) * CAS.log(@x), (@x ** @y).diff(@y).simplify)
    assert_equal((@x ** @x) * (CAS.log(@x) + @a), (@x ** @x).diff(@x).simplify)
  end
end


class SqrtTest < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_init
    assert_equal(CAS::Sqrt.new(@x), CAS.sqrt(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.sqrt(@a), CAS.sqrt(@x).subs(s))
  end

  def test_to_code
    assert_equal("Math::sqrt(x)", CAS.sqrt(@x).to_code)
  end

  def test_to_s
    assert_equal("√(x)", CAS.sqrt(@x).to_s)
  end

  def test_call
    s = {@x => 1.0}
    assert_equal(1.0, CAS.sqrt(@x).call(s))
  end

  def test_simplify
    assert_equal(CAS::Zero, (CAS.sqrt(CAS::Zero)).simplify)
    assert_equal(CAS::One, (CAS.sqrt(CAS::One)).simplify)
    assert_equal(@x ** (@y - 0.5), (CAS.sqrt(@x ** @y)).simplify)
  end

  def test_diff
    assert_equal(1/(2 * CAS.sqrt(@x)), CAS.sqrt(@x).diff(@x))
  end
end


class InvertTest < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_init
    assert_equal(CAS::Invert.new(@x), -@x)
  end

  def test_subs
    s = {@x => @a}
    assert_equal(-@a, (-@x).subs(s))
  end

  def test_to_code
    assert_equal("(-x)", (-@x).to_code)
  end

  def test_to_s
    assert_equal("-x", (-@x).to_s)
  end

  def test_call
    s = {@x => 1.0}
    assert_equal(-1, (-@x).call(s))
  end

  def test_simplify
    assert_equal(@x, (-(-@x)).simplify)
    assert_equal(CAS::Zero, (-CAS::Zero).simplify)
  end

  def test_diff
    assert_equal(-@a, (-@x).diff(@x))
  end
end


class AbsTest < Test::Unit::TestCase
  def setup
    @a, @b, @c = CAS::const 1, 2, 3
    @x, @y, @z = CAS::vars :x, :y, :z
  end

  def test_init
    assert_equal(CAS::Abs.new(@x), CAS.abs(@x))
  end

  def test_subs
    s = {@x => @a}
    assert_equal(CAS.abs(@a), CAS.abs(@x).subs(s))
  end

  def test_to_code
    assert_equal("(x).abs", CAS.abs(@x).to_code)
  end

  def test_to_s
    assert_equal("|x|", CAS.abs(@x).to_s)
  end

  def test_call
    s = {@x => -1.0}
    assert_equal(1, (CAS.abs(@x)).call(s))
  end

  def test_simplify
    assert_equal(CAS::Zero, (CAS.abs(CAS::Zero)).simplify)
    assert_equal(CAS.abs(@a), (CAS.abs(-@a)).simplify) # FIXME
  end

  def test_diff
    assert_equal(@x / CAS.abs(@x), (CAS.abs(@x)).diff(@x).simplify)
    assert_equal(-@a * ((-@x) / CAS.abs(@x)), (CAS.abs(-@x)).diff(@x).simplify)
  end
end
