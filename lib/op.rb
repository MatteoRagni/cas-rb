#!/usr/bin/env ruby

module CAS
  class CASError < RuntimeError; end

  #   ___
  #  / _ \ _ __
  # | (_) | '_ \
  #  \___/| .__/
  #       |_|
  class Op
    def initialize(x)
      @x = x
    end

    def depend?(v)
      @x.depend? v
    end

    def diff(v)
      if @x.depend? v
        return @x.diff(v)
      end
      CAS::Zero
    end

    def call(f)
      @x.call(f)
    end

    def to_s
      "#{@x}"
    end

    def +(op)
      CAS::Sum.new self, op
    end

    def -(op)
      CAS::Diff.new self, op
    end

    def *(op)
      CAS::Prod.new self, op
    end

    def /(op)
      CAS::Div.new self, op
    end

    def **(op)
      CAS.pow(self, op)
    end
  end # Op

  #  ___ _                     ___
  # | _ |_)_ _  __ _ _ _ _  _ / _ \ _ __
  # | _ \ | ' \/ _` | '_| || | (_) | '_ \
  # |___/_|_||_\__,_|_|  \_, |\___/| .__/
  #                      |__/      |_|
  class BinaryOp < CAS::Op
    def initialize(x, y)
      @x = x
      @y = y
    end

    def depend?(v)
      @x.depend? v or @y.depend? v
    end

    def diff(v)
      left = @x.diff(v) if @x.depend? v
      right = @y.diff(v) if @y.depend? v
      return left, right
    end

    def call
      raise CASError, "Not Implemented. This is a virtual method"
    end

    def to_s
      raise CASError, "Not Implemented. This is a virtual method"
    end
  end # BinaryOp
end
