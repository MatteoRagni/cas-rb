#!/usr/bin/env ruby

require 'test/unit'
require_relative '../lib/Mr.CAS.rb'

class TestVariable < Test::Unit::TestCase
  def setup
    @x = CAS::Variable.new :x
  end

  def test_init
    assert_equal(CAS::Variable, @x.class)
    assert_equal(@x, CAS::Variable.new(:x))
  end

  def test_diff
    assert_equal(CAS::One, @x.diff(@x))
  end

  def test_inspect
    assert_equal("Var(x)", @x.inspect)
  end

  def test_exist?
    assert_equal(true, CAS::Variable.exist?(:x))
    assert_equal(false, CAS::Variable.exist?(:bho))
  end

  def text_list
    assert_equal({:x => @x}, CAS::Variable.list)
    assert_equal(1, CAS::Variable.size)
  end

  def test_to_s
    assert_equal("x", @x.to_s)
  end

  def test_call
    assert_equal(1.0, @x.call({:x => 1.0}))
    assert_equal(1.0, @x.call({@x => 1.0}))
  end

  def test_simplify
    assert_equal(@x, @x.simplify)
  end

  def test_vars
    a = CAS::vars :a, :b, :c
    a.each do |e|
      assert_equal e.class, CAS::Variable
    end
  end
end
