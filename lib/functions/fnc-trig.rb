#!/usr/bin/env ruby

module CAS
  #  ___ _
  # / __(_)_ _
  # \__ \ | ' \
  # |___/_|_||_|
  class Sin < CAS::Op
    def diff(v)
      if @x.depend? v
        return @x.diff(v) * CAS.cos(@x)
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)
      Math::sin(@x.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "sin(#{@x})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return @x.x if @x.is_a? CAS::Asin
      return self.simplify_dictionary
    end
    @@simplify_dict = {
      CAS::Zero => CAS::Zero,
      CAS::Pi => CAS::Zero
    }

    # Same as `CAS::Op`
    def to_code
      "Math::sin(#{@x.to_code})"
    end

    # Return latex representation of current Op
    def to_latex
      "\\sin\\left( #{@x.to_latex} \\right)"
    end
  end # Sin

  def self.sin(x)
    CAS::Sin.new x
  end

  #    _       _
  #   /_\   __(_)_ _
  #  / _ \ (_-< | ' \
  # /_/ \_\/__/_|_||_|
  class Asin < CAS::Op
    def diff(v)
      if @x.depend? v
        return @x.diff(v) / CAS.sqrt(CAS::One - CAS.pow(@x, CAS::Two))
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)
      Math::acos(@x.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "asin(#{@x})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return @x.x if @x.is_a? CAS::Sin
      return self.simplify_dictionary
    end
    @@simplify_dict = {
      CAS::Zero => CAS::Zero,
      CAS::One => (CAS::Pi / 2)
    }

    # Same as `CAS::Op`
    def to_code
      "Math::asin(#{@x.to_code})"
    end

    # Return latex representation of current Op
    def to_latex
      "\\arcsin\\left( #{@x.to_latex} \\right)"
    end
  end

  def self.asin(x)
    CAS::Asin.new x
  end

  #   ___
  #  / __|___ ___
  # | (__/ _ (_-<
  #  \___\___/__/
  class Cos < CAS::Op
    def diff(v)
      if @x.depend? v
        return CAS.invert(@x.diff(v) * CAS.sin(@x))
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)
      Math::cos(@x.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "cos(#{@x})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return @x.x if @x.is_a? CAS::Acos
      return self.simplify_dictionary
    end
    @simplify_dict = {
      CAS::Zero => CAS::One,
      CAS::Pi => CAS::One
    }

    # Same as `CAS::Op`
    def to_code
      "Math::cos(#{@x.to_code})"
    end

    # Return latex representation of current Op
    def to_latex
      "\\cos\\left( #{@x.to_latex} \\right)"
    end
  end

  def self.cos(x)
    CAS::Cos.new x
  end

  #    _
  #   /_\  __ ___ ___
  #  / _ \/ _/ _ (_-<
  # /_/ \_\__\___/__/
  class Acos < CAS::Op
    def diff(v)
      if @x.depend? v
        return CAS.invert(@x.diff(v)/CAS.sqrt(CAS::One - CAS.pow(@x, CAS::Two)))
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)
      return Math::acos(@x.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "acos(#{@x})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return @x.x if @x.is_a? CAS::Cos
      return self.simplify_dictionary
    end
    @@simplify_dict = {
      CAS::Zero => (CAS::Pi / 2),
      CAS::One => CAS::Zero
    }

    # Same as `CAS::Op`
    def to_code
      "Math::acos(#{@x.to_code})"
    end

    # Return latex representation of current Op
    def to_latex
      "\\arccos\\left( #{@x.to_latex} \\right)"
    end
  end

  def self.acos(x)
    CAS::Acos.new x
  end

  #  _____
  # |_   _|_ _ _ _
  #   | |/ _` | ' \
  #   |_|\__,_|_||_|
  class Tan < CAS::Op
    def diff(v)
      if @x.depend? v
        return @x.diff(v) * CAS.pow(CAS::One/CAS.cos(@x), CAS::Two)
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)
      Math::tan(@x.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "tan(#{@x})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return @x.x if @x.is_a? CAS::Atan
      return self.simplify_dictionary
    end
    @@simplify_dict = {
      CAS::Zero => CAS::Zero,
      CAS::Pi => CAS::Zero
    }

    # Same as `CAS::Op`
    def to_code
      "Math::tan(#{@x.to_code})"
    end

    # Return latex representation of current Op
    def to_latex
      "\\tan\\left( #{@x.to_latex} \\right)"
    end
  end

  def self.tan(x)
    CAS::Tan.new x
  end

  #    _  _
  #   /_\| |_ __ _ _ _
  #  / _ \  _/ _` | ' \
  # /_/ \_\__\__,_|_||_|
  class Atan < CAS::Op
    def diff(v)
      if @x.depend? v
        return @x.diff(v) / (CAS.pow(@x, CAS::Two) + CAS::One)
      else
        return CAS::Zero
      end
    end

    # Same as `CAS::Op`
    def call(f)
      CAS::Help.assert(f, Hash)
      Math::atan(@x.call(f))
    end

    # Same as `CAS::Op`
    def to_s
      "atan(#{@x})"
    end

    # Same as `CAS::Op`
    def simplify
      super
      return @x.x if @x.is_a? CAS::Tan
      return self.simplify_dictionary
    end
    @@simplify_dict = {
      CAS::Zero => CAS::Zero,
      CAS::One => (CAS::Pi/4),
      CAS::Infinity => (CAS::Pi/2)
    }

    # Same as `CAS::Op`
    def to_code
      "Math::atan(#{@x.to_code})"
    end

    # Return latex representation of current Op
    def to_latex
      "\\arctan\\left( #{@x.to_latex} \\right)"
    end
  end

  def self.atan(x)
    CAS::Atan.new x
  end
end
