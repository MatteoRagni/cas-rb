#!/usr/bin/env ruby

module CAS
  class CASError < RuntimeError; end

  #   ___
  #  / _ \ _ __
  # | (_) | '_ \
  #  \___/| .__/
  #       |_|
  class Op
    attr_reader :x

    def initialize(x)
      if x.is_a? Numeric
        case x
        when 0
          x = CAS::Zero
        when 1
          x = CAS::One
        else
          x = CAS.const x
        end
      end
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

    def simplify
      @x.simplify
    end
  end # Op

  #  ___ _                     ___
  # | _ |_)_ _  __ _ _ _ _  _ / _ \ _ __
  # | _ \ | ' \/ _` | '_| || | (_) | '_ \
  # |___/_|_||_\__,_|_|  \_, |\___/| .__/
  #                      |__/      |_|
  class BinaryOp < CAS::Op
    attr_reader :x, :y

    def initialize(x, y)
      if x.is_a? Numeric
        case x
        when 0
          x = CAS::Zero
        when 1
          x = CAS::One
        else
          x = CAS.const x
        end
      end
      if y.is_a? Numeric
        case y
        when 0
          y = CAS::Zero
        when 1
          y = CAS::One
        else
          y = CAS.const y
        end
      end
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

    def simplify
      @x = @x.simplify
      @y = @y.simplify
    end
  end # BinaryOp
end
