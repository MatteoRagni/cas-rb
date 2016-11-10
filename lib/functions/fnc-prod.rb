#!/usr/bin/env ruby

module CAS

  #  ___             _
  # | _ \_ _ ___  __| |
  # |  _/ '_/ _ \/ _` |
  # |_| |_| \___/\__,_|

  ##
  # Product class. Performs the product between two elements.
  # This class will be soon modified as an n-ary operator.
  class Prod < CAS::NaryOp
    # The new element of a sum accumulates inside the
    # vector that holds the elements
    def *(op)
      CAS::Help.assert(op, CAS::Op)
      @x << op
      self
    end

    # Performs the product between two `CAS::Op`
    #
    # ```
    #   d
    # ---- (f(x) * g(x) * h(x)) = f'(x) * g(x) * h(x) +
    #  dx
    #                           + f(x) * g'(x) * h(x) +
    #
    #                           + f(x) * g(x) * h'(x)
    # ```
    #
    #  * **argument**: `CAS::Op` argument of derivative
    #  * **returns**: `CAS::Op` derivative
    def diff(v)
      xdiff = @x.map { |y| y.diff(v) }

      xdiff.each_with_index { |y, i|
        xdiff[i] = y * CAS::Prod.new(@x[0...i] + @x[(i + 1)..-1])
      }

      return CAS::Sum.new(xdiff)
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

      return @x.inject { |p, y| p = p.overloaded_mul(y.call(f)) }
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "(#{@x.map(&:to_s).join(" * ")})"
    end

    # Same as `CAS::Op`
    #
    # Simplifcation engine supports:
    #
    #  * x * 0 = x * y = 0
    #  * 1 * y = y
    #  * x * 1 = x
    #  * x * x = x²
    #  * a * b = c (constants reduction)
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return CAS::Zero if @x.include? CAS::Zero
      @x = @x - [CAS::One]
      return CAS::One if @x.size == 0
      return @x[0] if @x.size == 1

      @x = self.__reduce_constants(@x) do |cs, xs|
        [cs.inject { |t, c| t *= c.call({}) }] + xs
      end

      @x = self.__reduce_multeplicity(@x) do |op, count|
        count > 1 ? (op ** count) : op
      end
      return self
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "(#{@x.map(&:to_code).join(" * ")})"
    end
  end # Prod
  CAS::Prod.init_simplify_dict
end
