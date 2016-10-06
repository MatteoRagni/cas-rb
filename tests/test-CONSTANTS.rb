#!/usr/bin/env ruby

require 'test/unit'
require_relative '../lib/ragni-cas.rb'

# Testing lib/numbers/constants.rb
class TestConstant < Test::Unit::TestCase
  # Preparing tested variables
  def setup
    @ia, @ib, @ic = CAS::const 1, 2, 3
    @fa, @fb, @fc = CAS::const 1.0, 2.0, 3.0

    @x = CAS::Variable[:x]
  end

  # Test initialization
  def test_new
    assert_instance_of CAS::Constant, @ia, "Wrong initialization of a Fixnum constant"
    assert_instance_of CAS::Constant, @fa, "Wrong initialization of a Float constant"

    assert_equal @ia.class, @fa.class, "Constant Fixnum class different from Float Constant class"

    CAS::NumericToConst.each { |k, v|
      assert_equal(CAS::const(k), v, "Initializer #{k} does not return #{v}")
    }
  end

  # Test == method
  def test_equal
    assert_equal @ic, @fc, "Fixnum Constant and Float Constant are not equal"
  end

  # Test args method
  def test_args
    assert_equal @ic.args, [], "args does not return empty Array"
  end

  # Test call method
  def test_call
    assert_equal @ic.call({@x => 1.0}), @ic.x, "call method does not return the constant's value"
  end

  # Test depend method
  def test_depend
    assert not(@ic.depend?(@x)), "Constant depends upon a variable"
  end

  # Test duff method
  def test_diff
    assert_equal CAS::Zero, @fc.diff(@x), "Diff of a constant is not zero"
  end

  # Testing inspect method
  def test_inspect
    assert_equal("Const(1)", @ia.inspect, "Inspect not coherent")
  end

  # Testing simplify method
  def test_simplify
    assert_equal CAS::Infinity, CAS::Infinity.simplify, "Simplification not coherent"
  end

  # Testing substitution method
  def test_subs
    assert_equal @ia.subs({@x => CAS::Pi}), @ia, "Substitution on constant using variable"
    assert_equal @ia.subs({@ia => CAS::Pi}), @ia, "Substitution on constant using constant"
  end

  # Testing to_s method
  def test_to_s
    assert_equal "1", @ia.to_s, "String does not match"
  end
end
