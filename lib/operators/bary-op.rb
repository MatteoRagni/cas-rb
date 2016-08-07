#!/usr/bin/env ruby

module CAS
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
    def call(_fd)
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
