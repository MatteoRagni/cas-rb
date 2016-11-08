module CAS
  #  ___
  # / __|_  _ _ __
  # \__ \ || | '  \
  # |___/\_,_|_|_|_|

  ##
  # **Sum basic operation**. As for now it is implemented as a simple
  # binary operation. It will be implemented as n-ary op.
  class Sum < CAS::NaryOp
    # Performs the sum between arbitrary number of `CAS::Op`
    #
    # ```
    #   d
    # ---- (f(x) + g(x) + h(x)) = f'(x) + g'(x) + h'(x)
    #  dx
    # ```
    #
    #  * **argument**: `CAS::Op` argument of derivative
    #  * **returns**: `CAS::Op` derivative
    def diff(v)
      @x.map { |x| x.diff(v) }.inject { |sum_x, dx| sum_x += dx }
    end

    # The added element of a sum accumulates inside the
    # vector that holds the elements
    def +(op)
      CAS::Help.assert(op, CAS::Op)
      @x << op
      self
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
      return @x.inject { |val, x_i| val += x_i.call(f) }
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "(#{@x.map(&:to_s).join(" + ")})"
    end

    # Same as `CAS::Op`
    #
    # Simplifcation engine supports:
    #
    #  * x + 0 = x
    #  * 0 + y = y
    #  * x + x = 2 x
    #  * x + (-x) = 0
    #  * x + (-y) = x - y
    #  * 1 + 2 = 3 (constants reduction)
    #
    #  * **returns**: `CAS::Op` simplified version
    def simplify
      super
      return @x[0] if @x.size == 1

      # return CAS::Zero if @x == -@y or -@x == @y
      # return (@x - @y.x) if @y.is_a? CAS::Invert
      # return CAS.const(self.call({})) if (@x.is_a? CAS::Constant and @y.is_a? CAS::Constant)
      # Removing Zeros
      @x = @x - [CAS::Zero]
      # Multeplicity and associativity executed
      return self.reduce_associativity
    end

    # Reduce multeplicity will scan for elements that are equal in the definition
    # of the sum and will reduce their multeplicity
    # That means that if I have some sort of
    #
    # ```
    #  a + a + b + c => 2 * a + b + c
    # ```
    # But operates only on Array level! This is an internal function
    # and should never be used
    #
    #  * **requires**: An `Array`
    #  * **returns**: An `Array` with multeplicity reduced
    def __reduce_multeplicity(xs)
      count = Hash.new(0)
      xs.each do |x|
        e = x
        count.keys.each { |d| e = d if x == d  }
        count[e] += 1
      end
      count.map do |k, v|
        v > 1 ? CAS.const(v) * k : k
      end
    end

    # Reduces from an associative point of view, by a segregation
    # of "negative" and positive elements. Negatives comes from
    # Diff operations and Invert operations. All the others are considered
    # positive. This function implements an internal heuristic. Should
    # not be used outside
    #
    #  * **returns**: A `CAS::Diff` or a `CAS::Sum`
    def reduce_associativity
      pos, neg = [], []

      @x.each do |x_el|
        case x_el
        when CAS::Invert
          neg << x_el.x
        when CAS::Diff
          pos << x_el.x
          neg << x_el.y
        else
          pos << x_el
        end
      end

      pos, neg = self.reduce_associativity_array pos, neg
      pos = self.__reduce_multeplicity pos
      neg = self.__reduce_multeplicity neg

      # TODO : Add rules for simplifications
      left, right = nil, nil
      left  = CAS::Sum.new(pos) if pos.size > 1
      left  = pos[0]            if pos.size == 1
      right = CAS::Sum.new(neg) if neg.size > 1
      right = neg[0]            if neg.size == 1

      return  CAS::Zero unless left || right
      return  left unless right
      return  -right unless left
      return left - right
    end

    # Reduce the positive and the negative associative part of
    # the sum to perform the symbolic difference. Does not take into account
    # multeplicity
    #
    #  * **requires**: positive `Array`
    #  * **requires**: negative `Array`
    #  * **returns**: positive, reduced `Array` and negative `Array`
    def reduce_associativity_array(p_old, n_old)
      p_del, n_del = [], []
      p_old.each do |p|
        n_old.each do |n|
          if p == n
            p_del << p
            n_del << n
          end
        end
      end

      return (p_old - p_del), (n_old - n_del)
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "(#{@x.map(&:to_code).join(" + ")})"
    end
  end # Sum
  CAS::Sum.init_simplify_dict
end
