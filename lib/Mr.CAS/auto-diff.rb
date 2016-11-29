#!/usr/bin/env ruby

# Copyright (c) 2016 Matteo Ragni
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

module CAS
  module AutoDiff
    class DualNumber
      include Math
      attr_reader :x, :y

      def initialize(x, y)
        @x, @y = x, y
      end

      def +(v)
        DualNumber.new @x + v.x, @y + v.y
      end

      def -(v)
        DualNumber.new @x - v.x, @y - v.y
      end

      def *(v)
        DualNumber.new @x * v.x, @y * v.x + @x * v.y
      end

      def /(v)
        DualNumber.new @x / v.x, (@y * v.x - @x * v.y) / (v.x ** 2)
      end

      def -@
        DualNumber.new(-@x, -@y)
      end

      def **(v)
        t = (v.y == 0 ? 0 : @x * log(@x) * v.y)
        DualNumber.new @x ** v.x, (@x ** (v.x - 1)) * (v.x * @y + t)
      end

      def abs
        return DualNumber.new(0, 0) if @x == 0
        DualNumber.new @x.abs, @y * (@x <=> 0)
      end

      def to_s;    self.inspect;  end
      def inspect; "<#{@x},#{@y}>"; end
      def real; @x; end
      def diff; @y; end
    end # DualNumbers

    def self.const(x)
      DualNumber.new x, 0
    end

    def self.vars(x)
      DualNumber.new x, 1
    end

    Zero = self.const 0
    One  = self.const 1
    Two  = self.const 2
    E    = self.const Math::E
    Pi   = self.const Math::PI
  end


  {
    # Terminal nodes
    CAS::Variable => Proc.new { |fd| CAS::AutoDiff.vars (fd[CAS::Variable[@name]] || fd[@name]) },
    CAS::Constant => Proc.new { |_fd| CAS::AutoDiff.const @x },
    CAS::Function => Proc.new { |_fd| raise RuntimeError, "Impossible for implicit functions" },

    # Base functions
    CAS::Sum    => Proc.new { |fd|
      @x.map { |e| e.auto_diff(fd) }.inject { |s, e| s += e }
    },
    CAS::Diff   => Proc.new { |fd| @x.auto_diff(fd) - @y.auto_diff(fd) },
    CAS::Prod   => Proc.new { |fd|
      @x.map { |e| e.auto_diff(fd) }.inject { |s, e| s += e } 
    },
    CAS::Pow    => Proc.new { |fd| @x.auto_diff(fd) ** @y.auto_diff(fd) },
    CAS::Div    => Proc.new { |fd| @x.auto_diff(fd) / @y.auto_diff(fd) },
    CAS::Sqrt   => Proc.new { |fd| @x.auto_diff(fd) ** (CAS::AutoDiff::One / CAS::AutoDiff::Two) },
    CAS::Invert => Proc.new { |fd| -@x.auto_diff(fd) },
    CAS::Abs    => Proc.new { |fd| @x.auto_diff(fd).abs },

    # Trigonometric functions
    CAS::Sin    => Proc.new { |fd|
      u = @x.auto_diff(fd)
      CAS::AutoDiff::DualNumber.new Math.sin(u.x), Math.cos(u.x) * u.y
    },
    CAS::Asin   => Proc.new { |fd|
      u = @x.auto_diff(fd)
      CAS::AutoDiff::DualNumber.new Math.asin(u.x), -(Math.sin(u.x) * u.y)
    },
    CAS::Cos    => Proc.new { |fd|
      u = @x.auto_diff(fd)
      CAS::AutoDiff::DualNumber.new Math.cos(u.x), -(Math.sin(u.x) * u.y)
    },
    CAS::Acos   => Proc.new { |fd|
      u = @x.auto_diff(fd)
      CAS::AutoDiff::DualNumber.new Math.acos(u.x), -u.y / Math.sqrt(1 + u.x ** 2)
    },
    CAS::Tan    => Proc.new { |fd|
      u = @x.auto_diff(fd)
      CAS::AutoDiff::DualNumber.new Math.tan(u.x),  u.y / (Math.cos(u.x) ** 2)
    },
    CAS::Atan   => Proc.new { |fd|
      u = @x.auto_diff(fd)
      CAS::AutoDiff::DualNumber.new Math.atan(u.x), u.y / (1 + u.x ** 2)
    },

    # Trascendent functions
    CAS::Exp    => Proc.new { |fd| CAS::AutoDiff::E ** @x.auto_diff(fd) },
    CAS::Ln     => Proc.new { |fd|
      u = @x.auto_diff(fd)
      CAS::AutoDiff::DualNumber.new Math.log(u.x), u.y / u.x
    },

    # Piecewise
    CAS::Piecewise => Proc.new { |_fd| raise RuntimeError, "Not implemented AutoDiff for Piecewise" },
    CAS::Max       => Proc.new { |fd|
      a = @x.auto_diff(fd)
      b = @y.auto_diff(fd)
      (a.x >= b.x ? a : b)
    },
    CAS::Min       => Proc.new { |fd|
      a = @x.auto_diff(fd)
      b = @y.auto_diff(fd)
      (a.x >= b.x ? a : b)
    },

    CAS::Function => Proc.new { |_fd| raise RuntimeError, "Not implemented AutoDiff for implicit functions" }
  }.each do |cls, blk|
    cls.send(:define_method, "auto_diff", &blk)
  end
end
