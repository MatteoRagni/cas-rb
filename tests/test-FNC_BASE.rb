#!/usr/bin/env ruby

require 'test/unit'

require_relative '../lib/ragni-cas.rb'

$x, $y, $z = CAS::vars :x, :y, :z
$a, $b, $c = CAS::const 1, 2, 3

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
