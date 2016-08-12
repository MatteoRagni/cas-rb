#!/usr/vin/env ruby

module CAS
  #  ___
  # / __|_  _ _ __
  # \__ \ || | '  \
  # |___/\_,_|_|_|_|
  #

  ##
  # **Sum basic operation**. As for now it is implemented as a simple
  # binary operation. It will be implemented as n-ary op.
  class Sum < CAS::BinaryOp
    # Performs the sum between two `CAS::Op`
    #
    # ```
    #   d
    # ---- (f(x) + g(x)) = f'(x) + g'(x)
    #  dx
    # ```
    def diff(v)
      left, right = super v

      return left if right == CAS::Zero
      return right if left == CAS::Zero
      left + right
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)
      return @x.call(f).overloaded_plus(@y.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "(#{@x} + #{@y})"
    end

    # Same as `CAS::Op`
    #
    # Simplifcation engine supports:
    #
    # * x + 0 = x
    # * 0 + y = y
    # * x + x = 2 x
    # * x + (-x) = 0
    # * x + (-y) = x - y
    # * 1 + 2 = 3 (constants reduction)
    def simplify
      super
      return @y if @x == CAS::Zero
      return @x if @y == CAS::Zero
      return @x * 2.0 if @x == @y
      return CAS::Zero if @x == -@y or -@x == @y
      return (@x - @y.x) if @y.is_a? CAS::Invert
      return CAS.const(self.call({})) if (@x.is_a? CAS::Constant and @y.is_a? CAS::Constant)
      return self
    end

    # Same as `CAS::Op`
    def to_code
      "(#{@x.to_code} + #{@y.to_code})"
    end

    # Returns a latex represenntation of the current Op
    def to_latex
      "\\left(#{@x.to_latex} + #{@y.to_latex}\\right)"
    end
  end # Sum

  #  ___  _  __  __
  # |   \(_)/ _|/ _|
  # | |) | |  _|  _/
  # |___/|_|_| |_|

  ##
  # Diff basic operation. It's a binary operation
  class Diff < CAS::BinaryOp
    # Performs the difference between two `CAS::Op`s
    #
    # ```
    #   d
    # ---- (f(x) - g(x)) = f'(x) - g'(x)
    #  dx
    # ```
    def diff(v)
      left, right = super v
      return left if right == CAS::Zero
      return CAS::Invert.new(right) if left == CAS::Zero
      left - right
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)

      return @x.call(f).overloaded_minus(@y.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "(#{@x} - #{@y})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return CAS.invert(@y) if @x == CAS::Zero
      return @x if @y == CAS::Zero
      return CAS::Zero if @x == @y
      return CAS.const(self.call({})) if (@x.is_a? CAS::Constant and @y.is_a? CAS::Constant)
      return @x + @y.x if @y.is_a? CAS::Invert
      return -(@x.x + @y) if @x.is_a? CAS::Invert
      return self
    end

    # Same as `CAS::Op`
    def to_code
      "(#{@x.to_code} - #{@y.to_code})"
    end

    # Returns a latex representation of the current Op
    def to_latex
      "\\left(#{@x.to_latex} - #{@y.to_latex}\\right)"
    end
  end # Difference

  #  ___             _
  # | _ \_ _ ___  __| |
  # |  _/ '_/ _ \/ _` |
  # |_| |_| \___/\__,_|

  ##
  # Product class. Performs the product between two elements.
  # This class will be soon modified as an n-ary operator.
  class Prod < CAS::BinaryOp
    # Performs the product between two `CAS::Op`
    #
    # ```
    #   d
    # ---- (f(x) * g(x)) = f'(x) * g(x) + f(x) * g'(x)
    #  dx
    # ```
    def diff(v)
      left, right = super v
      return left * @y if right == CAS::Zero
      return right * @x if left == CAS::Zero
      (left * @y) + (right * @x)
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)

      return @x.call(f).overloaded_mul(@y.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "(#{@x} * #{@y})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return CAS::Zero if @x == CAS::Zero or @y == CAS::Zero
      return @y if @x == CAS::One
      return @x if @y == CAS::One
      return @x ** 2.0 if @x == @y
      return CAS.const(self.call({})) if @x.is_a? CAS::Constant and @y.is_a? CAS::Constant
      return self
    end

    # Same as `CAS::Op`
    def to_code
      "(#{@x.to_code} * #{@y.to_code})"
    end

    # Returns a latex represstation of the Op
    def to_latex
      "#{@x.to_latex}\\,#{@y.to_latex}"
    end
  end # Prod

  # ```
  #  ___
  # | _ \_____ __ __
  # |  _/ _ \ V  V /
  # |_| \___/\_/\_/
  # ```
  class Pow < CAS::BinaryOp
    # Performs the power between two `CAS::Op`
    #
    # ```
    #   d
    # ---- (f(x)^a) = f(x)^(a - 1) * a * f'(x)
    #  dx
    #
    #   d
    # ---- (a^f(x)) = a^f(x) * f'(x) * ln a
    #  dx
    #
    #   d
    # ---- (f(x)^g(x)) = (f(x)^g(x)) * (g'(x) * ln f(x) + g(x) * f'(x) / f(x))
    #  dx
    # ```
    def diff(v)
      diff_x, diff_y = super v
      if diff_y == CAS::Zero
        return ((@x ** (@y - 1.0)) * @y * diff_x)
      elsif diff_x == CAS::Zero
        return (@x ** @y) * diff_y * CAS.ln(@x)
      else
        return (@x ** @y) * ((diff_y * CAS.ln(@x)) + (@y * diff_x / @x))
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)
      @x.call(f).overloaded_pow(@y.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "(#{@x})^(#{@y})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return CAS::Zero if @x == CAS::Zero
      return CAS::One if @x == CAS::One
      return @x if @y == CAS::One
      return CAS::One if @y == CAS::Zero
      return CAS.const(self.call({})) if (@x.is_a? CAS::Constant and @y.is_a? CAS::Constant)
      return self
    end

    # Same as `CAS::Op`
    def to_code
      "(#{@x.to_code} ** #{@y.to_code})"
    end

    # Returns the latex representation of the op
    def to_latex
      "{#{@x.to_latex}}^{#{@y.to_latex}}"
    end
  end

  def self.pow(x, y)
    CAS::Pow.new x, y
  end

  # ```
  #  ___  _
  # |   \(_)_ __
  # | |) | \ V /
  # |___/|_|\_/
  # ```
  class Div < CAS::BinaryOp
    # Performs the division between two `CAS::Op`
    #
    # ```
    #   d
    # ---- (f(x) / g(x)) = (f'(x) * g(x) - f(x) * g'(x))/(g(x)^2)
    #  dx
    # ```
    def diff(v)
      diff_x, diff_y = super v
      if diff_y == CAS::Zero
        return (diff_x/@y)
      elsif diff_x == CAS::Zero
        return CAS.invert(@x * diff_y / CAS.pow(@y, CAS.const(2.0)))
      else
        return ((diff_x * @y) - (diff_y * @x))/CAS.pow(@y, CAS.const(2.0))
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)

      @x.call(f).overloaded_div(@y.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "(#{@x}) / (#{@y})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return CAS::Zero if @x == CAS::Zero
      return CAS::Infinity if @y == CAS::Zero
      return @x if @y == CAS::One
      return CAS::Zero if @y == CAS::Infinity
      return CAS.const(self.call({})) if (@x.is_a? CAS::Constant and @y.is_a? CAS::Constant)
      return self
    end

    # Same as `CAS::Op`
    def to_code
      "(#{@x.to_code} / #{@y.to_code})"
    end

    # Returns the latex reppresentation of the current Op
    def to_latex
      "\\dfrac{#{@x.to_latex}}{#{@y.to_latex}}"
    end
  end # Div

  #  ___           _
  # / __| __ _ _ _| |_
  # \__ \/ _` | '_|  _|
  # |___/\__, |_|  \__|
  #         |_|
  class Sqrt < CAS::Op
    # Performs the square root between two `CAS::Op`
    #
    # ```
    #   d
    # ---- √f(x) = 1/2 * f'(x) * √f(x)
    #  dx
    # ```
    def diff(v)
      if @x.depend? v
        return (@x.diff(v) / (CAS.const(2.0) * CAS.sqrt(@x)))
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)

      Math::sqrt @x.call(f)
    end

    # Same as `CAS::Op`
    def to_s
      "√(#{@x})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return CAS.pow(@x.x, @y - 0.5) if @x.is_a? CAS::Pow
      return CAS::Zero if @x == CAS::Zero
      return CAS::One if @x == CAS::One
      return CAS.const(self.call({})) if (@x.is_a? CAS::Constant and @y.is_a? CAS::Constant)
      return self
    end

    # Same as `CAS::Op`
    def to_code
      "Math::sqrt(#{@x.to_code})"
    end

    # Returns the latex representation of the current Op
    def to_latex
      "\\sqrt{#{@x.to_latex}}"
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
    # Performs the inversion of a `CAS::Op`
    #
    # ```
    #   d
    # ---- (-f(x)) = -f'(x)
    #  dx
    # ```
    def diff(v)
      if @x.depend? v
        CAS::const(-1.0) * @x.diff(v)
      else
        CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)

      -1.0 * @x.call(f)
    end

    # Same as `CAS::Op`
    def to_s
      "-#{@x}"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return @x.x if @x.is_a? CAS::Invert
      return self.simplify_dictionary
    end
    @@simplify_dict = {
      CAS::Zero => CAS::Zero
    }

    # Same as `CAS::Op`
    def to_code
      "(-#{@x.to_code})"
    end

    # Returns the latex representation of the current op
    def to_latex
      "-{#{@x.to_latex}}"
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
    # Performs the absolute value of a `CAS::Op`
    #
    # ```
    #   d
    # ---- |f(x)| = f'(x) * (f(x) / |f(x)|)
    #  dx
    # ```
    def diff(v)
      if @x.depend? v
        return @x.diff(x) * (@x/CAS.abs(@x))
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)

      s = (@x.call(f) >= 0 ? 1 : -1)
      return s * @x.call(f)
    end

    # Same as `CAS::Op`
    def to_s
      "|#{@x}|"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return CAS.abs(@x.x) if @x.is_a? CAS::Invert
      return self.simplify_dictionary
    end
    @@simplify_dict = {
      CAS::Zero => CAS::Zero
    }

    # Same as `CAS::Op`
    def to_code
      "(#{@x.to_code}).abs"
    end

    # Returns the latex representation of the current Op
    def to_latex
      "\\left|#{@x.to_latex}\\right|"
    end
  end

  def self.abs(x)
    CAS::Abs.new x
  end
end
