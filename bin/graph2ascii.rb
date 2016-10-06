#!/usr/bin/env ruby
#require 'ragni-cas'

module CAS
  module Ascii
    def self.normalize_ascii(x_lines, type=nil)
      x_width = x_lines.map(&:size).max
      x_lines = x_lines.map { |l| l + (" " * (x_width - l.size)) }
      if (type == :complex and x_lines.size > 1)
        x_lines = x_lines.map { |l| l = "⎜#{l}⎟" }
        x_lines[0][0],  x_lines[-1][0]  = "⎛", "⎝"
        x_lines[0][-1], x_lines[-1][-1] = "⎞", "⎠"
      elsif (type == :complex and x_lines.size == 1)
        x_lines = x_lines.map { |l| l = "(#{l})" }
      elsif type == :simple
        x_lines = x_lines.map { |l| l = "(#{l})" }
      end
      return x_lines
    end
  end

  class Op
    def to_ascii
      return "#{self}".lines, 0
    end

    def puts_ascii(offset=0)
      a, _, _ = self.to_ascii
      return a.map { |l| (" " * offset) + l }.join("\n")
    end

    def to_ascii_x_vars_complexity
      return (((@x.is_a? CAS::Variable) or (@x.is_a? CAS::Constant)) ? nil : :complex)
    end
  end

  class Variable
    def to_ascii
      return "#{@name}".lines, 0
    end
  end

  class BinaryOp
    def to_ascii_y_vars_complexity
      return (((@y.is_a? CAS::Variable) or (@y.is_a? CAS::Constant)) ? nil : :complex)
    end
  end

  #  ____
  # | __ )  __ _ ___  ___
  # |  _ \ / _` / __|/ _ \
  # | |_) | (_| \__ \  __/
  # |____/ \__,_|___/\___|

  class Sum
    def to_ascii
      x_ascii, x_ul = @x.to_ascii
      y_ascii, y_ul = @y.to_ascii
      x_ll = x_ascii.size - x_ul
      y_ll = y_ascii.size - y_ul

      x_ascii = CAS::Ascii.normalize_ascii x_ascii
      y_ascii = CAS::Ascii.normalize_ascii y_ascii

      ul, ll = [x_ul, y_ul].max, [x_ll, y_ll].max
      ret = Array.new (ul + ll), ""
      x_ascii.map.with_index do |l, i|
        ret[ul - x_ul + i] = l
      end
      ret = ret.map { |l| (l == "" ? (" " * x_ascii[0].size) : l) }
      y_ascii.map.with_index do |l, i|
        ret[ul - y_ul + i] += (i == y_ul ? " + " : "   ") + l
      end
      return ret, ul
    end
  end

  class Diff
    def to_ascii
      x_ascii, x_ul = @x.to_ascii
      y_ascii, y_ul = @y.to_ascii
      x_ll = x_ascii.size - x_ul
      y_ll = y_ascii.size - y_ul

      x_ascii = CAS::Ascii.normalize_ascii x_ascii
      y_ascii = CAS::Ascii.normalize_ascii y_ascii

      ul, ll = [x_ul, y_ul].max, [x_ll, y_ll].max
      ret = Array.new (ul + ll), ""
      x_ascii.map.with_index do |l, i|
        ret[ul - x_ul + i] = l
      end
      ret = ret.map { |l| (l == "" ? " " * x_ascii[0].size : l) }
      y_ascii.map.with_index do |l, i|
        ret[ul - y_ul + i] += (i == y_ul ? " − " : "   ") + l
      end
      return ret, ul
    end
  end

  class Prod
    def to_ascii
      x_ascii, x_ul = @x.to_ascii
      y_ascii, y_ul = @y.to_ascii
      x_ll = x_ascii.size - x_ul
      y_ll = y_ascii.size - y_ul

      x_ascii = CAS::Ascii.normalize_ascii x_ascii
      y_ascii = CAS::Ascii.normalize_ascii y_ascii

      ul, ll = [x_ul, y_ul].max, [x_ll, y_ll].max
      ret = Array.new (ul + ll), ""
      x_ascii.map.with_index do |l, i|
        ret[ul - x_ul + i] = l
      end
      ret = ret.map { |l| (l == "" ? " " * x_ascii[0].size : l) }
      y_ascii.map.with_index do |l, i|
        ret[ul - y_ul + i] += (i == y_ul ? " · " : "   ") + l
      end
      return ret, ul
    end
  end

  class Div
    def to_ascii
      x_ascii, _ = @x.to_ascii
      y_ascii, _ = @y.to_ascii

      x_ascii = CAS::Ascii.normalize_ascii x_ascii
      y_ascii = CAS::Ascii.normalize_ascii y_ascii
      displace = (x_ascii[0].size - y_ascii[0].size).abs / 2
      line = ""
      if x_ascii[0].size < y_ascii[0].size
        x_ascii = x_ascii.map { |l| (" " * displace) + l }
        line = "─" * y_ascii[0].size
      else
        y_ascii = y_ascii.map { |l| (" " * displace) + l }
        line = "─" * x_ascii[0].size
      end
      ret = x_ascii + [line] + y_ascii
      return ret, (x_ascii.size)
    end
  end

  class Pow
    def to_ascii
      x_ascii, x_baseline = @x.to_ascii
      y_ascii, _ = @y.to_ascii

      x_ascii = CAS::Ascii.normalize_ascii(x_ascii, self.to_ascii_x_vars_complexity)
      y_ascii = CAS::Ascii.normalize_ascii(y_ascii, self.to_ascii_y_vars_complexity)

      ret = []
      y_ascii.each  { |l| ret << (" " * x_ascii[0].size) + l }
      x_ascii.each  { |l| ret << l + (" " * y_ascii[0].size) }

      return ret, (y_ascii.size + x_baseline)
    end
  end

  class Invert
    def to_ascii
      x_ascii, x_bl = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii(x_ascii, (self.to_ascii_x_vars_complexity ? :complex : :simple))

      x_ascii = x_ascii.map.with_index { |l, i| (i == x_bl ? "-" : " ") + l }
      return x_ascii, x_bl
    end
  end

  class Sqrt
    def to_ascii
      x_ascii, x_bl = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii x_ascii

      ret = []
      ret << " ┌" + "─" * x_ascii[0].size
      x_ascii = x_ascii.map.with_index do |l, i|
        (i == (x_ascii.size - 1) ? "╭┤" : " │") + l
      end
      return (ret + x_ascii), (x_bl + 1)
    end
  end

  class Abs
    def to_ascii
      x_ascii, x_bl = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii x_ascii

      x_ascii = x_ascii.map { |l| "│" + l + "│" }
      return x_ascii, x_bl
    end
  end

  #  _____     _                                  _        _
  # |_   _| __(_) __ _ _ __   ___  _ __ ___   ___| |_ _ __(_) ___
  #   | || '__| |/ _` | '_ \ / _ \| '_ ` _ \ / _ \ __| '__| |/ __|
  #   | || |  | | (_| | | | | (_) | | | | | |  __/ |_| |  | | (__
  #   |_||_|  |_|\__, |_| |_|\___/|_| |_| |_|\___|\__|_|  |_|\___|
  #              |___/
  class Sin
    def to_ascii
      x_ascii, x_baseline = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii(x_ascii, (self.to_ascii_x_vars_complexity ? :complex : :simple))
      x_ascii = x_ascii.map.with_index do |l, i|
        (i == x_baseline ? "sin" : "   ") + l
      end

      return x_ascii, x_baseline
    end
  end

  class Cos
    def to_ascii
      x_ascii, x_baseline = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii(x_ascii, (self.to_ascii_x_vars_complexity ? :complex : :simple))
      x_ascii = x_ascii.map.with_index do |l, i|
        (i == x_baseline ? "cos" : "   ") + l
      end

      return x_ascii, x_baseline
    end
  end

  class Tan
    def to_ascii
      x_ascii, x_baseline = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii(x_ascii, (self.to_ascii_x_vars_complexity ? :complex : :simple))
      x_ascii = x_ascii.map.with_index do |l, i|
        (i == x_baseline ? "tan" : "   ") + l
      end

      return x_ascii, x_baseline
    end
  end

  class Asin
    def to_ascii
      x_ascii, x_baseline = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii(x_ascii, (self.to_ascii_x_vars_complexity ? :complex : :simple))
      x_ascii = x_ascii.map.with_index do |l, i|
        (i == x_baseline ? "arcsin" : "      ") + l
      end

      return x_ascii, x_baseline
    end
  end

  class Acos
    def to_ascii
      x_ascii, x_baseline = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii(x_ascii, (self.to_ascii_x_vars_complexity ? :complex : :simple))
      x_ascii = x_ascii.map.with_index do |l, i|
        (i == x_baseline ? "arccos" : "      ") + l
      end

      return x_ascii, x_baseline
    end
  end

  class Atan
    def to_ascii
      x_ascii, x_baseline = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii(x_ascii, (self.to_ascii_x_vars_complexity ? :complex : :simple))
      x_ascii = x_ascii.map.with_index do |l, i|
        (i == x_baseline ? "arctan" : "      ") + l
      end

      return x_ascii, x_baseline
    end
  end

  #  _____                                 _            _
  # |_   _| __ __ _ ___  ___ ___ _ __   __| | ___ _ __ | |_
  #   | || '__/ _` / __|/ __/ _ \ '_ \ / _` |/ _ \ '_ \| __|
  #   | || | | (_| \__ \ (_|  __/ | | | (_| |  __/ | | | |_
  #   |_||_|  \__,_|___/\___\___|_| |_|\__,_|\___|_| |_|\__|
  class Exp
    def to_ascii
      x_ascii, x_baseline = CAS::E.to_ascii
      y_ascii, _ = @x.to_ascii

      x_ascii = CAS::Ascii.normalize_ascii(x_ascii)
      y_ascii = CAS::Ascii.normalize_ascii(y_ascii, self.to_ascii_x_vars_complexity)

      ret = []
      y_ascii.each  { |l| ret << (" " * x_ascii.size) + l }
      x_ascii.each  { |l| ret << l + (" " * y_ascii.size) }

      return ret, (y_ascii.size + x_baseline)
    end
  end

  class Log
    def to_ascii
      x_ascii, x_baseline = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii(x_ascii, (self.to_ascii_x_vars_complexity ? :complex : :simple))
      x_ascii = x_ascii.map.with_index do |l, i|
        (i == x_baseline ? "log" : "   ") + l
      end

      return x_ascii, x_baseline
    end
  end

  #   ____                _ _ _   _
  #  / ___|___  _ __   __| (_) |_(_) ___  _ __
  # | |   / _ \| '_ \ / _` | | __| |/ _ \| '_ \
  # | |__| (_) | | | | (_| | | |_| | (_) | | | |
  #  \____\___/|_| |_|\__,_|_|\__|_|\___/|_| |_|
  class Condition
    def to_ascii
      x_ascii, x_ul = @x.to_ascii
      y_ascii, y_ul = @y.to_ascii
      x_ll = x_ascii.size - x_ul
      y_ll = y_ascii.size - y_ul

      x_ascii = CAS::Ascii.normalize_ascii x_ascii
      y_ascii = CAS::Ascii.normalize_ascii y_ascii

      ul, ll = [x_ul, y_ul].max, [x_ll, y_ll].max
      ret = Array.new (ul + ll), ""
      x_ascii.map.with_index do |l, i|
        ret[ul - x_ul + i] = l
      end
      ret = ret.map { |l| (l == "" ? " " * x_ascii[0].size : l) }
      y_ascii.map.with_index do |l, i|
        ret[ul - y_ul + i] += (i == y_ul ? " #{@cond_repr} " : "   ") + l
      end
      return ret, ul
    end

    def puts_ascii(offset=0)
      a, _, _ = self.to_ascii
      return a.map { |l| (" " * offset) + l }.join("\n")
    end

    def to_ascii_x_vars_complexity
      return (((@x.is_a? CAS::Variable) or (@x.is_a? CAS::Constant)) ? nil : :complex)
    end

    def to_ascii_y_vars_complexity
      return (((@y.is_a? CAS::Variable) or (@y.is_a? CAS::Constant)) ? nil : :complex)
    end
  end

  class BoxCondition
    def to_ascii
      cond_a = "#{@lower} #{@@lower_str} "
      cond_b = " #{@@upper_str} #{@upper}"

      x_ascii, x_bl = @x.to_ascii
      x_ascii = CAS::Ascii.normalize_ascii x_ascii
      x_ascii = x_ascii.map.with_index do |l, i|
        (i == x_bl ? cond_a : " " * cond_a.size ) + l + (i == x_bl ? cond_b : " " * cond_b.size )
      end

      return x_ascii, x_bl
    end
  end

  #  ____  _                        _
  # |  _ \(_) ___  ___ _____      _(_)___  ___
  # | |_) | |/ _ \/ __/ _ \ \ /\ / / / __|/ _ \
  # |  __/| |  __/ (_|  __/\ V  V /| \__ \  __/
  # |_|   |_|\___|\___\___| \_/\_/ |_|___/\___|
  class Piecewise
    #def to_ascii
    #  x_ascii, x_ul = @x.to_ascii
    #  y_ascii, y_ul = @y.to_ascii
    #  c_ascii, c_ul = @condition.to_ascii
    #  x_ascii = CAS::Ascii.normalize_ascii x_ascii
    #  y_ascii = CAS::Ascii.normalize_ascii y_ascii
    #  c_ascii = CAS::Ascii.normalize_ascii c_ascii
    #  label_a = "  for "
    #  label_b = "  otherwise"

    #  size =
    #  ret = []
    #  raise RuntimeError
    #  return [], 0
    #end
  end
end

if __FILE__ == $0
  x = CAS::vars :x
  f = CAS::exp(CAS::sin(x ** (2 ** x))) + CAS::cos(x)
  puts
  puts f.puts_ascii(3)
  puts
  puts (CAS::sqrt(2 + 1/(x+1))).puts_ascii(2)
  puts
  puts (-f/x + f).puts_ascii(3)
  puts
  puts CAS::abs(f.diff(x).simplify).puts_ascii(3)
  puts
  puts (f.smaller(f.diff(x).simplify)).puts_ascii(3)
  puts
  puts f.limit(1, 2).puts_ascii(3)
  puts
end
