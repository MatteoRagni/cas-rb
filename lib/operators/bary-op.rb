#!/usr/bin/env ruby

module CAS
  #  ___ _                     ___
  # | _ |_)_ _  __ _ _ _ _  _ / _ \ _ __
  # | _ \ | ' \/ _` | '_| || | (_) | '_ \
  # |___/_|_||_\__,_|_|  \_, |\___/| .__/
  #                      |__/      |_|

  ##
  # Binary operator
  class BinaryOp < CAS::Op
    # First element of the operation
    attr_reader :x
    # Second element of the operation
    attr_reader :y

    # The binary operator inherits from the `CAS::Op`, even
    # if it is defined as a node with two possible branches. This
    # is particular of the basic operations. The two basic nodes
    # shares the **same** interface, so all the operations do not
    # need to know which kind of node they are handling.
    #
    #  * **argument**: `CAS::Op` left argument of the node or `Numeric` to be converted in `CAS::Constant`
    #  * **argument**: `CAS::Op` right argument of the node or `Numeric` to be converted in `CAS::Constant`
    #  * **returns**: `CAS::BinaryOp` instance
    def initialize(x, y)
      if x.is_a? Numeric
        x = BinaryOp.numeric_to_const x
      end
      if y.is_a? Numeric
        y = BinaryOp.numeric_to_const y
      end
      CAS::Help.assert(x, CAS::Op)
      CAS::Help.assert(y, CAS::Op)

      @x = x
      @y = y
    end

    # Return the dependencies of the operation. Requires a `CAS::Variable`
    # and it is one of the recursve method (implicit tree resolution)
    #
    #  * **argument**: `CAS::Variable` instance
    #  * **returns**: `TrueClass` if depends, `FalseClass` if not
    def depend?(v)
      CAS::Help.assert(v, CAS::Op)

      @x.depend? v or @y.depend? v
    end

    # This method returns an array with the derivatives of the two branches
    # of the node. This method is usually called by child classes, and it is not
    # intended to be used directly.
    #
    #  * **argument**: `CAS::Op` operation to differentiate against
    #  * **returns**: `Array` of differentiated branches ([0] for left, [1] for right)
    def diff(v)
      CAS::Help.assert(v, CAS::Op)
      left, right = CAS::Zero, CAS::Zero

      left = @x.diff(v) if @x.depend? v
      right = @y.diff(v) if @y.depend? v

      return left, right
    end

    # Substituitions for both branches of the graph, same as `CAS::Op#subs`
    #
    #  * **argument**: `Hash` of substitutions
    #  * **returns**: `CAS::BinaryOp`, in practice `self`
    def subs(dt)
      return self.subs_lhs(dt).subs_rhs(dt)
    end

    # Substituitions for left branch of the graph, same as `CAS::Op#subs`
    #
    #  * **argument**: `Hash` of substitutions
    #  * **returns**: `CAS::BinaryOp`, in practice `self`
    def subs_lhs(dt)
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

    # Substituitions for left branch of the graph, same as `CAS::Op#subs`
    #
    #  * **argument**: `Hash` of substitutions
    #  * **returns**: `CAS::BinaryOp`, in practice `self`
    def subs_rhs(dt)
      CAS::Help.assert(dt, Hash)
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
    #  * **argument**: `Hash` of values
    #  * **returns**: `Numeric` for result
    def call(_fd)
      raise CAS::CASError, "Not Implemented. This is a virtual method"
    end

    # String representation of the tree
    #
    #  * **returns**: `String`
    def to_s
      raise CAS::CASError, "Not Implemented. This is a virtual method"
    end

    # Code to be used in `CAS::BinaryOp#to_proc`
    #
    #  * **returns**: `String`
    def to_code
      raise CAS::CASError, "Not implemented. This is a virtual method"
    end

    # Returns an array of all the variables that are in the graph
    #
    #  * **returns**: `Array` of `CAS::Variable`s
    def args
      (@x.args + @y.args).uniq
    end

    # Inspector
    #
    #  * **returns**: `String`
    def inspect
      "#{self.class}(#{@x.inspect}, #{@y.inspect})"
    end

    # Comparison with other `CAS::Op`. This is **not** a math operation.
    #
    #  * **argument**: `CAS::Op` to be compared against
    #  * **returns**: `TrueClass` if equal, `FalseClass` if different
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
    #  * **returns**: `CAS::BinaryOp` as `self`
    def simplify
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
    #  * **argument**: `?` unused removed
    #  * **returns**: `String`
    def dot_graph
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph}\n  #{cls} -> #{@y.dot_graph}"
    end

    # Returns the latex representation of the current Op.
    #
    #  * **returns**: `String`
    def to_latex
      "#{self.class.gsub("CAS::", "")}\\left(#{@x.to_latex},\\,#{@y.to_latex}\\right)"
    end
  end # BinaryOp
end
