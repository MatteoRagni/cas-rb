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

    def diff(v); CAS::Zero; end
    def call(f = {}); @x; end
    def depend?(v); false; end
    def to_s; "#{@x}"; end
    def simplify
      case x
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
  end
  def self.const(f)
    CAS::Constant.new f
  end

  # __   __        _      _    _
  # \ \ / /_ _ _ _(_)__ _| |__| |___
  #  \ V / _` | '_| / _` | '_ \ / -_)
  #   \_/\__,_|_| |_\__,_|_.__/_\___|
  class Variable < CAS::Op
    def initialize(name = "x")
      self.is(name)
    end

    def is(name)
      @name = name
    end

    def diff(v)
      CAS::One
    end

    def depend?(v)
      self == v
    end

    def call(f)
      f[self]
    end

    def to_s
      "#{@name}"
    end

    def simplify
      return self
    end
  end # Number

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
  end
  Infinity = CAS::INFINITY_CONSTANT.new

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
