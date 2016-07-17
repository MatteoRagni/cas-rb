#!/usr/bin/env ruby

module CAS
  #  ___                            _
  # | __|_ ___ __  ___ _ _  ___ _ _| |_
  # | _|\ \ / '_ \/ _ \ ' \/ -_) ' \  _|
  # |___/_\_\ .__/\___/_||_\___|_||_\__|
  #         |_|
  class Exp < CAS::Op
    def initialize(x)
      self.x = x
    end

    def diff
      CAS::Prod(self.x.diff, self)
    end

    def call
      Math::exp(self.x.call)
    end

    def to_s
      "exp(#{self.x})"
    end
  end # Exp

  #  _                       _ _   _
  # | |   ___  __ _ __ _ _ _(_) |_| |_  _ __
  # | |__/ _ \/ _` / _` | '_| |  _| ' \| '  \
  # |____\___/\__, \__,_|_| |_|\__|_||_|_|_|_|
  #           |___/
  class Ln < CAS::Op
    def initialize(x)
      self.x = x
    end

    def diff
      CAS::Div.new(self.x.diff, self.x)
    end

    def call
      Math::log self.x.call
    end

    def to_s
      "ln(#{self.x})"
    end
  end # Ln
end
