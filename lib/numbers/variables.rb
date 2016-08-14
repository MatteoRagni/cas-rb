#!/usr/bin/env ruby

module CAS
  # __   __        _      _    _
  # \ \ / /_ _ _ _(_)__ _| |__| |___
  #  \ V / _` | '_| / _` | '_ \ / -_)
  #   \_/\__,_|_| |_\__,_|_.__/_\___|

  ##
  # Container for a variable. It can be resolved in a numerical value.
  # It can also be used for derivatives.
  class Variable < CAS::Op
    # Contains all define variable, in an hash. Variables are
    # accessible through variable name.
    @@vars = {}

    # Returns the `Hash` that contains all the variable
    #
    #  * **returns**: `Hash`
    def self.list
      @@vars
    end

    # Return the number of variable defined
    #
    #  * **returns**: `Fixnum`
    def self.size
      @@vars.keys.size
    end

    # Returns a variable given its name
    #
    #  * **argument**: `Object` name of the variable
    #  * **returns**: `CAS::Variable` instance if exists, creates a new variable if does not
    def self.[](s)
      if CAS::Variable.exist? s
        return @@vars[s]
      else
        return CAS::vars(s)
      end
    end

    # Returns `true` if a variable already exists
    #
    #  * **argument**: `Object` that represent the variable
    #  * **returns**: `TrueClass` if variable exists, `FalseClass` if not
    def self.exist?(name)
      @@vars.keys.include? name
    end

    attr_reader :name
    # Variable is a container for an atomic simbol that becomes a number
    # when `CAS::Op#call` method is used.
    #
    #  * **argument**: `Object` that is a identifier for the variable
    #  * **returns**: `CAS::Variable` instance
    def initialize(name)
      raise CASError, "Variable #{name} already exists" if CAS::Variable.exist? name
      @name = name
      @@vars[@name] = self
    end

    # Returns the derivative of a variable
    #
    # ```
    #  dx      dx
    #  -- = 1; -- = 0
    #  dx      dy
    # ```
    #
    #  * **argument**: `CAS::Op` for the derivative denominator
    #  * **returns**: `CAS::Constant`, 0 if not depended, 1 if dependent
    def diff(v)
      (self == v ? CAS::One : CAS::Zero)
    end

    # Returns `TrueClass` if argument of the function is equal
    # to `self`
    #
    #  * **argument**: `CAS::Op`
    #  * **returns**: `TrueClass` or `FalseClass`
    def depend?(v)
      self == v
    end

    # Equality operator, the standard operator is overloaded
    # :warning: this operates on the graph, not on the math
    # See `CAS::equal`, etc.
    #
    #  * **argument**: `CAS::Op` to be tested against
    #  * **returns**: `TrueClass` if equal, `FalseClass` if differs
    def ==(op)
      # CAS::Help.assert(op, CAS::Op)
      if op.is_a? CAS::Variable
        return self.inspect == op.inspect
      else
        false
      end
    end

    # Call resolves the operation tree in a `Numeric` (if `Fixnum`)
    # or `Float` (depends upon promotions).
    # As input, it requires an hash with `CAS::Variable` or `CAS::Variable#name`
    # as keys, and a `Numeric` as a value
    #
    # ``` ruby
    # x, y = CAS::vars :x, :y
    # f = (x ** 2) + (y ** 2)
    # f.call({x => 1, y => 2})
    # # => 2
    # ```
    #
    #  * **argument**: `Hash` with feed dictionary
    #  * **returns**: `Numeric`
    def call(f)
      CAS::Help.assert(f, Hash)

      return f[self] if f[self]
      return f[@name] if f[@name]
    end

    # Convert expression to string
    #
    #  * **returns**: `String` to print on screen
    def to_s
      "#{@name}"
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    #  * **returns**: `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "#{@name}"
    end

    # Returns an array containing `self`
    #
    #  * **returns**: `Array` containing `self`
    def args
      [self]
    end

    # Terminal substitutions for variables. If input datatable
    # contains the variable will perform the substitution with
    # the value.
    #
    #  * **argument**: `Hash` of substitutions
    #  * **returns**: `CAS::Op` of substitutions
    def subs(dt)
      CAS::Help.assert(dt, Hash)
      if dt.keys.include? self
        if dt[self].is_a? CAS::Op
          return dt[self]
        elsif dt[self].is_a? Numeric
          return CAS::const(dt[self])
        else
          raise CASError, "Impossible subs. Received a #{dt[self].class} = #{dt[self]}"
        end
      end
    end

    # Inspector for the current object
    #
    #  * **returns**: `String`
    def inspect
      "Var(#{@name})"
    end

    # Simplification callback. The only possible simplification
    # is returning `self`
    #
    #  * **returns**: `CAS::Variable` as `self`
    def simplify
      self
    end

    # Return the local Graphviz node of the tree
    #
    #  * **returns**: `String` of local Graphiz node
    def dot_graph
      "#{@name};"
    end

    # Returns the latex representation of the current Op.
    #
    #  * **returns**: `String`
    def to_latex
      self.to_s
    end
  end # Number

  # Allows to define a series of new variables.
  #
  # ``` ruby
  # x, y = CAS::vars :x, :y
  # ```
  #
  #  * **argument**: `Array` of Numeric
  #  * **returns**: `Array` of `CAS::Variable`
  def self.vars(*name)
    (return CAS::Variable.new(name[0])) if name.size == 1
    ret = []
    name.each do |n|
      ret << CAS::Variable.new(n)
    end
    return ret
  end
end
