#!/usr/bin/env ruby

#   ___   ___ _           _
#  / __| | _ \ |_  _ __ _(_)_ _
# | (__  |  _/ | || / _` | | ' \
#  \___| |_| |_|\_,_\__, |_|_||_|
#                   |___/

module CAS
  module C_PLUGIN
    def define(k, v)
      raise ArgumentError "k must be a String, received a #{k.class}" unless k.is_a? String
      C_DEFINES[k] = v.to_s
      C_DEFINES
    end

    def undefine(k)
      C_DEFINES.delete k
      return C_DEFINES
    end

    def include(type, lib)
      raise ArgumentError "type must be a Symbol (:std, :local), received #{type}" unless [:std, :local].include? type
      raise ArgumentError "lib must be a String, received a #{lib.class}" unless lib.is_a? String
      C_LIBRARIES[type] << lib unless C_LIBRARIES[type].include? lib
    end

    C_DEFINES = {
      "M_PI"       => Math::PI.to_s,
      "M_INFINITY" => "HUGE_VAL",
      "M_E"        => Math::E.to_s,
      "M_EPSILON"  => (1E-16).to_s
    }

    #C_LIBRARIES {
    #  :std => ["math.h"],
    #  :local => []
    #}

    C_LOCAL_LIBRARIES = [ ] # TODO eliminare

    C_STD_LIBRARIES = [
      "math.h"
    ] # TODO eliminare

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
      c_op = op.to_c.sort_by { |k, v| v[:id] }

      <<-TO_SOURCE
#include "#{name}.h"

double #{name}(#{ op.args.map { |x| "double #{x.name}"}.join(", ") }) {
#{c_op.map { |e| "  double #{e[1][:var]} = #{e[1][:def]};"}.join("\n")}

  return #{c_op[-1][1][:var]}
}
      TO_SOURCE
    end
  end

  {
    # Terminal nodes
    CAS::Constant              => Proc.new { |_v| "#{@x}" },
    CAS::Variable              => Proc.new { |_v| "#{@name}" },
    CAS::PI_CONSTANT           => Proc.new { |_v| "M_PI" },
    CAS::INFINITY_CONSTANT     => Proc.new { |_v| "M_INFINITY" },
    CAS::NEG_INFINITY_CONSTANT => Proc.new { |_v| "(-M_INFINITY)" },
    CAS::E_CONSTANT            => Proc.new { |_v| "M_E" }
  }.each do |cls, blk|
    cls.send(:define_method, "__to_c", &blk)
  end.each do |cls, _blk|
    cls.send(:define_method, "to_c", &Proc.new do
      v = {}; self.__to_c(v); v
    end)
  end

  {
    # Base functions
    CAS::Sum    => Proc.new { |v| "(#{x.__to_c(v)} + #{y.__to_c(v)})" },
    CAS::Diff   => Proc.new { |v| "(#{@x.__to_c(v)} - #{@y.__to_c(v)})" },
    CAS::Prod   => Proc.new { |v| "(#{@x.__to_c(v)} * #{@y.__to_c(v)})" },
    CAS::Pow    => Proc.new { |v| "pow(#{@x.__to_c(v)}, #{@y.__to_c(v)})" },
    CAS::Div    => Proc.new { |v| "(#{@x.__to_c(v)}) / (#{@y.__to_c(v)} + )" },
    CAS::Sqrt   => Proc.new { |v| "sqrt(#{@x.__to_c(v)})" },
    CAS::Invert => Proc.new { |v| "(-#{@x.__to_c(v)})" },
    CAS::Abs    => Proc.new { |v| "fabs(#{@x.__to_c(v)})" },

    # Trigonometric functions
    CAS::Sin    => Proc.new { |v| "sin(#{@x.__to_c(v)})" },
    CAS::Asin   => Proc.new { |v| "asin(#{@x.__to_c(v)})" },
    CAS::Cos    => Proc.new { |v| "cos(#{@x.__to_c(v)})" },
    CAS::Acos   => Proc.new { |v| "acos(#{@x.__to_c(v)})" },
    CAS::Tan    => Proc.new { |v| "tan(#{@x.__to_c(v)})" },
    CAS::Atan   => Proc.new { |v| "atan(#{@x.__to_c(v)})" },

    # Trascendent functions
    CAS::Exp    => Proc.new { |v| "exp(#{@x.__to_c(v)})" },
    CAS::Ln     => Proc.new { |v| "log(#{@x.__to_c(v)})" },

    # # Box Conditions
    # CAS::BoxConditionOpen => Proc.new {
    #   ["double __t_#{x.object_id} = #{x.__to_c(v)};",
    #    "(__t_#{x.object_id} > #{lower.latex} && __t_#{x.object_id} < #{upper.latex})"]
    # },
    # CAS::BoxConditionUpperClosed => Proc.new {
    #   ["double __t_#{x.object_id} = #{x.__to_c(v)};",
    #    "(__t_#{x.object_id} > #{lower.latex} && __t_#{x.object_id} <= #{upper.latex})"]
    # },
    # CAS::BoxConditionLowerClosed => Proc.new {
    #   ["double __t_#{x.object_id} = #{x.__to_c(v)};",
    #    "(__t_#{x.object_id} >= #{lower.latex} && __t_#{x.object_id} < #{upper.latex})"]
    # },
    # CAS::BoxConditionClosed => Proc.new {
    #   ["double __t_#{x.object_id} = #{x.__to_c(v)};",
    #    "(__t_#{x.object_id} >= #{lower.latex} && __t_#{x.object_id} <= #{upper.latex})"]
    # },

    # Conditions
    # CAS::Equal        => Proc.new { "(#{x.__to_c(v)} == #{y.__to_c(v)})" },
    # CAS::Smaller      => Proc.new { "(#{x.__to_c(v)} < #{y.__to_c(v)})" },
    # CAS::Greater      => Proc.new { "(#{x.__to_c(v)} > #{y.__to_c(v)})" },
    # CAS::SmallerEqual => Proc.new { "(#{x.__to_c(v)} <= #{y.__to_c(v)})" },
    # CAS::GreaterEqual => Proc.new { "(#{x.__to_c(v)} >= #{y.__to_c(v)})" },
    # TODO there is no sense in exporting conditions in C...

    # Piecewise
    # CAS::Piecewise => Proc.new { raise CASError, "Not implemented yet" },
    # CAS::Max       => Proc.new { raise CASError, "Not implemented yet" },
    # CAS::Min       => Proc.new { raise CASError, "Not implemented yet" }
  }.each do |cls, blk|
    cls.send(:define_method, "__to_c_impl", &blk)
  end.each do |cls, _blk|
    cls.send(:define_method, "__to_c", &Proc.new do |v|
      sym = self.to_s.to_sym
      v[sym] = {
        :def => "#{self.__to_c_impl(v)}",
        :var => "__t_#{v.keys.size}",
        :id => v.keys.size
      } unless v[sym] # Pleas note that the order here is foundamental!
      v[sym][:var]
    end)
  end.each do |cls, _blk|
    cls.send(:define_method, "to_c", &Proc.new do
      v = {}; self.__to_c(v); v
    end)
  end

  class Op
    def to_c_lib(name)
      CAS::Help.assert(name, String)
      [CAS::C_PLUGIN.write_header(self, name), CAS::C_PLUGIN.write_source(self, name)]
    end
  end
end
