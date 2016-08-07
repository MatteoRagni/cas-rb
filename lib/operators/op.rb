#!/usr/bin/env ruby

module CAS
  class CASError < RuntimeError; end

  #   ___
  #  / _ \ _ __
  # | (_) | '_ \
  #  \___/| .__/
  #       |_|
  class Op
    attr_reader :x

    # Initialize a new empty operation container. This is a virtual
    # class and the other must inherit from this basic container.
    # Some methods raise a `CAS::CASError` if called.
    # The input element is a Numric, to create a constant.
    # `CAS::Op` specifies operations with a single variable
    #
    # <- `Numeric` to be converted in `CAS::Constant` or `CAS::Op` child operation
    # -> `CAS::Op` instance
    def initialize(x)
      if x.is_a? Numeric
        case x.to_f
        when 0.0
          x = CAS::Zero
        when 1.0
          x = CAS::One
        else
          x = CAS.const x
        end
      end
      CAS::Help.assert(x, CAS::Op)

      @x = x
    end

    # Return the dependencies of the operation. Requires a `CAS::Variable`
    # and it is one of the recursve method (implicit tree resolution)
    #
    # <- `CAS::Variable` instance
    # -> `TrueClass` if depends, `FalseClass` if not
    def depend?(v)
      CAS::Help.assert(v, CAS::Op)

      @x.depend? v
    end

    # Return the derivative of the operation using the chain rule
    # The input is a `CAS::Op` because it can handle derivatives
    # with respect to functions. E.g.:
    #
    # ```
    #  f(x) = (ln(x))**2
    #  g(x) = ln(x)
    #
    #  d f(x)
    #  ------ = 2 ln(x)
    #  d g(x)
    # ```
    #
    # <- `CAS::Op` object of the derivative
    # -> `CAS::Op` a derivated object, or `CAS::Zero` for constants
    def diff(v)
      CAS::Help.assert(v, CAS::Op)

      if @x.depend? v
        return @x.diff(v)
      end
      CAS::Zero
    end

    # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
    # or `Float` depends upon promotions).
    # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
    # as keys, and a `Numeric` as a value
    #
    # ``` ruby
    # x, y = CAS::vars :x, :y
    # f = (x ** 2) + (y ** 2)
    # f.call({x => 1, y => 2})
    # # => 2
    # ```
    # <- `Hash` with feed dictionary
    # -> `Numeric`
    def call(f)
      CAS::Help.assert(f, Hash)

      @x.call(f)
    end

    # Perform substitution of a part of the graph using a data table:
    #
    # ``` ruby
    # x, y = CAS::vars :x, :y
    # f = (x ** 2) + (y ** 2)
    # puts f
    # # => (x^2) + (y^2)
    # puts f.subs({x => CAS::ln(y)})
    # # => (ln(y)^2) + (y^2)
    # ```
    #
    # <- `Hash` with substitution table
    # -> `CAS::Op` (`self`) with substitution performed
    def subs(dt)
      CAS::Help.assert(dt, Hash)
      if dt.keys.include? @x
        if dt[@x].is_a? CAS::Op
          @x = dt[@x]
        elsif dt[@x].is_a? Numeric
          @x = CAS::const dt[@x]
        else
          raise CAS::CASError, "Impossible subs. Received a #{dt[@x].class} = #{dt[@x]}"
        end
      else
        @x.subs(dt)
      end
      return self
    end

    # Convert expression to string
    #
    # -> `String` to print on screen
    def to_s
      "#{@x}"
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    # -> `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "#{@x}"
    end

    # Returns a sum of two `CAS::Op`s
    #
    # <- `CAS::Op` tree
    # -> `CAS::Op` new object
    def +(op)
      CAS::Sum.new self, op
    end

    # Returns a difference of two `CAS::Op`s
    #
    # <- `CAS::Op` tree
    # -> `CAS::Op` new object
    def -(op)
      CAS::Diff.new self, op
    end

    # Returns a product of two `CAS::Op`s
    #
    # <- `CAS::Op` tree
    # -> `CAS::Op` new object
    def *(op)
      CAS::Prod.new self, op
    end

    # Returns a division of two `CAS::Op`s
    #
    # <- `CAS::Op` tree
    # -> `CAS::Op` new object
    def /(op)
      CAS::Div.new self, op
    end

    # Returns the power of two `CAS::Op`s
    #
    # <- `CAS::Op` tree
    # -> `CAS::Op` new object
    def **(op)
      CAS.pow(self, op)
    end

    # Unary operator for inversion of a `CAS::Op`
    #
    # -> `CAS::Op` new object
    def -@
      CAS.invert(self)
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    def simplify # TODO: improve this
      hash = @x.to_s
      @x = @x.simplify
      while @x.to_s != hash
        hash = @x.to_s
        @x = @x.simplify
      end
    end

    # Inspector for the current object
    #
    # -> `String`
    def inspect
      "#{self.class}(#{@x.inspect})"
    end

    # Equality operator, the standard operator is overloaded
    # :warning: this operates on the graph, not on the math
    # See `CAS::equal`, etc.
    #
    # <- `CAS::Op` to be tested against
    # -> `TrueClass` if equal, `FalseClass` if differs
    def ==(op)
      # CAS::Help.assert(op, CAS::Op)
      if op.is_a? CAS::Op
        return false if op.is_a? CAS::BinaryOp
        return (self.class == op.class and @x == op.x)
      end
      false
    end

    # Disequality operator, the standard operator is overloaded
    # :warning: this operates on the graph, not on the math
    # See `CAS::equal`, etc.
    #
    # <- `CAS::Op` to be tested against
    # -> `FalseClass` if equal, `TrueClass` if differs
    def !=(op)
      not self.==(op)
    end

    # Evaluates the proc against a given context. It is like having a
    # snapshot of the tree transformed in a callable object.
    # Obviously **if the tree changes, the generated proc does notchanges**.
    # The proc takes as input a feed dictionary in which each variable
    # is identified through the `CAS::Variable#name` key.
    #
    # The proc is evaluated in the context devined by the input `Binding` object
    # If `nil` is passed, the `eval` will run in this local context
    #
    # <- `Binding` or `NilClass` that is the context of the Ruby VM
    # -> `Proc` object with a single argument as an `Hash`
    def as_proc(bind=nil)
      args_ext = self.args.map { |e| "#{e} = fd[\"#{e}\"];" }
      code = "Proc.new do |fd|; #{args_ext.join " "} #{self.to_code}; end"
      if bind # All objects have eval value, we bind when not nil
        # CAS::Help.assert(bind, Binding)
        bind.eval(code)
      else
        eval(code)
      end
    end

    # Returns a list of all `CAS::Variable`s of the current tree
    #
    # -> `Array` of `CAS::Variable`s
    def args
      @x.args.uniq
    end

    # Return the local Graphviz node of the tree
    #
    # <- `?` unused variable (TODO: to be removed)
    # -> `String` of local Graphiz node
    def dot_graph(node)
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph node}\n"
    end

    # Returns the latex representation of the current Op.
    #
    # -> `String`
    def to_latex
      "#{self.class.gsub("CAS::", "")}\\left(#{@x.to_latex}\\right)"
    end
  end # Op
end
