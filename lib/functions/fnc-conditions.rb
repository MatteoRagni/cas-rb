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

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    # <- `Hash` with feed dictionary
    # -> `Trueclass` or `Falseclass`
    def call(_fd)
      raise CAS::CASError, "This is a virtual method"
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

  #  ___                _
  # | __|__ _ _  _ __ _| |
  # | _|/ _` | || / _` | |
  # |___\__, |\_,_\__,_|_|
  #        |_|

  ##
  # This class is a Condition for two equal function
  class Equal < CAS::Condition
    @@type, @@repr, @@latex = "==", "≡", "="

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    # <- `Hash` with feed dictionary
    # -> `Trueclass` or `Falseclass`
    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) == @y.call(fd))
    end

    # Return true if two functions are equal, false if different
    #
    # <- `CAS::Op` operator to check against for equality
    # -> `TrueClass` or `FalseClass`
    def ==(op)
      CAS::Help.assert(op, CAS::Op)
      cond_f = ((@x == op.x) and (@y == op.y)) or ((@x == op.y) and (@y == op.x))
      return (cond_f and (self.class == op.class))
    end
  end # Equal

  #  ___            _ _
  # / __|_ __  __ _| | |___ _ _
  # \__ \ '  \/ _` | | / -_) '_|
  # |___/_|_|_\__,_|_|_\___|_|

  ##
  # This class is a Condition for left smaller function
  class Smaller < CAS::Condition
    @@type = @@repr = @@latex = "<"

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    # <- `Hash` with feed dictionary
    # -> `Trueclass` or `Falseclass`
    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) < @y.call(fd))
    end
  end # Smaller

  #   ___              _
  #  / __|_ _ ___ __ _| |_ ___ _ _
  # | (_ | '_/ -_) _` |  _/ -_) '_|
  #  \___|_| \___\__,_|\__\___|_|

  ##
  # This class is a Condition for right smaller function
  class Greater < CAS::Condition
    @@type = @@repr = @@latex = ">"

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    # <- `Hash` with feed dictionary
    # -> `Trueclass` or `Falseclass`
    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) > @y.call(fd))
    end
  end # Greater

  #  ___            _ _         ___                _
  # / __|_ __  __ _| | |___ _ _| __|__ _ _  _ __ _| |
  # \__ \ '  \/ _` | | / -_) '_| _|/ _` | || / _` | |
  # |___/_|_|_\__,_|_|_\___|_| |___\__, |\_,_\__,_|_|
  #                                   |_|

  ##
  # This class is a Condition for left smaller or equal function
  class SmallerEqual < CAS::Condition
    @@type = "<="
    @@repr = "≤"
    @@latex = "\\leq"

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    # <- `Hash` with feed dictionary
    # -> `Trueclass` or `Falseclass`
    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) <= @y.call(fd))
    end
  end # SmallerEqual

  #   ___              _           ___                _
  #  / __|_ _ ___ __ _| |_ ___ _ _| __|__ _ _  _ __ _| |
  # | (_ | '_/ -_) _` |  _/ -_) '_| _|/ _` | || / _` | |
  #  \___|_| \___\__,_|\__\___|_| |___\__, |\_,_\__,_|_|
  #                                      |_|

  ##
  # This class is a condition for right smaller or equal function
  class GreaterEqual < CAS::Condition
    @@type = ">="
    @@repr = "≥"
    @@latex = "\\geq"

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    # <- `Hash` with feed dictionary
    # -> `Trueclass` or `Falseclass`
    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) >= @y.call(fd))
    end
  end # SmallerEqual

  # Shortcut creates a `CAS::Equal` object
  def self.equal(x, y)
    CAS::Equal.new(x, y)
  end

  # Shortcut creates a `CAS::Greater` object
  def self.greater(x, y)
    CAS::Greater.new(x, y)
  end

  # Shortcut creates a `CAS::GreaterEqual` object
  def self.greater_equal(x, y)
    CAS::GreaterEqual.new(x, y)
  end

  # Shortcut creates `CAS::Smaller` object
  def self.smaller(x, y)
    CAS::Smaller.new(x, y)
  end

  # Shortcut creates a `CAs::SmallerEqual` object
  def self.smaller_equal(x, y)
    CAS::SmallerEqual.new(x, y)
  end

  class Op
    # Shortcut for creating equality condition.
    #
    # <- `CAS::Op` ther element of the condition
    # -> `CAS::Equal` new instance
    def equal(v)
      CAS.equal(self, v)
    end

    # Shortcut for creating greater kind condition.
    #
    # <- `CAS::Op` ther element of the condition
    # -> `CAS::Greater` new instance
    def greater(v)
      CAS.greater(self, v)
    end

    # Shortcut for creating a smaller kind condition.
    #
    # <- `CAS::Op` ther element of the condition
    # -> `CAS::Smaller` new instance
    def smaller(v)
      CAS.smaller(self, v)
    end

    # Shortcut for creating a greater equal kind condition.
    #
    # <- `CAS::Op` ther element of the condition
    # -> `CAS::GreaterEqual` new instance
    def greater_equal(v)
      CAS.greater_equal(self, v)
    end

    # Shortcut for creating a smaller equal kind condition.
    #
    # <- `CAS::Op` ther element of the condition
    # -> `CAS::SmallerEqual` new instance
    def smaller_equal(v)
      CAS.smaller_equal(self, v)
    end
  end # Op
end