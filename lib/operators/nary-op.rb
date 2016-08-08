#!/usr/bin/env ruby

module CAS
  # This is an attempt to build some sort of node in the graph that
  # has arbitrary number of childs node. It should help implement more easily
  # some sort of better simplifications engine
  #
  # This is an incredibly experimental feature.
  class NaryOp < CAS::Op
    attr_reader :x

    # Initialize a new empty N-elements operation container. This is
    # a virtual class, and other must inherit from this basical container
    #
    # <- `Numeric` to be converted in `CAS::Constant` or `CAS::Op` child operations
    # -> `CAS::NaryOp` instance
    def initialize(*xs)
      @x = []
      xs.each do |x|
        if x.is_a? Numeric
          x = Op.numeric_to_const x
        end
        CAS::Help.assert(x, CAS::Op)
        @x << x
      end
    end

    # Returns the dependencies of the operation. Require a `CAS::Variable`
    # and it is one of the recursive method (implicit tree resolution)
    #
    # <- `CAS::Variable` instance
    # -> `TrueClass` or `FalseClass`
    def depend?(v)
      CAS::Help.assert(v, CAS::Op)
      dep = false
      @x.each { |x| dep = (x.depend?(v) or dep) }
      return dep
    end

    # Return a list of derivative using the chain rule. The input is a
    # operation:
    #
    # ```
    #  f(x) = g(x) + h(x) + l(x) + m(x)
    #
    #  d f(x)
    #  ------ = g'(x) + h'(x) + l'(x) + m'(x)
    #    dx
    #
    #  d f(x)
    #  ------ = 1
    #  d g(x)
    # ```
    # <- `CAS::Op` object of the derivative
    # -> `CAS::NaryOp` of derivative
    def diff(v)
      CAS::Help.assert(v, CAS::Op)
      if self.depend?(v)
        return @x.map { |x| x.diff(v) }
      end
      return CAS::Zero
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
    # -> `Array` of `Numeric`
    def call(fd)
      CAS::Help.assert(fd, Hash)
      return @x.map { |x| x.call(fd) }
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
    # -> `CAS::NaryOp` (`self`) with substitution performed
    def subs(dt)
      CAS::Help.assert(dt, Hash)
      @x.each_with_index do |x, k|
        if dt.keys.include? x
          if dt[x].is_a? CAS::Op
            @x[k] = dt[x]
          elsif dt[x].is_a? Numeric
            @x[k] = CAS::const dt[x]
          else
            raise CAS::CASError, "Impossible subs. Received a #{dt[x].class} = #{dt[x]}"
          end
        end
      end
      return self
    end

    # Convert expression to string
    #
    # -> `String` to print on screen
    def to_s
      return "(#{@x.map(&:to_s).join(", ")})"
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    # -> `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      return "(#{@x.map(&:to_code).join(", ")})"
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    def simplify
      hash = self.to_s
      @x = @x.map { |x| x.simplify }
      while self.to_s != hash
        hash = self.to_s
        @x = @x.map { |x| x.simplify }
      end
    end

    # Inspector for the current object
    #
    # -> `String`
    def inspect
      "#{self.class}(#{@x.map(&:inspect).join(", ")})"
    end

    # Equality operator, the standard operator is overloaded
    # :warning: this operates on the graph, not on the math
    # See `CAS::equal`, etc.
    #
    # <- `CAS::Op` to be tested against
    # -> `TrueClass` if equal, `FalseClass` if differs
    def ==(op)
      # CAS::Help.assert(op, CAS::Op)
      if op.is_a? CAS::NaryOp
        return false if @x.size != op.x.size
        0.upto(@x.size - 1) do |i|
          return false if @x[i] != op.x[i]
        end
        return true
      end
      false
    end

    # Returns a list of all `CAS::Variable`s of the current tree
    #
    # -> `Array` of `CAS::Variable`s
    def args
      r = []
      @x.each { |x| r += x.args }
      return r.uniq
    end

    # Return the local Graphviz node of the tree
    #
    # <- `?` unused variable (TODO: to be removed)
    # -> `String` of local Graphiz node
    def dot_graph
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      ret = ""
      @x.each do |x|
        ret += "#{cls} -> #{x.dot_graph}\n"
      end
      return ret
    end


    # Returns the latex representation of the current Op.
    #
    # -> `String`
    def to_latex
      "#{self.class.gsub("CAS::", "")}\\left(#{@x.map(&:to_latex).join(",\\,")}\\right)"
    end
  end # NaryOp
end
