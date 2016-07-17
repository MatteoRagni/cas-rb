#!/usr/bin/env ruby

module CAS
  #  ___ _
  # / __(_)_ _
  # \__ \ | ' \
  # |___/_|_||_|
  class Sin < CAS::Op
    def diff(v)
      if @x.depend? v
        return @x.diff(v) * CAS::cos(@x)
      else
        return CAS::Zero
      end
    end

    def call(f)
      Math::sin self.x.call(f)
    end

    def to_s
      "sin(#{self.x})"
    end
  end

  def sin(x)
    CAS::Sin.new x
  end

  #    _       _
  #   /_\   __(_)_ _
  #  / _ \ (_-< | ' \
  # /_/ \_\/__/_|_||_|
  class Asin < CAS::Op
    def diff(v)

    end

    def call(f)

    end

    def to_s
      "atan(#{self.x})"
    end
  end

  def asin(x)
    CAS::Asin.new x
  end

  #   ___
  #  / __|___ ___
  # | (__/ _ (_-<
  #  \___\___/__/
  class Cos < CAS::Op
    def diff(v)
      if @x.depend? v
        return CAS::invert(@x.diff(v) * CAS::sin(@x))
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

  def cos(x)
    CAS::Cos.new x
  end

  #    _
  #   /_\  __ ___ ___
  #  / _ \/ _/ _ (_-<
  # /_/ \_\__\___/__/
  class Acos < CAS::Op
    def diff(v)

    end

    def call(f)

    end

    def to_s
      "atan(#{self.x})"
    end
  end

  def acos(x)
    CAS::Acos.new x
  end

  #  _____
  # |_   _|_ _ _ _
  #   | |/ _` | ' \
  #   |_|\__,_|_||_|
  class Tan < CAS::Op
    def diff(v)
      CAS::Prod.new(
        CAS::Sum.new(
          CAS::Number.new(1.0),
          CAS::Pow.new(CAS::Tan.new(self.x), CAS::Number.new(1.0))
        ),
        self.x.diff
      )
    end

    def call(f)
      Math::tan self.x.call
    end

    def to_s
      "tan(#{self.x})"
    end
  end

  def tan(x)
    CAS::Tan.new x
  end

  #    _  _
  #   /_\| |_ __ _ _ _
  #  / _ \  _/ _` | ' \
  # /_/ \_\__\__,_|_||_|
  class Atan < CAS::Op
    def diff
      CAS::Div.new(
        self.x.diff,
        CAES::Sum.new(
          CAES::Pow.new(self.x, CAES::Number.new(2.0)),
          CAES::Number.new(1.0)
        )
      )
    end

    def call
      Math::atan2 self.x.call
    end

    def to_s
      "atan(#{self.x})"
    end
  end

  def atan(x)
    CAS::Atan.new x
  end
end
