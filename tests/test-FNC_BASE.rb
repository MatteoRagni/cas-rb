#!/usr/bin/env ruby

require 'test/unit'

require_relative '../lib/ragni-cas.rb'

$x, $y, $z = CAS::vars :x, :y, :z
$a, $b, $c = CAS::const 1, 2, 3

class TestVariable < Test::Unit::TestCase


  def test_init
    assert_equal(CAS::Variable, $x.class)
    assert_raise(CAS::CASError) { CAS::Variable.new :x }
  end

  def test_diff
    assert_equal(CAS::One, $x.diff($x))
  end

  def test_inspect
    assert_equal("Var(x)", $x.inspect)
  end

  def test_exist?
    assert_equal(true, CAS::Variable.exist?(:x))
    assert_equal(false, CAS::Variable.exist?(:bho))
  end

  def text_list
    assert_equal({:x => $x}, CAS::Variable.list)
    assert_equal(1, CAS::Variable.size)
  end

  def test_to_s
    assert_equal("x", $x.to_s)
  end

  def test_call
    assert_equal(1.0, $x.call({:x => 1.0}))
    assert_equal(1.0, $x.call({$x => 1.0}))
  end

  def test_simplify
    assert_equal($x, $x.simplify)
  end

  def test_vars
    a = CAS::vars :a, :b, :c
    a.each do |e|
      assert_equal e.class, CAS::Variable
    end
  end
end

class TestConstant < Test::Unit::TestCase

  def test_init
    assert_equal($a.class, $b.class)
    assert_equal(false, $x == $a)
  end

  def test_initialize
    assert_equal(CAS::Constant, $a.class)
  end

  def test_diff
    assert_equal(CAS::Zero, $a.diff($x))
    assert_equal(CAS::Zero, $a.diff($a))
  end

  def test_inspect
    assert_equal("Const(1)", $a.inspect)
    assert_equal("Const(2)", $b.inspect)
    assert_equal("Const(3)", $c.inspect)

  end

  def test_typicalconst
    assert_equal($a, CAS::One)
    assert_equal(CAS::const(0), CAS::Zero)
    assert_equal(CAS::const(-1), CAS::MinusOne)
    assert_equal(CAS::const(Math::PI), CAS::Pi)
    assert_equal(CAS::const(Math::E), CAS::E)
  end

  def test_to_s
    assert_equal("1", $a.to_s)
    assert_equal("2", $b.to_s)
    assert_equal("3", $c.to_s)
  end
end

class TestSum < Test::Unit::TestCase
  def test_init
    assert_equal(CAS::const(3.0), ($a + $b).simplify)
    assert_equal(CAS::const(3.0), ($c + CAS::Zero).simplify)
    assert_equal(CAS::Variable.list[:x], (CAS::Zero + $x).simplify)
  end

  def test_subs
    s = {$x => CAS::One, $y => CAS::Two}
    assert_equal(CAS::One + CAS::Two, ($x + CAS::Two).subs(s))
    assert_equal(CAS::One + CAS::Two, (CAS::One + $y).subs(s))
  end

  def test_to_code
    assert_equal("(x + y)", ($x + $y).to_code)
  end

  def test_to_s
    assert_equal("(x + y)", "#{$x + $y}")
  end

  def test_diff
    assert_equal(CAS::One, ($x + $y).diff($x).simplify)
    assert_equal(CAS::One, ($x + $y).diff($y).simplify)

    assert_equal(CAS::One, ($x + CAS::Two).diff($x).simplify)
    assert_equal(CAS::One, (CAS::Two + $y).diff($y).simplify)

    assert_equal(CAS::Zero, ($x + $y).diff($z).simplify)
  end

end

class TestDiff < Test::Unit::TestCase
  def test_init
    assert_equal(CAS::const(2.0), ($c - $a).simplify)
    assert_equal(CAS::const(3.0), ($c - CAS::Zero).simplify)
    assert_equal(-CAS::Variable.list[:x], (CAS::Zero - $x).simplify)
  end

  def test_subs
    s = {$x => CAS::One, $y => CAS::Two}
    assert_equal(CAS::One - CAS::Two, ($x - CAS::Two).subs(s))
    assert_equal(CAS::One - CAS::Two, (CAS::One - $y).subs(s))
  end

  def test_to_code
    assert_equal("(x - y)", ($x - $y).to_code)
  end

  def test_to_s
    assert_equal("(x - y)", "#{$x - $y}")
  end

  def test_diff
    assert_equal(CAS::One, ($x - $y).diff($x).simplify)
    assert_equal(-CAS::One, ($x - $y).diff($y).simplify)

    assert_equal(CAS::One, ($x - CAS::Two).diff($x).simplify)
    assert_equal(-CAS::One, (CAS::Two - $y).diff($y).simplify)

    assert_equal(CAS::Zero, ($x - $y).diff($z).simplify)
  end
end

class TestProd < Test::Unit::TestCase
  def test_init
    assert_equal(CAS::const(2.0), ($b * $a).simplify)
    assert_equal(CAS::const(0.0), ($c * CAS::Zero).simplify)
    assert_equal(CAS::Variable.list[:x], (CAS::One * $x).simplify)
    assert_equal(CAS::Variable.list[:x], ($x * CAS::One).simplify)
  end

  def test_subs
    s = {$x => CAS::One, $y => CAS::Two}
    assert_equal(CAS::One * CAS::Two, ($x * CAS::Two).subs(s))
    assert_equal(CAS::One * CAS::Two, (CAS::One * $y).subs(s))
  end

  def test_to_code
    assert_equal("(x * y)", ($x * $y).to_code)
  end

  def test_to_s
    assert_equal("(x * y)", "#{$x * $y}")
  end

  def test_diff
    assert_equal($y, ($x * $y).diff($x).simplify)
    assert_equal($x, ($x * $y).diff($y).simplify)

    assert_equal(CAS::Two, ($x * CAS::Two).diff($x).simplify)
    assert_equal(CAS::Two, (CAS::Two * $y).diff($y).simplify)

    assert_equal(CAS::Zero, ($x - $y).diff($z).simplify)

    assert_equal(CAS::One, ($x * $y).diff($x).diff($y).simplify)
    assert_equal(CAS::One, ($x * $y).diff($y).diff($x).simplify)
  end
end

class TestDiv < Test::Unit::TestCase
  def test_init
    assert_equal(CAS::const(2.0), ($b / $a).simplify)
    assert_equal(CAS::const(0.0), (CAS::Zero / $c).simplify)
    assert_equal(CAS::Variable.list[:x], ($x / CAS::One).simplify)
  end

  def test_subs
    s = {$x => CAS::One, $y => CAS::Two}
    assert_equal(CAS::One / CAS::Two, ($x / CAS::Two).subs(s))
    assert_equal(CAS::One / CAS::Two, (CAS::One / $y).subs(s))
  end

  def test_to_code
    assert_equal("(x / y)", ($x / $y).to_code)
  end

  def test_to_s
    assert_equal("(x) / (y)", "#{$x / $y}")
  end

  def test_call
    s = {$x => 1.0, $y => 2.0}
    assert_equal(0.5, ($x / $y).call(s))
  end

  def test_diff
    assert_equal(CAS::One / $y, ($x / $y).diff($x).simplify)
    assert_equal($x, ($x * $y).diff($y).simplify)

    assert_equal(-(CAS::Two / ($y ** 2)), (CAS::Two / $y).diff($y).simplify)

    assert_equal(CAS::Zero, ($x - $y).diff($z).simplify)
  end
end

class SqrtTest < Test::Unit::TestCase
  def test_init
    assert_equal(CAS::const(1.0), (CAS::sqrt($a)).simplify)
  end

  def test_to_code
    assert_equal("Math::sqrt(x)", (CAS::sqrt($x)).to_code)
  end
end
