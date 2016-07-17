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

    def call(f)
      Math::sin @x.call(f)
    end

    def to_s
      "sin(#{@x})"
    end
  end

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

    def call(f)
      Math::acos @x.call(f)
    end

    def to_s
      "asin(#{@x})"
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

    def call(f)
      Math::cos self.x.call(f)
    end

    def to_s
      "cos(#{self.x})"
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

    def call(f)

    end

    def to_s
      "acos(#{self.x})"
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

    def call(f)
      Math::tan self.x.call
    end

    def to_s
      "tan(#{self.x})"
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

    def call
      Math::atan self.x.call
    end

    def to_s
      "atan(#{self.x})"
    end
  end

  def self.atan(x)
    CAS::Atan.new x
  end
end
