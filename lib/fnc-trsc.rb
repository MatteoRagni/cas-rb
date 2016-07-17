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

    def call(f)
      Math::exp @x.call
    end

    def to_s
      "exp(#{@x})"
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

    def call
      Math::log self.x.call
    end

    def to_s
      "ln(#{self.x})"
    end
  end # Ln

  def self.ln(x)
    CAS::Ln.new x
  end
end
