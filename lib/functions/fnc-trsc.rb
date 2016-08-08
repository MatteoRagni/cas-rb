#!/usr/bin/env ruby

module CAS
  #  ___                            _
  # | __|_ ___ __  ___ _ _  ___ _ _| |_
  # | _|\ \ / '_ \/ _ \ ' \/ -_) ' \  _|
  # |___/_\_\ .__/\___/_||_\___|_||_\__|
  #         |_|
  class Exp < CAS::Op
    def diff(v)
      if @x.depend? v
        return @x.diff(v) * CAS.exp(@x)
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)
      Math::exp(@x.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "exp(#{@x})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return @x.x if @x.is_a? CAS::Ln
      return self.simplify_dictionary
    end
    @@simplify_dict = {
      CAS::Zero => CAS::One,
      CAS::One => CAS::E,
      CAS::Infinity => CAS::Infinity
    }

    # Same as `CAS::Op`
    def to_code
      "Math::exp(#{@x.to_code})"
    end

    # Return latex representation of current Op
    def to_latex
      "e^{#{@x.to_latex}}"
    end
  end # Exp

  def self.exp(x)
    CAS::Exp.new x
  end

  #  _                       _ _   _
  # | |   ___  __ _ __ _ _ _(_) |_| |_  _ __
  # | |__/ _ \/ _` / _` | '_| |  _| ' \| '  \
  # |____\___/\__, \__,_|_| |_|\__|_||_|_|_|_|
  #           |___/
  class Ln < CAS::Op
    def diff(v)
      if @x.depend? v
        return CAS::One / @x
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      # I'm leaving to Math the honor
      # of handling negative values...
      CAS::Help.assert(f, Hash)
      Math::log(@x.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "log(#{@x})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return @x.x if @x.is_a? CAS::Exp
      return self.simplify_dictionary
    end
    @@simplify_dict = {
      CAS::Zero => CAS.invert(CAS::Infinity),
      CAS::One => CAS::Zero,
      CAS::E => CAS::One
    }

    # Same as `CAS::Op`
    def to_code
      "Math::log(#{@x.to_code})"
    end

    # Return latex representation of current Op
    def to_latex
      "\\log\\left( #{@x.to_latex} \\right)"
    end
  end # Ln

  def self.ln(x)
    CAS::Ln.new x
  end
  def self.log(x)
    CAS::Ln.new x
  end
end
