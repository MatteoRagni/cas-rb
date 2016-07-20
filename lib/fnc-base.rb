#!/usr/vin/env ruby

module CAS
  #  ___
  # / __|_  _ _ __
  # \__ \ || | '  \
  # |___/\_,_|_|_|_|
  class Sum < CAS::BinaryOp
    def diff(v)
      left, right = super v
      return left if (right == nil or right == CAS::Zero)
      return right if (left == nil or left == CAS::Zero)
      left + right
    end

    def call(f)
      return @x.call(f) + @y.call(f)
    end

    def to_s
      "(#{@x} + #{@y})"
    end

    def simplify
      super
      if @x == CAS::Zero
        return @y
      end
      if @y == CAS::Zero
        return @x
      end
      if @x == @y
        return @x * 2.0
      end
      if @x.is_a? CAS::Constant and @y.is_a? CAS::Constant
        return CAS.const(self.call({}))
      end
      return self
    end

    def to_code
      "(#{@x.to_code} + #{@y.to_code})"
    end
  end # Sum

  #  ___  _  __  __
  # |   \(_)/ _|/ _|
  # | |) | |  _|  _/
  # |___/|_|_| |_|
  class Diff < CAS::BinaryOp
    def diff(v)
      left, right = super v
      return left if (right == nil or right == CAS::Zero)
      return CAS::Invert.new(right) if (left == nil or left == CAS::Zero)
      left - right
    end

    def call(f)
      return @x.call(f) - @y.call(f)
    end

    def to_s
      "(#{@x} - #{@y})"
    end

    def simplify
      super
      if @x == CAS::Zero
        return CAS.invert(@y)
      end
      if @y == CAS::Zero
        return @x
      end
      if @x == @y
        return CAS::Zero
      end
      if @x.is_a? CAS::Constant and @y.is_a? CAS::Constant
        return CAS.const(self.call({}))
      end
      return self
    end

    def to_code
      "(#{@x.to_code} - #{@y.to_code})"
    end
  end # Difference

  #  ___             _
  # | _ \_ _ ___  __| |
  # |  _/ '_/ _ \/ _` |
  # |_| |_| \___/\__,_|
  class Prod < CAS::BinaryOp
    def diff(v)
      left, right = super v
      return left * @y if (right == nil or right == CAS::Zero)
      return right * @x if (left == nil or left == CAS::Zero)
      (left * @y) + (right * @x)
    end

    def call(f)
      return @x.call(f) * @y.call(f)
    end

    def to_s
      "(#{@x} * #{@y})"
    end

    def simplify
      super
      if @x == CAS::Zero or @y == CAS::Zero
        return CAS::Zero
      end
      if @x == CAS::One
        return @y
      end
      if @y == CAS::One
        return @x
      end
      if @x == @y
        return @x ** 2.0
      end
      if @x.is_a? CAS::Constant and @y.is_a? CAS::Constant
        return CAS.const(self.call({}))
      end
      return self
    end

    def to_code
      "(#{@x.to_code} * #{@y.to_code})"
    end
  end # Prod

  #  ___
  # | _ \_____ __ __
  # |  _/ _ \ V  V /
  # |_| \___/\_/\_/
  class Pow < CAS::BinaryOp
    def diff(v)
      diff_x, diff_y = super v
      if diff_y == nil or diff_y == CAS::Zero
        return ((@x ** (@y - 1.0)) * @y * diff_x)
      elsif diff_x == nil or diff_x == CAS::Zero
        return (@x ** @y) * diff_y * CAS.ln(@x)
      else
        return (@x ** @y) * ((diff_y * CAS.ln(@x)) + (@y * diff_x / @x))
      end
    end

    def call(f)
      @x.call(f) ** @y.call(f)
    end

    def to_s
      "#{@x}^#{@y}"
    end

    def simplify
      super
      if @x == CAS::Zero
        return CAS::Zero
      end
      if @x == CAS::One
        return CAS::One
      end
      if @y == CAS::One
        return @x
      end
      if @y == CAS::Zero
        return CAS::One
      end
      if @x.is_a? CAS::Constant and @y.is_a? CAS::Constant
        return CAS.const(self.call({}))
      end
      return self
    end

    def to_code
      "(#{@x.to_code} ** #{@y.to_code})"
    end
  end

  def self.pow(x, y)
    CAS::Pow.new x, y
  end

  #  ___  _
  # |   \(_)_ __
  # | |) | \ V /
  # |___/|_|\_/
  class Div < CAS::BinaryOp
    def diff(v)
      diff_x, diff_y = super v
      if diff_y == nil or diff_y == CAS::Zero
        return (diff_x/@y)
      elsif diff_x == nil or diff_x == CAS::Zero
        return CAS.invert(@x * diff_y / CAS.pow(@y, CAS.const(2.0)))
      else
        return ((diff_x * @y) - (diff_y * @x))/CAS.pow(@y, CAS.const(2.0))
      end
    end

    def call(f)
      @x.call(f)/@y.call(f)
    end

    def to_s
      "(#{@x}) / (#{@y})"
    end

    def simplify
      super
      if @x == CAS::Zero
        return CAS::Zero
      end
      if @y == CAS::Zero
        return CAS::Infinity
      end
      if @y == CAS::One
        return @x
      end
      if @y == CAS::Infinity
        return CAS::Zero
      end
      if @x.is_a? CAS::Constant and @y.is_a? CAS::Constant
        return CAS.const(self.call({}))
      end
      return self
    end

    def to_code
      "(#{@x.to_code} / #{@y.to_code})"
    end
  end # Div

  #  ___           _
  # / __| __ _ _ _| |_
  # \__ \/ _` | '_|  _|
  # |___/\__, |_|  \__|
  #         |_|
  class Sqrt < CAS::Op
    def diff(v)
      if @x.depend? v
        return (@x.diff(v) / (CAS.const(2.0) * CAS.sqrt(@x)))
      else
        return CAS::Zero
      end
    end

    def call(f)
      Math::sqrt @x.call(f)
    end

    def to_s
      "√(#{@x})"
    end

    def simplify
      super
      if @x.is_a? CAS::Pow
        return CAS.pow(@x.x, @y - 0.5)
      end
      if @x == CAS::Zero
        return CAS::Zero
      end
      if @x == CAS::One
        return CAS::One
      end
      if @x.is_a? CAS::Constant and @y.is_a? CAS::Constant
        return CAS.const(self.call({}))
      end
      return self
    end

    def to_code
      "Math::sqrt(#{@x.to_code})"
    end
  end # Sqrt

  def self.sqrt(x)
    CAS::Sqrt.new x
  end

  #  ___                 _
  # |_ _|_ ___ _____ _ _| |_
  #  | || ' \ V / -_) '_|  _|
  # |___|_||_\_/\___|_|  \__|
  class Invert < CAS::Op
    def diff(v)
      if @x.depend? v
        CAS::const(-1.0) * @x.diff
      else
        CAS::Zero
      end
    end

    def call(f)
      -1.0 * @x.call(f)
    end

    def to_s
      "-#{@x}"
    end

    def simplify
      super
      if @x == CAS::Zero
        return CAS::Zero
      end
      if @x.is_a? CAS::Invert
        return @x.x
      end
      return self
    end

    def to_code
      "(-#{@x.to_code})"
    end
  end

  def self.invert(x)
    CAS::Invert.new x
  end

  #    _   _
  #   /_\ | |__ ___
  #  / _ \| '_ (_-<
  # /_/ \_\_.__/__/
  class Abs < CAS::Op
    def diff(v)
      if @x.depend? v
        return @x.diff * (@x/CAS.abs(@x))
      else
        return CAS::Zero
      end
    end

    def call(f)
      s = (@x.call(f) >= 0 ? 1 : -1)
      return s * @x.call(f)
    end

    def to_s
      "|#{@x}|"
    end

    def simplify
      super
      if @x == CAS::Zero
        return CAS::Zero
      end
      if @x.is_a? CAS::Invert
        return CAS.abs(@x.x)
      end
      return self
    end

    def to_code
      "(#{@x.to_code}).abs"
    end
  end

  def self.abs(x)
    CAS::Abs.new x
  end
end
