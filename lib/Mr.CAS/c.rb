#!/usr/bin/env ruby

#   ___   ___ _           _
#  / __| | _ \ |_  _ __ _(_)_ _
# | (__  |  _/ | || / _` | | ' \
#  \___| |_| |_|\_,_\__, |_|_||_|
#                   |___/

module CAS
  module C_PLUGIN
    C_STD_LIBRARIES = [
      "math.h"
    ]

    C_LOCAL_LIBRARIES = [ ]

    C_DEFINES = {
      "M_PI"       => Math::PI.to_s,
      "M_INFINITY" => "HUGE_VAL",
      "M_E"        => Math::E.to_s,
      "M_EPSILON"  => (1E-16).to_s
    }

    def self.write_header(op, name)
      <<-TO_HEADER
#ifndef #{name}_HEADER
#define #{name}_HEADER

// Standard Libraries
#{ CAS::C_PLUGIN::C_STD_LIBRARIES.map { |e| "#include <#{e}>" }.join("\n") }

// Local Libraries
#{ CAS::C_PLUGIN::C_LOCAL_LIBRARIES.map { |e| "#include <#{e}>" }.join("\n") }

// Definitions
#{ CAS::C_PLUGIN::C_DEFINES.map { |k, v| "#define #{k} #{v}" }.join("\n") }

// Function
double #{name}(#{ op.args.map { |x| "double #{x.name}"}.join(", ") });

#endif // #{name}_HEADER
      TO_HEADER
    end

    def self.write_source(op, name)
      <<-TO_SOURCE
#include "#{name}.h"

double #{name}(#{ op.args.map { |x| "double #{x.name}"}.join(", ") }) {
  return #{op.to_c};
}
      TO_SOURCE
    end
  end

  {
    # Terminal nodes
    CAS::Constant              => Proc.new { "#{x}" },
    CAS::Variable              => Proc.new { "#{name}" },
    CAS::PI_CONSTANT           => Proc.new { "M_PI" },
    CAS::INFINITY_CONSTANT     => Proc.new { "M_INFINITY" },
    CAS::NEG_INFINITY_CONSTANT => Proc.new { "(-M_INFINITY)" },
    CAS::E_CONSTANT            => Proc.new { "M_E" },
    # Base functions
    CAS::Sum    => Proc.new { "(#{x.to_c} + #{y.to_c})" },
    CAS::Diff   => Proc.new { "(#{x.to_c} - #{y.to_c})" },
    CAS::Prod   => Proc.new { "(#{x.to_c} * #{y.to_c})" },
    CAS::Pow    => Proc.new { "pow(#{x.to_c}, #{y.to_c})" },
    CAS::Div    => Proc.new { "(#{x.to_c}) / (#{y.to_c} + )" },
    CAS::Sqrt   => Proc.new { "sqrt(#{x.to_c})" },
    CAS::Invert => Proc.new { "(-#{x.to_c})" },
    CAS::Abs    => Proc.new { "fabs(#{x.to_c})" },

    # Trigonometric functions
    CAS::Sin    => Proc.new { "sin(#{x.to_c})" },
    CAS::Asin   => Proc.new { "asin(#{x.to_c})" },
    CAS::Cos    => Proc.new { "cos(#{x.to_c})" },
    CAS::Acos   => Proc.new { "acos(#{x.to_c})" },
    CAS::Tan    => Proc.new { "tan(#{x.to_c})" },
    CAS::Atan   => Proc.new { "atan(#{x.to_c})" },

    # Trascendent functions
    CAS::Exp    => Proc.new { "exp(#{x.to_c})" },
    CAS::Ln     => Proc.new { "log(#{x.to_c})" },

    # Box Conditions
    CAS::BoxConditionOpen => Proc.new {
      ["double __t_#{x.object_id} = #{x.to_c};",
       "(__t_#{x.object_id} > #{lower.latex} && __t_#{x.object_id} < #{upper.latex})"]
    },
    CAS::BoxConditionUpperClosed => Proc.new {
      ["double __t_#{x.object_id} = #{x.to_c};",
       "(__t_#{x.object_id} > #{lower.latex} && __t_#{x.object_id} <= #{upper.latex})"]
    },
    CAS::BoxConditionLowerClosed => Proc.new {
      ["double __t_#{x.object_id} = #{x.to_c};",
       "(__t_#{x.object_id} >= #{lower.latex} && __t_#{x.object_id} < #{upper.latex})"]
    },
    CAS::BoxConditionClosed => Proc.new {
      ["double __t_#{x.object_id} = #{x.to_c};",
       "(__t_#{x.object_id} >= #{lower.latex} && __t_#{x.object_id} <= #{upper.latex})"]
    },

    # Conditions
    CAS::Equal        => Proc.new { "(#{x.to_c} == #{y.to_c})" },
    CAS::Smaller      => Proc.new { "(#{x.to_c} < #{y.to_c})" },
    CAS::Greater      => Proc.new { "(#{x.to_c} > #{y.to_c})" },
    CAS::SmallerEqual => Proc.new { "(#{x.to_c} <= #{y.to_c})" },
    CAS::GreaterEqual => Proc.new { "(#{x.to_c} >= #{y.to_c})" },

    # Piecewise
    CAS::Piecewise => Proc.new { raise CASError, "Not implemented yet" },
    CAS::Max       => Proc.new { raise CASError, "Not implemented yet" },
    CAS::Min       => Proc.new { raise CASError, "Not implemented yet" }
  }.each do |cls, blk|
    cls.send(:define_method, "to_c", &blk)
  end

  class Op
    def to_c_lib(name)
      CAS::Help.assert(name, String)
      [CAS::C_PLUGIN.write_header(self, name), CAS::C_PLUGIN.write_source(self, name)]
    end
  end

end
