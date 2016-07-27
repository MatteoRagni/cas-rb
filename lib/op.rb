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
        case x
        when 0
          x = CAS::Zero
        when 1
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
      CAS::Help.assert(v, CAS::Variable)

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
          raise CASError, "Impossible subs. Received a #{dt[@x].class} = #{dt[@x]}"
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
      if bind
        CAS::Help.assert(bind, Binding)
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

  #  ___ _                     ___
  # | _ |_)_ _  __ _ _ _ _  _ / _ \ _ __
  # | _ \ | ' \/ _` | '_| || | (_) | '_ \
  # |___/_|_||_\__,_|_|  \_, |\___/| .__/
  #                      |__/      |_|
  class BinaryOp < CAS::Op
    attr_reader :x, :y

    # The binary operator inherits from the `CAS::Op`, even
    # if it is defined as a node with two possible branches. This
    # is particular of the basic operations. The two basic nodes
    # shares the **same** interface, so all the operations do not
    # need to know which kind of node they are handling.
    #
    # <- `CAS::Op` left argument of the node or `Numeric` to be converted in `CAS::Constant`
    # <- `CAS::Op` right argument of the node or `Numeric` to be converted in `CAS::Constant`
    # -> `CAS::BinaryOp` instance
    def initialize(x, y)
      if x.is_a? Numeric
        case x
        when 0
          x = CAS::Zero
        when 1
          x = CAS::One
        else
          x = CAS.const x
        end
      end
      if y.is_a? Numeric
        case y
        when 0
          y = CAS::Zero
        when 1
          y = CAS::One
        else
          y = CAS.const y
        end
      end
      CAS::Help.assert(x, CAS::Op)
      CAS::Help.assert(y, CAS::Op)

      @x = x
      @y = y
    end

    # Same as `CAS::Op#depend?`
    def depend?(v)
      CAS::Help.assert(v, CAS::Op)

      @x.depend? v or @y.depend? v
    end

    # This method returns an array with the derivatives of the two branches
    # of the node. This method is usually called by child classes, and it is not
    # intended to be used directly.
    #
    # <- `CAS::Op` operation to differentiate against
    # -> `Array` of differentiated branches ([0] for left, [1] for right)
    def diff(v)
      CAS::Help.assert(v, CAS::Op)
      left, right = CAS::Zero, CAS::Zero

      left = @x.diff(v) if @x.depend? v
      right = @y.diff(v) if @y.depend? v

      return left, right
    end

    # Substituitions for both branches of the graph, same as `CAS::Op#subs`
    #
    # <- `Hash` of substitutions
    # -> `CAS::BinaryOp`, in practice `self`
    def subs(dt)
      CAS::Help.assert(dt, Hash)
      if dt.keys.include? @x
        if dt[@x].is_a? CAS::Op
          @x = dt[@x]
        elsif dt[@x].is_a? Numeric
          @x = CAS::const dt[@x]
        else
          raise CASError, "Impossible subs. Received a #{dt[@x].class} = #{dt[@x]}"
        end
      else
        @x.subs(dt)
      end
      if dt.keys.include? @y
        if dt[@y].is_a? CAS::Op
          @y = dt[@y]
        elsif dt[@y].is_a? Numeric
          @y = CAS::const dt[@y]
        else
          raise CASError, "Impossible subs. Received a #{dt[@y].class} = #{dt[@y]}"
        end
      else
        @y.subs(dt)
      end
      return self
    end

    # Same `CAS::Op#call`
    #
    # <- `Hash` of values
    # -> `Numeric` for result
    def call(fd)
      raise CASError, "Not Implemented. This is a virtual method"
    end

    # String representation of the tree
    #
    # -> `String`
    def to_s
      raise CASError, "Not Implemented. This is a virtual method"
    end

    # Code to be used in `CAS::BinaryOp#to_proc`
    #
    # -> `String`
    def to_code
      raise CASError, "Not implemented. This is a virtual method"
    end

    # Returns an array of all the variables that are in the graph
    #
    # -> `Array` of `CAS::Variable`s
    def args
      (@x.args + @y.args).uniq
    end

    # Inspector
    #
    # -> `String`
    def inspect
      "#{self.class}(#{@x.inspect}, #{@y.inspect})"
    end

    # Comparison with other `CAS::Op`. This is **not** a math operation.
    #
    # <- `CAS::Op` to be compared against
    # -> `TrueClass` if equal, `FalseClass` if different
    def ==(op)
      CAS::Help.assert(op, CAS::Op)
      if op.is_a? CAS::BinaryOp
        return (self.class == op.class and @x == op.x and @y == op.y)
      else
        return false
      end
    end

    # Executes simplifications of the two branches of the graph
    #
    # -> `CAS::BinaryOp` as `self`
    def simplify # TODO: improve this
      hash = @x.to_s
      @x = @x.simplify
      while @x.to_s != hash
        hash = @x.to_s
        @x = @x.simplify
      end
      hash = @y.to_s
      @y = @y.simplify
      while @y.to_s != hash
        hash = @y.to_s
        @y = @y.simplify
      end
    end

    # Returns the graphviz representation of the current node
    #
    # <- `?` to be removed
    # -> `String`
    def dot_graph(node)
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph node}\n  #{cls} -> #{@y.dot_graph node}"
    end
    
    # Returns the latex representation of the current Op.
    #
    # -> `String`
    def to_latex
      "#{self.class.gsub("CAS::", "")}\\left(#{@x.to_latex},\\,#{@y.to_latex}\\right)"
    end
  end # BinaryOp
end
