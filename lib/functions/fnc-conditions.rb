#!/usr/bin/env ruby

module CAS
  #   ___             _ _ _   _
  #  / __|___ _ _  __| (_) |_(_)___ _ _
  # | (__/ _ \ ' \/ _` | |  _| / _ \ ' \
  #  \___\___/_||_\__,_|_|\__|_\___/_||_|

  ##
  # Condition class is a pseudo-class for all the other kind of conditions:
  #
  #  * Equal
  #  * Greater
  #  * GreaterEqual
  #  * Smaller
  #  * SmallerEqual
  #
  # When derivated, the two functions (that can be considered as the difference of two elements)
  # are derived autonoumouosly. A condition is composed by:
  #
  #  * left function (x)
  #  * right function (y)
  #  * type of condition
  class Condition
    @@type  = "??"
    @@repr  = "??"
    @@latex = "??"
    attr_reader :x, :y

    # Initializer for a new condition. The condition is implicit in the class, thus a
    # pure `CAS::Condition` cannot be used.
    #
    # <- `CAS::Op` left argument
    # <- `CAS::Op` right argument
    # -> `CAS::Condition` new instance
    def initialize(x, y)
      @x = x
      @y = y
    end

    # Inspector for the class. It is class specific
    #
    # -> `String`
    def inspect
      "#{self.class}(#{@x.inspect}, #{@y.inspect})"
    end

    # Returns a string that represents the object to be printed
    #
    # `String`
    def to_s
      "(#{@x} #{@@repr} #{@y})"
    end

    # Returns a string that can be used for printing LaTeX version of the
    # condition
    #
    # `String`
    def to_latex
      "\\left(#{@x} #{@@latex} #{@y}\\right)"
    end

    # Return the code that performs a condition evaluation
    #
    # -> `String`
    def to_code
      "(#{@x} #{@@type} #{@y})"
    end

    # Returns an array of variables of the two functions in the condition
    #
    # -> `Array` of `CAS::Variable`
    def args
      (@x.args + @y.args).uniq
    end

    # Performs the derivative of the two elements:
    #
    # ```
    #  d
    # -- [f(x) > g(y)] = f'(x) > g'(x)
    # dx
    # ```
    #
    # since between the two there is a difference relation.
    #
    # <- `CAS::Op` to perform the derivative
    def diff(v)
      CAS::Help.assert v, CAS::Op

      @x.diff(v)
      @y.diff(v)
      self.simplify
    end

    # Returns true if one of the two functions depends upon the expression included
    #
    # <- `CAS::Op` operator to check against for dependencies
    # -> `TrueClass` or `FalseClass`
    def depend?(v)
      CAS::Help.assert v, CAS::Op

      @x.depend?(v) or @y.depend?(v)
    end

    # Return true if two functions are equal, false if different
    #
    # <- `CAS::Op` operator to check against for equality
    # -> `TrueClass` or `FalseClass`
    def ==(op)
      CAS::Help.assert(op, CAS::Op)

      # condB = (@x == op.y) and (@y == op.x)
      return ((@x == op.x) and (@y == op.y) and (self.class == op.class))
    end

    # Simplify left and right term of the operator
    #
    # -> `CAS::Condition`
    def simplify
      @x.simplify
      @y.simplify
      return self
    end

    # Substitute in the two elements using a dictionary
    #
    # -> `Hash` of substitutions
    def subs(fd)
      CAS::Help.assert(fd, Hash)
      @x.subs(fd)
      @y.subs(fd)
      return self
    end

    # Returns the dot graphviz representation of the code
    #
    # -> `String`
    def dot_graph(node)
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph node}\n  #{cls} -> #{@y.dot_graph node}"
    end
  end # Condition

  class Equal < CAS::Condition
    @@type = "=="
    @@repr = "≡"
    @@latex = "="

    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) == @y.call(fd))
    end

    def ==(op)
      super
    end
  end # Equal

  class Smaller < CAS::Condition
    @@type = "<"
    @@repr = "<"
    @@latex = "<"

    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) < @y.call(fd))
    end
  end # Smaller

  class Greater < CAS::Condition
    @@type = ">"
    @@repr = ">"
    @@latex = ">"

    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) > @y.call(fd))
    end
  end # Greater

  class SmallerEqual < CAS::Condition
    @@type = "<="
    @@repr = "≤"
    @@latex = "\\leq"

    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) <= @y.call(fd))
    end
  end # SmallerEqual

  class GreaterEqual < CAS::Condition
    @@type = ">="
    @@repr = "≥"
    @@latex = "\\geq"

    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) >= @y.call(fd))
    end
  end # SmallerEqual
end
