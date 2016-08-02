#!/usr/bin/env ruby

module CAS
  #   ___             _            _
  #  / __|___ _ _  __| |_ __ _ _ _| |_
  # | (__/ _ \ ' \(_-<  _/ _` | ' \  _|
  #  \___\___/_||_/__/\__\__,_|_||_\__|
  class Constant < CAS::Op
    def initialize(x)
      @x = x
    end

    # The derivative of a constant is always zero
    def diff(v)
      CAS::Zero
    end

    # Same as `CAS::Op`
    def call(f)
      @x
    end

    # Same as `CAS::Op`
    def depend?(v)
      false
    end

    # Same as `CAS::Op`
    def to_s
      "#{@x}"
    end

    # Subs for a constant is a dummy method
    def subs(dt)
      # CAS::Help.assert(dt, Hash)
      # if dt.keys.include? self
      #   if dt[self].is_a? CAS::Op
      #     return dt[self]
      #   elsif dt[self].is_a? Numeric
      #     return CAS::const(dt[self])
      #   else
      #     raise CASError, "Impossible subs. Received a #{dt[self].class} = #{dt[self]}"
      #   end
      # end
    end

    # Same as `CAS::Op`
    def simplify
      case @x
      when 0
        return CAS::Zero
      when 1
        return CAS::One
      when Math::PI
        return CAS::Pi
      when Math::E
        return CAS::E
      when 1.0/0.0
        return CAS::Infinity
      else
        return self
      end
    end

    # Same as `CAS::Op`
    def args
      []
    end

    # Same as `CAS::Op`
    def ==(op)
      # CAS::Help.assert(op, CAS::Op)

      if op.is_a? CAS::Constant
        return @x == op.x
      else
        return false
      end
    end

    # Same as `CAS::Op`
    def inspect
      "Const(#{@x})"
    end

    # Same as `CAS::Op`
    def dot_graph(node)
      "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id};"
    end

    # Return latex representation of current Op
    def to_latex
      self.to_s
    end
  end

  # Allows to define a series of new constants.
  #
  # ``` ruby
  # a, b = CAS::const 1.0, 100
  # ```
  #
  # <- `Array` of Numeric
  # -> `Array` of `CAS::Contant`
  def self.const(*val)
    (return CAS::Constant.new(val[0])) if val.size == 1
    ret = []
    val.each do |n|
      ret << CAS::Constant.new(n)
    end
    return ret
  end

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
    def dot_graph(node)
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

  #  _______ ___  ___
  # |_  / __| _ \/ _ \
  #  / /| _||   / (_) |
  # /___|___|_|_\\___/
  class ZERO_CONSTANT < CAS::Constant
    def initialize
      @x = 0.0
    end

    def to_s
      "0"
    end
  end # Zero
  Zero = CAS::ZERO_CONSTANT.new

  #   ___
  #  / _ \ _ _  ___
  # | (_) | ' \/ -_)
  #  \___/|_||_\___|
  class ONE_CONSTANT < CAS::Constant
    def initialize
      @x = 1.0
    end

    def to_s
      "1"
    end
  end # Zero
  One = CAS::ONE_CONSTANT.new

  #  _____
  # |_   _|_ __ _____
  #   | | \ V  V / _ \
  #   |_|  \_/\_/\___/
  class TWO_CONSTANT < CAS::Constant
    def initialize
      @x = 2.0
    end

    def to_s
      "2"
    end
  end # Zero
  Two = CAS::TWO_CONSTANT.new

  #  ___ ___
  # | _ \_ _|
  # |  _/| |
  # |_| |___|
  class PI_CONSTANT < CAS::Constant
    def initialize
      @x = Math::PI
    end

    def to_s
      "π"
    end

    def to_latex
      "\\pi"
    end
  end
  Pi = CAS::PI_CONSTANT.new

  #  ___
  # | __|
  # | _|
  # |___|
  class E_CONSTANT < CAS::Constant
    def initialize
      @x = Math::E
    end

    def to_s
      "e"
    end

    def to_latex
      "e"
    end
  end
  E = CAS::E_CONSTANT.new

  #  ___       __ _      _ _
  # |_ _|_ _  / _(_)_ _ (_) |_ _  _
  #  | || ' \|  _| | ' \| |  _| || |
  # |___|_||_|_| |_|_||_|_|\__|\_, |
  #                            |__/
  class INFINITY_CONSTANT < CAS::Constant
    def initialize
      @x = (1.0/0.0)
    end

    def to_s
      "∞"
    end

    def to_latex
      "\\infty"
    end
  end
  Infinity = CAS::INFINITY_CONSTANT.new

  #  _  _          ___       __ _      _ _
  # | \| |___ __ _|_ _|_ _  / _(_)_ _ (_) |_ _  _
  # | .` / -_) _` || || ' \|  _| | ' \| |  _| || |
  # |_|\_\___\__, |___|_||_|_| |_|_||_|_|\__|\_, |
  #          |___/                           |__/
  class NEG_INFINITY_CONSTANT < CAS::Constant
    def initialize
      @x = -(1.0/0.0)
    end

    def to_s
      "-∞"
    end

    def to_latex
      "-\\infty"
    end
  end
  NegInfinity = CAS::NEG_INFINITY_CONSTANT.new

  #      _
  #  ___/ |
  # |___| |
  #     |_|
  class MINUS_ONE_CONSTANT < CAS::Constant
    def initialize
      @x = -1.0
    end

    def to_s
      "-1"
    end
  end
  MinusOne = CAS::MINUS_ONE_CONSTANT.new
end
