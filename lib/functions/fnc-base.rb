#!/usr/vin/env ruby

module CAS
  #  ___  _  __  __
  # |   \(_)/ _|/ _|
  # | |) | |  _|  _/
  # |___/|_|_| |_|

  ##
  # **Difference basic operation**. It's a binary operation. This cannot
  # be implemented as a n-ary op, thus will not be changed
  class Diff < CAS::BinaryOp
    # Performs the difference between two `CAS::Op`s
    #
    # ```
    #   d
    # ---- (f(x) - g(x)) = f'(x) - g'(x)
    #  dx
    # ```
    #
    #  * **argument**: `CAS::Op` argument of derivative
    #  * **returns**: `CAS::Op` derivative
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
    #
    # Simplifcation engine supports:
    #
    #  * 0 - y = -y
    #  * x - 0 = x
    #  * a - b = c (constants reduction)
    #  * x - x = 0
    #  * x - (-y) = x + y
    #
    #  * **returns**: `CAS::Op` simplified version
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

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "(#{@x.to_code} - #{@y.to_code})"
    end
  end # Difference
  CAS::Diff.init_simplify_dict

  #  ___
  # | _ \_____ __ __
  # |  _/ _ \ V  V /
  # |_| \___/\_/\_/

  ##
  # Power function.
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
    #
    #  * **argument**: `CAS::Op` argument of derivative
    #  * **returns**: `CAS::Op` derivative
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

    # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
    # or `Float` (depends upon promotions).
    # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
    # as keys, and a `Numeric` as a value. In this case it will call
    # the `Fixnum#overloaded_plus`, that is the old plus function.
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Numeric`
    def call(f)
      CAS::Help.assert(f, Hash)
      @x.call(f).overloaded_pow(@y.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "(#{@x})^(#{@y})"
    end

    # Same as `CAS::Op`
    #
    # Simplifcation engine supports:
    #
    #  * 0 ^ y = 0
    #  * x ^ 0 = 1
    #  * a ^ b = c (constants reduction)
    #  * x ^ 1 = x
    #  * 1 ^ y = 1
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return self if (@x == CAS::Zero and @y == CAS::Zero)
      return self if (@x == CAS::Infinity and @y == CAS::Infinity)
      return self if (@x == CAS::Infinity and @y == CAS::Zero)
      return self if (@x == CAS::Zero and @y == CAS::Infinity)

      return CAS::Zero if @x == CAS::Zero
      return CAS::One if @x == CAS::One
      return @x if @y == CAS::One
      return CAS::One if @y == CAS::Zero
      return CAS.const(self.call({})) if (@x.is_a? CAS::Constant and @y.is_a? CAS::Constant)
      return self
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "(#{@x.to_code} ** #{@y.to_code})"
    end
  end # Pow
  CAS::Pow.init_simplify_dict

  # Shortcut for `CAS::Pow` initializer
  #
  #  * **argument**: `CAS::Op` base
  #  * **argument**: `CAS::Op` exponent
  #  * **returns**: `CAS::Pow` new instance
  def self.pow(x, y)
    CAS::Pow.new x, y
  end

  #  ___  _
  # |   \(_)_ __
  # | |) | \ V /
  # |___/|_|\_/

  ##
  # Division between two functions. A function divided by zero it is considered
  # as an Infinity.
  class Div < CAS::BinaryOp
    # Performs the division between two `CAS::Op`
    #
    # ```
    #   d
    # ---- (f(x) / g(x)) = (f'(x) * g(x) - f(x) * g'(x))/(g(x)^2)
    #  dx
    # ```
    #
    #  * **argument**: `CAS::Op` argument of derivative
    #  * **returns**: `CAS::Op` derivative
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

    # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
    # or `Float` (depends upon promotions).
    # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
    # as keys, and a `Numeric` as a value. In this case it will call
    # the `Fixnum#overloaded_plus`, that is the old plus function.
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Numeric`
    def call(f)
      CAS::Help.assert(f, Hash)

      @x.call(f).overloaded_div(@y.call(f))
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "(#{@x}) / (#{@y})"
    end

    # Same as `CAS::Op`
    #
    # Simplifcation engine supports:
    #
    #  * 0 / y = 0
    #  * x / 0 = Inf
    #  * x / 1 = x
    #  * x / Inf = 0
    #  * a / b = c (constants reduction)
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return self if (@x == CAS::Zero and @y == CAS::Zero)
      return self if (@x == CAS::Infinity and @y == CAS::Infinity)
      return self if (@x == CAS::Infinity and @y == CAS::Zero)
      return self if (@x == CAS::Zero and @y == CAS::Infinity)

      return CAS::Zero if @x == CAS::Zero
      return CAS::Infinity if @y == CAS::Zero
      return @x if @y == CAS::One
      return CAS::Zero if @y == CAS::Infinity
      return CAS::One if @x == @y
      return CAS.const(self.call({})) if (@x.is_a? CAS::Constant and @y.is_a? CAS::Constant)
      return self
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "(#{@x.to_code} / #{@y.to_code})"
    end
  end # Div
  CAS::Div.init_simplify_dict

  #  ___           _
  # / __| __ _ _ _| |_
  # \__ \/ _` | '_|  _|
  # |___/\__, |_|  \__|
  #         |_|

  ##
  # Square Root of a function. Even if it can be implemented as a power function,
  # it is a separated class.
  class Sqrt < CAS::Op
    # Performs the square root between two `CAS::Op`
    #
    # ```
    #   d
    # ---- √f(x) = 1/2 * f'(x) * √f(x)
    #  dx
    # ```
    #
    #  * **argument**: `CAS::Op` argument of derivative
    #  * **returns**: `CAS::Op` derivative
    def diff(v)
      if @x.depend? v
        return (@x.diff(v) / (CAS.const(2.0) * CAS.sqrt(@x)))
      else
        return CAS::Zero
      end
    end

    # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
    # or `Float` (depends upon promotions).
    # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
    # as keys, and a `Numeric` as a value. In this case it will call
    # the `Fixnum#overloaded_plus`, that is the old plus function.
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Numeric`
    def call(f)
      CAS::Help.assert(f, Hash)

      Math::sqrt @x.call(f)
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "√(#{@x})"
    end

    # Same as `CAS::Op`
    #
    # Simplifcation engine supports:
    #
    #  * √(x^z) = x^(z - 1/2)
    #  * √x = 0
    #  * √x = 1
    #  * √a = b (constants reduction)
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return (CAS.pow(@x.x, @x.y - 0.5)).simplify if @x.is_a? CAS::Pow
      return CAS::Zero if @x == CAS::Zero
      return CAS::One if @x == CAS::One
      return CAS.const(self.call({})) if (@x.is_a? CAS::Constant and @y.is_a? CAS::Constant)
      return self
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "Math::sqrt(#{@x.to_code})"
    end
  end # Sqrt
  CAS::Sqrt.init_simplify_dict

  # Shortcut for `CAS::Sqrt` initializer
  #
  #  * **argument**: `CAS::Op` argument of square root
  #  * **returns**: `CAS::Sqrt` new instance
  def self.sqrt(x)
    CAS::Sqrt.new x
  end

  #  ___                 _
  # |_ _|_ ___ _____ _ _| |_
  #  | || ' \ V / -_) '_|  _|
  # |___|_||_\_/\___|_|  \__|

  ##
  # Invert is the same as multiply by `-1` a function.
  # `Invert(x)` is equal to `-x`
  class Invert < CAS::Op
    # Performs the inversion of a `CAS::Op`
    #
    # ```
    #   d
    # ---- (-f(x)) = -f'(x)
    #  dx
    # ```
    #
    #  * **argument**: `CAS::Op` argument of derivative
    #  * **returns**: `CAS::Op` derivative
    def diff(v)
      if @x.depend? v
        -@x.diff(v)
      else
        CAS::Zero
      end
    end

    # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
    # or `Float` (depends upon promotions).
    # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
    # as keys, and a `Numeric` as a value. In this case it will call
    # the `Fixnum#overloaded_plus`, that is the old plus function.
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Numeric`
    def call(f)
      CAS::Help.assert(f, Hash)

      -1.0 * @x.call(f)
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "-#{@x}"
    end

    # Same as `CAS::Op`
    #
    # Simplifcation engine supports:
    #
    #  * -(-x) = x
    #  * -0 = 0
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x.x if @x.is_a? CAS::Invert
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => CAS::Zero
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "(-#{@x.to_code})"
    end
  end # Invert
  CAS::Invert.init_simplify_dict

  # Shortcut for `CAs::Invert` initializer
  #
  #  * **argument**: `CAs::Op` argument of the inversion
  #  * **returns**: `CAS::Invert` new instance
  def self.invert(x)
    CAS::Invert.new x
  end

  #    _   _
  #   /_\ | |__ ___
  #  / _ \| '_ (_-<
  # /_/ \_\_.__/__/

  ##
  # Absolute value of a function. It can be also implemented as a Piecewise function.
  class Abs < CAS::Op
    # Performs the absolute value of a `CAS::Op`
    #
    # ```
    #   d
    # ---- |f(x)| = f'(x) * (f(x) / |f(x)|)
    #  dx
    # ```
    #
    #  * **argument**: `CAS::Op` argument of derivative
    #  * **returns**: `CAS::Op` derivative
    def diff(v)
      if @x.depend? v
        return @x.diff(v) * (@x/CAS.abs(@x))
      else
        return CAS::Zero
      end
    end

    # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
    # or `Float` (depends upon promotions).
    # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
    # as keys, and a `Numeric` as a value. In this case it will call
    # the `Fixnum#overloaded_plus`, that is the old plus function.
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Numeric`
    def call(f)
      CAS::Help.assert(f, Hash)

      s = (@x.call(f) >= 0 ? 1 : -1)
      return s * @x.call(f)
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "|#{@x}|"
    end

    # Same as `CAS::Op`
    #
    # Simplifcation engine supports:
    #
    #  * |-x| = x
    #  * |0| = 0
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return CAS.abs(@x.x) if @x.is_a? CAS::Invert
      return self.simplify_dictionary
    end

    def self.init_simplify_dict
      @simplify_dict = {
        CAS::Zero => CAS::Zero
      }
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "(#{@x.to_code}).abs"
    end
  end # Abs
  CAS::Abs.init_simplify_dict

  # Shortcut for `CAs::Abs` initializer
  #
  #  * **argument**: `CAs::Op` argument of absolute value
  #  * **returns**: `CAS::Abs` new instance
  def self.abs(x)
    CAS::Abs.new x
  end
end
