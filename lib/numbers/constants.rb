#!/usr/bin/env ruby

module CAS
  #   ___             _            _
  #  / __|___ _ _  __| |_ __ _ _ _| |_
  # | (__/ _ \ ' \(_-<  _/ _` | ' \  _|
  #  \___\___/_||_/__/\__\__,_|_||_\__|

  ##
  # Constant is a `CAS::Op` container for a `Numeric` value, that is
  # not a `CAS::Variable`, thus its derivative it is always zero
  class Constant < CAS::Op
    def initialize(x)
      @x = x
    end

    # Evaluates the derivative of a constant. The derivative is
    # always a `CAS::Zero`
    #
    # ```
    #  d
    # -- c = 0
    # dx
    # ```
    def diff(_v)
      CAS::Zero
    end

    # Calling a constant will return the value of the constant
    # itself.
    #
    # <- Unused argument
    # -> `Numeric` value of the constant
    def call(_f)
      @x
    end

    # There is no dependency in a constant, thus this method will
    # always return false
    #
    # <- Unused argument
    # -> `FalseClass`
    def depend?(_v)
      false
    end

    # The string representation of a constant is the value
    # of the constant
    #
    # -> `String`
    def to_s
      "#{@x}"
    end

    # Subs for a constant is a dummy method that returns always `self`
    #
    # <- Unused argument
    # -> `CAS::Constant` that represent `self`
    def subs(_dt)
      return self
    end

    # Simplification callback. It simplify the subgraph of each node
    # until all possible simplification are performed (thus the execution
    # time is not deterministic).
    #
    # -> `CAS::Op` simplified version
    def simplify
      return self.simplify_dictionary
    end
    @@simplidy_dict = {
      0 => CAS::Zero,
      1 => CAS::One,
      Math::PI => CAS::Pi,
      Math::E => CAS::E,
      (1.0/0.0) => CAS::Infinity
    }

    # Args of a constant is an empty `Array`
    #
    # -> `Array` empty
    def args
      []
    end

    # Check if a constant is equal to another `CAS::Op` object
    #
    # <- `CAs::Op`
    # -> `TrueClass` or `FalseClass`
    def ==(op)
      if op.is_a? CAS::Constant
        return @x == op.x
      else
        return false
      end
    end

    # Inspection for `CAS::Constant` class
    #
    # -> `String`
    def inspect
      "Const(#{self})"
    end

    # Return the local Graphviz node of the tree
    #
    # -> `String` of local Graphiz node
    def dot_graph
      n = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{n};\n  #{n} [label=\"#{@x}\"];"
    end

    # Return latex representation of current `CAS::Op`
    #
    # -> `String`
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

  #  _______ ___  ___
  # |_  / __| _ \/ _ \
  #  / /| _||   / (_) |
  # /___|___|_|_\\___/

  ##
  # Class that represents the constant Zero (0)
  class ZERO_CONSTANT < CAS::Constant
    # Initializer for the zero constant
    #
    # -> `CAS::ZERO_CONSTANT` new instance
    def initialize
      @x = 0.0
    end

    # String representation for the constant
    #
    # -> `String`
    def to_s
      "0"
    end
  end # Zero

  # Zero (0) constant representation
  Zero = CAS::ZERO_CONSTANT.new

  #   ___
  #  / _ \ _ _  ___
  # | (_) | ' \/ -_)
  #  \___/|_||_\___|

  ##
  # Class that represents the constant One (1)
  class ONE_CONSTANT < CAS::Constant
    # Initializer for the one constant
    #
    # -> `CAS::ONE_CONSTANT` new instance
    def initialize
      @x = 1.0
    end

    # String representation for the constant
    #
    # -> `String`
    def to_s
      "1"
    end
  end # Zero
  One = CAS::ONE_CONSTANT.new

  #  _____
  # |_   _|_ __ _____
  #   | | \ V  V / _ \
  #   |_|  \_/\_/\___/

  ##
  # Class that represents the constant Two (2)
  class TWO_CONSTANT < CAS::Constant
    # Initializer for the two constant
    #
    # -> `CAS::TWO_CONSTANT` new instance
    def initialize
      @x = 2.0
    end

    # String representation for the constant
    #
    # -> `String`
    def to_s
      "2"
    end
  end # Zero
  Two = CAS::TWO_CONSTANT.new

  #  ___ ___
  # | _ \_ _|
  # |  _/| |
  # |_| |___|

  ##
  # Class that represents the constant Pi (π)
  class PI_CONSTANT < CAS::Constant
    # Initializer for the pi constant
    #
    # -> `CAS::PI_CONSTANT` new instance
    def initialize
      @x = Math::PI
    end

    # String representation for the constant
    #
    # -> `String`
    def to_s
      "π"
    end

    # Latex representation for the constant
    #
    # -> `String`
    def to_latex
      "\\pi"
    end
  end
  Pi = CAS::PI_CONSTANT.new

  #  ___
  # | __|
  # | _|
  # |___|

  ##
  # Class that represents the constant E (e)
  class E_CONSTANT < CAS::Constant
    # Initializer for the E constant
    #
    # -> `CAS::E_CONSTANT` new instance
    def initialize
      @x = Math::E
    end

    # String representation for the constant
    #
    # -> `String`
    def to_s
      "e"
    end

    # Latex representation for the constant
    #
    # -> `String`
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

  ##
  # Class that represents the constant Infinity (∞)
  class INFINITY_CONSTANT < CAS::Constant
    # Initializer for the infinity constant
    #
    # -> `CAS::INFINITY_CONSTANT` new instance
    def initialize
      @x = (1.0/0.0)
    end

    # String representation for the constant
    #
    # -> `String`
    def to_s
      "∞"
    end

    # Latex representation for the constant
    #
    # -> `String`
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

  ##
  # Class that represents the constant Negative Infinity (-∞)
  class NEG_INFINITY_CONSTANT < CAS::Constant
    # Initializer for the negative infinity constant
    #
    # -> `CAS::NEG_INFINITY_CONSTANT` new instance
    def initialize
      @x = -(1.0/0.0)
    end

    # String representation for the constant
    #
    # -> `String`
    def to_s
      "-∞"
    end

    # Latex representation for the constant
    #
    # -> `String`
    def to_latex
      "-\\infty"
    end
  end
  NegInfinity = CAS::NEG_INFINITY_CONSTANT.new

  #      _
  #  ___/ |
  # |___| |
  #     |_|

  ##
  # Class that represents the constant Minus One (-1)
  class MINUS_ONE_CONSTANT < CAS::Constant
    # Initializer for the minus one constant
    #
    # -> `CAS::MINUS_ONE_CONSTANT` new instance
    def initialize
      @x = -1.0
    end

    # String representation for the constant
    #
    # -> `String`
    def to_s
      "-1"
    end
  end
  MinusOne = CAS::MINUS_ONE_CONSTANT.new

  # Series of useful numeric constant, Based upon
  # `Numeric` keys, with `CAs::Constant` value
  NumericToConst = {
    0 => CAS::Zero,
    0.0 => CAS::Zero,
    1 => CAS::One,
    1.0 => CAS::One,
    2 => CAS::Two,
    2.0 => CAS::Two,
    Math::PI => CAS::Pi,
    Math::E => CAS::E,
    (1.0/0.0) => CAS::Infinity,
  }
end
