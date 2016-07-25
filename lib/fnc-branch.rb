#!/usr/bin/env ruby

module CAS
  class Piecewise < CAS::BinaryOp
    attr_reader :condition

    def initialize(x, y, condition)
      CAS::Help.assert(condition, CAS::Condition)

      super(x, y)
      @condition = condition
    end

    def diff(v)
      CAS::Help.assert(v, CAS::Op)

      return CAS::Piecewise.new(@x.diff(v).simplify, @y.diff(v).simplify, condition)
    end

    def call(fd)
      CAS::Help.assert(fd, Hash)

      (@condition.call(fd) ? @x.call(fd) : @y.call(fd))
    end

    def ==(op)
      CAS::Help.assert(op, CAS::Op)

      if self.class != op.class
        return false
      else
        return ((@x == op.x) and (@y == op.y) and (@condition == op.condition))
      end
    end

    def to_code
      "(#{@condition.to_code} ? (#{@x.to_code}) : (#{@y.to_code}))"
    end

    def to_s
      "(#{@condition} ? #{@x} : #{@y})"
    end

    def dot_graph(node)
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph node}\n  #{cls} -> #{@y.dot_graph node}\n  #{cls} -> #{@condition.dot_graph node}"
    end
  end


  def self.max(x, y)
    CAS::Piecewise.new(x, y, CAS::greater_equal(x, y))
  end

  def self.min(x, y)
    CAS::Piecewise.new(x, y, CAS::smaller_equal(x, y))
  end

  class Condition
    attr_reader :x, :y, :type

    def initialize(type, x, y)
      CAS::Help.assert(type, Symbol)

      @x = x
      @y = y
      case type
      when :eq
        @type = "=="
        self.define_singleton_method("call") do |fd|
          @x.call(fd) == @y.call(fd)
        end
      when :gt
        @type = ">"
        self.define_singleton_method("call") do |fd|
          @x.call(fd) > @y.call(fd)
        end
      when :lt
        @type = "<"
        self.define_singleton_method("call") do |fd|
          @x.call(fd) < @y.call(fd)
        end
      when :geq
        @type = "≥"
        self.define_singleton_method("call") do |fd|
          @x.call(fd) >= @y.call(fd)
        end
      when :leq
        @type = "≤"
        self.define_singleton_method("call") do |fd|
          @x.call(fd) <= @y.call(fd)
        end
      else
        raise CASError, "Unknown condition #{@type}"
      end
    end

    def inspect
      "#{@x.inspect} #{@type} #{@y.inspect}"
    end

    def to_s
      "#{@x} #{@type} #{@y}"
    end

    def to_code
      "#{@x}.call(fd) #{@type} #{@y}.call(fd)"
    end

    def args
      (@x.args + @y.args).uniq
    end

    def diff(v)
      @x.diff(v)
      @y.diff(v)
      self.simplify
    end

    def depend?(v)
      @x.depend?(v) or @y.depend?(v)
    end

    def ==(op)
      CAS::Help.assert(op, CAS::Op)
      condA = (@x == op.x) and (@y == op.y)
      condB = (@x == op.y) and (@y == op.x)
      condC = condA or condB
      return (condC and (self.class == op.class) and (@type == op.type))
    end

    def !=(op)
      not self == op
    end

    def simplify
      @x.simplify
      @y.simplify
      return self
    end

    def subs(fd)
      CAS::Help.assert(fd, Hash)
      @x.subs(fd)
      @y.subs(fd)
      return self
    end

    def dot_graph(node)
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph node}\n  #{cls} -> #{@y.dot_graph node}"
    end
  end

  class Equal < CAS::Condition
    def initialize(x, y)
      super(:eq, x, y)
    end
  end

  class Greater < CAS::Condition
    def initialize(x, y)
      super(:gt, x, y)
    end
  end

  class GreaterEqual < CAS::Condition
    def initialize(x, y)
      super(:geq, x, y)
    end
  end

  class Smaller < CAS::Condition
    def initialize(x, y)
      super(:lt, x, y)
    end
  end

  class SmallerEqual < CAS::Condition
    def initialize(x, y)
      super(:leq, x, y)
    end
  end

  def self.equal(x, y); CAS::Equal.new(x, y); end
  def self.greater(x, y); CAS::Greater.new(x, y); end
  def self.greater_equal(x, y); CAS::GreaterEqual.new(x, y); end
  def self.smaller(x, y); CAS::Smaller.new(x, y); end
  def self.smaller_equal(x, y); CAS::SmallerEqual.new(x, y); end

  class Op
    def equal(v); CAS.equal(self, v); end
    def greater(v); CAS.greater(self, v); end
    def smaller(v); CAS.smaller(self, v); end
    def greater_equal(v); CAS.greater_equal(self, v); end
    def smaller_equal(v); CAS.smaller_equal(self, v); end
  end
end
