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
    def diff(_v)
      CAS::Zero
    end

    # Same as `CAS::Op`
    def call(_f)
      @x
    end

    # Same as `CAS::Op`
    def depend?(_v)
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
