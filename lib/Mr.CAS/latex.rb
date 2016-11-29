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

#  _        _____ ____      ___ _           _
# | |   __ |_   _|__ /_ __ | _ \ |_  _ __ _(_)_ _
# | |__/ _` || |  |_ \ \ / |  _/ | || / _` | | ' \
# |____\__,_||_| |___/_\_\ |_| |_|\_,_\__, |_|_||_|
#                                     |___/

module CAS
  {
    # Terminal nodes
    CAS::Constant              => Proc.new { "#{x}" },
    CAS::Variable              => Proc.new { "#{name}" },
    CAS::PI_CONSTANT           => Proc.new { "\\pi" },
    CAS::INFINITY_CONSTANT     => Proc.new { "\\infty" },
    CAS::NEG_INFINITY_CONSTANT => Proc.new { "-\\infty" },
    # Base functions
    CAS::Sum    => Proc.new { "\\left( #{x.latex} + #{y.latex} \\right)" },
    CAS::Diff   => Proc.new { "\\left( #{x.latex} - #{y.latex} \\right)" },
    CAS::Prod   => Proc.new { "\\left( #{x.latex} \\, #{y.latex} \\right)"},
    CAS::Pow    => Proc.new { "{#{x.latex}}^{#{y.latex}}" },
    CAS::Div    => Proc.new { "\\dfrac{#{x.latex}}{#{y.latex}}" },
    CAS::Sqrt   => Proc.new { "\\sqrt{#{x.latex}}" },
    CAS::Invert => Proc.new { "-#{x.latex}" },
    CAS::Abs    => Proc.new { "\\left| #{}{x.latex} \\right|" },

    # Trigonometric functions
    CAS::Sin    => Proc.new { "\\sin \\left( #{x.latex} \\right)" },
    CAS::Asin   => Proc.new { "\\arcsin \\left( #{x.latex} \\right)" },
    CAS::Cos    => Proc.new { "\\cos \\left( #{x.latex} \\right)" },
    CAS::Acos   => Proc.new { "\\arccos \\left( #{x.latex} \\right)" },
    CAS::Tan    => Proc.new { "\\tan \\left( #{x.latex} \\right)" },
    CAS::Atan   => Proc.new { "\\arctan \\left( #{x.latex} \\right)" },

    # Trascendent functions
    CAS::Exp    => Proc.new { "e^#{x.latex}" },
    CAS::Ln     => Proc.new { "\\log \\left( #{x.latex} \\right)" },

    # Box Conditions
    CAS::BoxConditionOpen        => Proc.new { "#{lower.latex} < #{x.latex} < #{upper.latex}" },
    CAS::BoxConditionClosed      => Proc.new { "#{lower.latex} \\leq #{x.latex} \\leq #{upper.latex}" },
    CAS::BoxConditionUpperClosed => Proc.new { "#{lower.latex} < #{x.latex} \\leq #{upper.latex}" },
    CAS::BoxConditionLowerClosed => Proc.new { "#{lower.latex} \\leq #{x.latex} < #{upper.latex}" },

    # Conditions
    CAS::Equal        => Proc.new { "#{x.latex} = #{y.latex}" },
    CAS::Smaller      => Proc.new { "#{x.latex} < #{y.latex}" },
    CAS::Greater      => Proc.new { "#{x.latex} > #{y.latex}" },
    CAS::SmallerEqual => Proc.new { "#{x.latex} \\leq #{y.latex}" },
    CAS::GreaterEqual => Proc.new { "#{x.latex} \\geq #{y.latex}" },

    # Piecewise
    CAS::Piecewise => Proc.new {
      "\\left\\{ " +
      "  \\begin{array}{lr} " +
      "    #{x.latex} & #{condition.latex} \\\\" +
      "    #{y.latex}" +
      "  \\end{array}" +
      "\\right."
    },
    CAS::Max => Proc.new { "\\max \\left( #{x.latex}, \\, #{y.latex} \\right)" },
    CAS::Min => Proc.new { "\\min \\left( #{x.latex}, \\, #{y.latex} \\right)" }


  }.each do |cls, blk|
    cls.send(:define_method, "to_latex", &blk)
  end
end
