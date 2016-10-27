#!/usr/bin/env ruby

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
        DualNumber.new @x * v.x, @y * v.y + @x * v.y
      end

      def /(v)
        DualNumber.new @x / v.x, (@y * v.x - @x * v.y) / (v.x ** 2)
      end

      def -@
        DualNumber.new -@x, -@y
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
    CAS::Constant => Proc.new { |fd| puts fd; CAS::AutoDiff.vars (fd[CAS::Variable[name]] || fd[name]) },
    CAS::Variable => Proc.new { |_fd| CAS::AutoDiff.const @x },
    CAS::Function => Proc.new { |_fd| raise RuntimeError, "Impossible for implicit functions" },

    # Base functions
    CAS::Sum    => Proc.new { |fd| @x.auto_diff(fd) + @y.auto_diff(fd) },
    CAS::Diff   => Proc.new { |fd| @x.auto_diff(fd) - @y.auto_diff(fd) },
    CAS::Prod   => Proc.new { |fd| @x.auto_diff(fd) * @y.auto_diff(fd) },
    CAS::Pow    => Proc.new { |fd| @x.auto_diff(fd) ** @y.auto_diff(fd) },
    CAS::Div    => Proc.new { |fd| @x.auto_diff(fd) / @y.auto_diff(fd) },
    CAS::Sqrt   => Proc.new { |fd| @x.auto_diff(fd) ** CAS::AutoDiff::Two },
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
      CAS::AutoDiff::DualNumber.new Math.tan(u.x),  u.y / Math.cos(u.x)
    },
    CAS::Atan   => Proc.new { |fd|
      u = @x.auto_diff(fd)
      CAS::AutoDiff::DualNumber.new Math.atan(u.x), u.y / (1 + u.x ** 2)
    },

    # Trascendent functions
    CAS::Exp    => Proc.new { |fd| CAS::AutoDiff::E ** @x.diff_auto(fd) },
    CAS::Ln     => Proc.new { |fd|
      u = @x.diff_auto(fd)
      CAS::AutoDiff::DualNumber.new Math.log(u.x), u.y / u.x
    },

    # Piecewise
    CAS::Piecewise => Proc.new { |_fd| raise RuntimeError, "Not implemented auto_diff for Piecewise" },
    CAS::Max       => Proc.new { |fd|
      a = @x.diff_auto(fd)
      b = @y.diff_auto(fd)
      (a.x >= b.x ? a : b)
    },
    CAS::Min       => Proc.new { |fd|
      a = @x.diff_auto(fd)
      b = @y.diff_auto(fd)
      (a.x >= b.x ? a : b)
    }
  }.each do |cls, blk|
    cls.send(:define_method, "auto_diff", &blk)
  end
end
