#!/usr/bin/env ruby

# Copyright (c) 2016 Matteo Ragni
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

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
    # Left hand side
    attr_reader :x
    # Right hand side
    attr_reader :y

    # Initializer for a new condition. The condition is implicit in the class, thus a
    # pure `CAS::Condition` cannot be used.
    #
    #  * **argument**: `CAS::Op` left argument
    #  * **argument**: `CAS::Op` right argument
    #  * **returns**: `CAS::Condition` new instance
    def initialize(x, y)
      @x = x
      @y = y
      self.representative
    end

    # Saves some required elements
    def representative
      @cond_type  = "??"
      @cond_repr  = "??"
      self
    end

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Trueclass` or `Falseclass`
    def call(_fd)
      raise CAS::CASError, "This is a virtual method"
    end

    # Inspector for the class. It is class specific
    #
    #  * **returns**: `String`
    def inspect
      "#{self.class}(#{@x.inspect}, #{@y.inspect})"
    end

    # Returns a string that represents the object to be printed
    #
    # `String`
    def to_s
      "(#{@x} #{@cond_repr} #{@y})"
    end

    # Return the code that performs a condition evaluation
    #
    #  * **returns**: `String`
    def to_code
      "(#{@x} #{@cond_type} #{@y})"
    end

    # Returns an array of variables of the two functions in the condition
    #
    #  * **returns**: `Array` of `CAS::Variable`
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
    #  * **argument**: `CAS::Op` to perform the derivative
    def diff(v)
      CAS::Help.assert v, CAS::Op

      @x.diff(v)
      @y.diff(v)
      self.simplify
    end

    # Returns true if one of the two functions depends upon the expression included
    #
    #  * **argument**: `CAS::Op` operator to check against for dependencies
    #  * **returns**: `TrueClass` or `FalseClass`
    def depend?(v)
      CAS::Help.assert v, CAS::Op

      @x.depend?(v) or @y.depend?(v)
    end

    # Return true if two functions are equal, false if different
    #
    #  * **argument**: `CAS::Op` operator to check against for equality
    #  * **returns**: `TrueClass` or `FalseClass`
    def ==(op)
      CAS::Help.assert(op, CAS::Op)

      # condB = (@x == op.y) and (@y == op.x)
      return ((@x == op.x) and (@y == op.y) and (self.class == op.class))
    end

    # Simplify left and right term of the operator
    #
    #  * **returns**: `CAS::Condition`
    def simplify
      @x.simplify
      @y.simplify
      return self
    end

    # Substitute in the two elements using a dictionary
    #
    #  * **returns**: `Hash` of substitutions
    def subs(fd)
      CAS::Help.assert(fd, Hash)
      @x.subs(fd)
      @y.subs(fd)
      return self
    end

    # Returns the dot graphviz representation of the code
    #
    #  * **returns**: `String`
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
    # Saves some required elements
    def representative
      @cond_type, @cond_repr = "==", "≡"
      self
    end

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Trueclass` or `Falseclass`
    def call(fd)
      CAS::Help.assert fd, Hash

      return (@x.call(fd) == @y.call(fd))
    end

    # Return true if two functions are equal, false if different
    #
    #  * **argument**: `CAS::Op` operator to check against for equality
    #  * **returns**: `TrueClass` or `FalseClass`
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
    # Saves some required elements
    def representative
      @cond_type = @cond_repr = "<"
      self
    end

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Trueclass` or `Falseclass`
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
    # Saves some required elements
    def representative
      @cond_type = @cond_repr = ">"
      self
    end

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Trueclass` or `Falseclass`
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
    # Saves some required elements
    def representative
      @cond_type = "<="
      @cond_repr = "≤"
      self
    end

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Trueclass` or `Falseclass`
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
    # Saves some required elements
    def representative
      @cond_type = ">="
      @cond_repr = "≥"
      self
    end

    # Function call will evaluate left and right functions to solve the
    # relation
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Trueclass` or `Falseclass`
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
    #  * **argument**: `CAS::Op` ther element of the condition
    #  * **returns**: `CAS::Equal` new instance
    def equal(v)
      CAS.equal(self, v)
    end

    # Shortcut for creating greater kind condition.
    #
    #  * **argument**: `CAS::Op` ther element of the condition
    #  * **returns**: `CAS::Greater` new instance
    def greater(v)
      CAS.greater(self, v)
    end

    # Shortcut for creating a smaller kind condition.
    #
    #  * **argument**: `CAS::Op` ther element of the condition
    #  * **returns**: `CAS::Smaller` new instance
    def smaller(v)
      CAS.smaller(self, v)
    end

    # Shortcut for creating a greater equal kind condition.
    #
    #  * **argument**: `CAS::Op` ther element of the condition
    #  * **returns**: `CAS::GreaterEqual` new instance
    def greater_equal(v)
      CAS.greater_equal(self, v)
    end

    # Shortcut for creating a smaller equal kind condition.
    #
    #  * **argument**: `CAS::Op` ther element of the condition
    #  * **returns**: `CAS::SmallerEqual` new instance
    def smaller_equal(v)
      CAS.smaller_equal(self, v)
    end
  end # Op
end
