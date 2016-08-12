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
    # -> `Hash`
    def self.list
      @@vars
    end

    # Return the number of variable defined
    #
    # -> `Fixnum`
    def self.size
      @@vars.keys.size
    end

    # Returns `true` if a variable already exists
    #
    # <- `Object` that represent the variable
    # -> `TrueClass` if variable exists, `FalseClass` if not
    def self.exist?(name)
      @@vars.keys.include? name
    end

    attr_reader :name
    # Variable is a container for an atomic simbol that becomes a number
    # when `CAS::Op#call` method is used.
    #
    # <- `Object` that is a identifier for the variable
    # -> `CAS::Variable` instance
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
    # <- `CAS::Op` for the derivative denominator
    # -> `CAS::Constant`, 0 if not depended, 1 if dependent
    def diff(v)
      (self == v ? CAS::One : CAS::Zero)
    end

    # Returns `TrueClass` if argument of the function is equal
    # to `self`
    #
    # <- `CAS::Op`
    # -> `TrueClass` or `FalseClass`
    def depend?(v)
      self == v
    end

    # Equality operator, the standard operator is overloaded
    # :warning: this operates on the graph, not on the math
    # See `CAS::equal`, etc.
    #
    # <- `CAS::Op` to be tested against
    # -> `TrueClass` if equal, `FalseClass` if differs
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
    # <- `Hash` with feed dictionary
    # -> `Numeric`
    def call(f)
      CAS::Help.assert(f, Hash)

      return f[self] if f[self]
      return f[@name] if f[@name]
    end

    # Convert expression to string
    #
    # -> `String` to print on screen
    def to_s
      "#{@name}"
    end

    # Convert expression to code (internal, for `CAS::Op#to_proc` method)
    #
    # -> `String` that represent Ruby code to be parsed in `CAS::Op#to_proc`
    def to_code
      "#{@name}"
    end

    # Returns an array containing `self`
    #
    # -> `Array` containing `self`
    def args
      [self]
    end

    # Terminal substitutions for variables. If input datatable
    # contains the variable will perform the substitution with
    # the value.
    #
    # <- `Hash` of substitutions
    # -> `CAS::Op` of substitutions
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
    # -> `String`
    def inspect
      "Var(#{@name})"
    end

    # Simplification callback. The only possible simplification
    # is returning `self`
    #
    # -> `CAS::Variable` as `self`
    def simplify
      self
    end

    # Return the local Graphviz node of the tree
    #
    # -> `String` of local Graphiz node
    def dot_graph
      "#{@name};"
    end

    # Returns the latex representation of the current Op.
    #
    # -> `String`
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
  # <- `Array` of Numeric
  # -> `Array` of `CAS::Variable`
  def self.vars(*name)
    (return CAS::Variable.new(name[0])) if name.size == 1
    ret = []
    name.each do |n|
      ret << CAS::Variable.new(n)
    end
    return ret
  end
end
