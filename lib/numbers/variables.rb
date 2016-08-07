#!/usr/bin/env ruby

module CAS
  # __   __        _      _    _
  # \ \ / /_ _ _ _(_)__ _| |__| |___
  #  \ V / _` | '_| / _` | '_ \ / -_)
  #   \_/\__,_|_| |_\__,_|_.__/_\___|
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

    # Same as `CAS::Op`
    def depend?(v)
      self == v
    end

    # Same as `CAS::Op`
    def ==(op)
      # CAS::Help.assert(op, CAS::Op)
      if op.is_a? CAS::Variable
        return self.inspect == op.inspect
      else
        false
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)

      return f[self] if f[self]
      return f[@name] if f[@name]
    end

    # Same as `CAS::Op`
    def to_s
      "#{@name}"
    end

    # Same as `CAS::Op`
    def to_code
      "#{@name}"
    end

    # Same as `CAS::Op`
    def args
      [self]
    end

    # Terminal substitutions for variables
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

    # Same as `CAS::Op`
    def inspect
      "Var(#{@name})"
    end

    # Same as `CAS::Op`
    def simplify
      self
    end

    # Same as `CAS::Op`
    def dot_graph
      "#{@name};"
    end

    # Return latex representation of current Op
    def to_latex
      self.to_s
    end
  end # Number

  def self.vars(*name)
    (return CAS::Variable.new(name[0])) if name.size == 1
    ret = []
    name.each do |n|
      ret << CAS::Variable.new(n)
    end
    return ret
  end
end
