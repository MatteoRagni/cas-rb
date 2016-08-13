#!/usr/bin/env ruby

module CAS
  #  ___ _                   _
  # | _ (_)___ __ _____ __ _(_)___ ___
  # |  _/ / -_) _/ -_) V  V / (_-</ -_)
  # |_| |_\___\__\___|\_/\_/|_/__/\___|

  ##
  # Piecewise function. The function returns when called a result
  # that dependes upon the evaluation of a condition. In practice:
  #
  # ```
  #   /
  #  |  f(x)   if condition(x) is True
  # <
  #  |  g(x)   otherwise
  #   \
  # ```
  #
  # From this class other classes will inherit like `CAS::Max` and `CAS::Min` classes
  class Piecewise < CAS::BinaryOp
    attr_reader :condition

    # Initialize a new piecewise function. It requires first the function
    # that returns when condition is true, than the function when condition is
    # false, and finally the condition that must be of class `CAS::Condition`
    #
    #  * **argument**: `CAS::Op` first function
    #  * **argument**: `CAS::Op` second function
    #  * **argument**: `CAS::Condition` evaluated condition
    #  * **returns**: `CAS::Piecewise` new instance
    def initialize(x, y, condition)
      CAS::Help.assert(condition, CAS::Condition)

      super(x, y)
      @condition = condition
    end

    # Derivative of a function is performed as derivative of the two internal functions
    # while condition is unchanged
    #
    # warning:: Piecewise functions are in general not differentiable. Thus differentiability
    # is left to the user
    #
    # ```
    #      /                                     /
    #  d  |  f(x)   if condition(x) is True     | f'(x)   if condition(x) is True
    # -- <                                   = <
    # dx  |  g(x)   otherwise                   | g'(x)   otherwise
    #      \                                     \
    # ```
    #
    #  * **argument**: `CAS::Op` argument of derivative
    #  * **returns**: `CAS::Piecewise` with derivated functions and unchanged condition
    def diff(v)
      CAS::Help.assert(v, CAS::Op)
      return CAS::Piecewise.new(@x.diff(v).simplify, @y.diff(v).simplify, @condition)
    end

    # Executes the condition. If it is `true` it returns the first function,
    # else it returns the value of the second function.
    #
    #  * **argument**: `Hash` with value tables
    #  * **returns**: `Numeric` the result of the call
    def call(fd)
      CAS::Help.assert(fd, Hash)
      (@condition.call(fd) ? @x.call(fd) : @y.call(fd))
    end

    # Checks if two `CAS::Piecewise` are equal. Checks equality on all functions+
    # and conditions
    #
    #  * **argument**: `CAS::Op` to be checked against
    #  * **returns**: `TrueClass` or `FalseClass`
    def ==(op)
      CAS::Help.assert(op, CAS::Op)
      if self.class != op.class
        return false
      else
        return ((@x == op.x) and (@y == op.y) and (@condition == op.condition))
      end
    end

    # Convert the piecewise funtion to a String of Ruby code
    #
    #  * **returns**: `String` of code
    def to_code
      "(#{@condition.to_code} ? (#{@x.to_code}) : (#{@y.to_code}))"
    end

    # Convert the piecewise function into a String
    #
    #  * **returns**: `String`
    def to_s
      "(#{@condition} ? #{@x} : #{@y})"
    end

    alias :binary_dot_graph :dot_graph
    # Convert piecewise function into a dot graphviz representation
    #
    #  * **returns**: `String`
    def dot_graph
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph}\n  #{cls} -> #{@y.dot_graph}\n  #{cls} -> #{@condition.dot_graph}"
    end

    # Convert piecewise function into LaTeX representation
    #
    #  * **returns**: `String` of LaTeX code
    def to_latex
      "\\left\\{ \\begin{array}{lr} #{@x.to_latex} & #{@condition.to_latex} \\\\ #{@y.to_latex} \\end{array} \\right."
    end
  end

  #  __  __ _      __  __
  # |  \/  (_)_ _ |  \/  |__ ___ __
  # | |\/| | | ' \| |\/| / _` \ \ /
  # |_|  |_|_|_||_|_|  |_\__,_/_\_\

  ##
  # Class MinMax is an intermediate class for Min and Max functions. It contains shared code
  # and methods
  class MinMax < CAS::Piecewise
    # Convert MinMax function into LaTeX representation
    #
    #  * **returns**: `String` of LaTeX code
    def to_latex
      "\\mathrm{#{@type}}\\left( \\begin{array}{c} #{@x.to_latex} \\\\ #{@y.to_latex} \\end{array} \\right)"
    end

    # Returns a string representation for the current operation
    #
    #  * **returns**: `String`
    def to_s
      "#{@type}(#{@x}, #{@y})"
    end

    alias :dot_graph :binary_dot_graph
  end # MinMax

  #  __  __
  # |  \/  |__ ___ __
  # | |\/| / _` \ \ /
  # |_|  |_\__,_/_\_\

  # Max class represent a piecewise in which the condition is `f(x) ≥ g(x)`. Derivate a `CAS::Max`
  # will return a `CAS::Piecewise` (since condition will not depend anymore on object functions)
  class Max < CAS::Piecewise
    # To initialize `CAS::Max` only the two functions are necessary. The condition is automatically
    # generated
    #
    #  * **argument**: `CAS::Op` first function
    #  * **argument**: `CAS::Op` second function
    def initialize(x, y)
      super(x, y, CAS::greater_equal(x, y))
      @type = "max"
    end
  end # Max

  #  __  __ _
  # |  \/  (_)_ _
  # | |\/| | | ' \
  # |_|  |_|_|_||_|

  # Min class represent a piecewise in which the condition is `f(x) ≤ g(x)`. Derivate a `CAS::Min`
  # will return a `CAS::Piecewise` (since condition will not depend anymore on object functions)
  class Min < CAS::Piecewise
    # To initialize `CAS::Min` only the two functions are necessary. The condition is automatically
    # generated
    #
    #  * **argument**: `CAS::Op` first function
    #  * **argument**: `CAS::Op` second function
    def initialize(x, y)
      super(x, y, CAS::smaller_equal(x, y))
      @type = "min"
    end
  end # Min

  # Shortcut for `CAS::Max` initializer
  #
  #  * **argument**: `CAS::Op` left function
  #  * **argument**: `CAS::Op` right function
  #  * **returns**: `CAS::Max` new instance
  def self.max(x, y)
    CAS::Max.new(x, y)
  end

  # Shortcut for `CAS::Min` initializer
  #
  #  * **argument**: `CAS::Op` left function
  #  * **argument**: `CAS::Op` right function
  #  * **returns**: `CAS::Min` new instance
  def self.min(x, y)
    CAS::Min.new(x, y, CAS::smaller_equal(x, y))
  end
end
