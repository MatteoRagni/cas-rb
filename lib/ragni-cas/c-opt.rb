#!/usr/bin/env ruby

#   ___   ___ _           _
#  / __| | _ \ |_  _ __ _(_)_ _
# | (__  |  _/ | || / _` | | ' \
#  \___| |_| |_|\_,_\__, |_|_||_|
#                   |___/

require 'pry'

module CAS
  class CLib < Hash
    def self.create(name, &blk)
      a = CLib.new(name)
      a.instance_eval(&blk)
      return a
    end

    def initialize(name)
      raise ArgumentError, "Name for the library undefined" unless name.is_a? String
      @name            = name
      @define          = {}
      @include         = {}
      @include[:std]   = []
      @include[:local] = []
      @type            = "double"

      # Default definitions
      self.define "M_PI", Math::PI
      self.define "M_INFINITY","HUGE_VAL"
      self.define "M_E", Math::E
      self.define "M_EPSILON", 1E-16

      # Default inclusions
      self.include "math.h"
    end

    def as_double;   @type = "double";   end
    def as_float;    @type = "float";    end
    def as_int;      @type = "int";      end
    def as_long_int; @type = "long int"; end

    def define(k, v)
      raise ArgumentError, "k must be a String, received a #{k.class}" unless k.is_a? String
      @define[k] = v.to_s
      @define
    end

    def undefine(k)
      @define.delete k
      return @define
    end

    def include_type(type, lib)
      raise ArgumentError, "type must be a Symbol (:std, :local), received #{type}" unless [:std, :local].include? type
      raise ArgumentError, "lib must be a String, received a #{lib.class}" unless lib.is_a? String
      @include[type] << lib unless @include[type].include? lib
    end
    def include(lib); self.include_type(:std, lib); end
    def include_local(lib); self.include_type(:local, lib); end

    def implements_as(name, op); self[name] = op; end

    def header
      <<-TO_HEADER
// Header file for library: #{@name}.c

#ifndef #{@name}_H
#define #{@name}_H

// Standard Libraries
#{ @include[:std].map { |e| "#include <#{e}>" }.join("\n") }

// Local Libraries
#{ @include[:local].map { |e| "#include \"#{e}\"" }.join("\n") }

// Definitions
#{ @define.map { |k, v| "#define #{k} #{v}" }.join("\n") }

// Functions
#{
  self.keys.map do |fname|
    "#{@type} #{fname}(#{ self[fname].args.map { |x| "#{@type} #{x.name}" }.join(", ")});"
  end.join("\n")
}

#endif // #{@name}_H
      TO_HEADER
    end

    def source
      functions = []

      self.each do |fname, op|
        c_op = op.to_c.sort_by { |_k, c| c[:id] }
        nf = <<-NEWFUNCTION
#{@type} #{fname}(#{ op.args.map { |x| "#{@type} #{x.name}" }.join(", ")}) {
#{c_op.map { |e| "  double #{e[1][:var]} = #{e[1][:def]};"}.join("\n")}

  return #{c_op[-1][1][:var]};
}
NEWFUNCTION
        functions << nf
      end

      <<-TO_SOURCE
// Source file for library: #{@name}.c

#include "#{@name}.h"

#{functions.join("\n")}
// end of #{@name}.c
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
    CAS::Sum    => Proc.new { |v| "(#{@x.__to_c(v)} + #{@y.__to_c(v)})" },
    CAS::Diff   => Proc.new { |v| "(#{@x.__to_c(v)} - #{@y.__to_c(v)})" },
    CAS::Prod   => Proc.new { |v| "(#{@x.__to_c(v)} * #{@y.__to_c(v)})" },
    CAS::Pow    => Proc.new { |v| "pow(#{@x.__to_c(v)}, #{@y.__to_c(v)})" },
    CAS::Div    => Proc.new { |v| "(#{@x.__to_c(v)}) / (#{@y.__to_c(v)} + M_EPSILON)" },
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
    CAS::Function    => Proc.new { |v| "#{@c_name}(#{@x.map {|e| e.__to_c(v)}.join(", ")})" }
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

  class Function
    def c_name=(s)
      CAS::Help.assert_name s
      @c_name = s
    end

    def Function.new(name, *xs)
      super
      @c_name = name
    end
  end
  Function.list.each do |k, v| v.c_name = k; end
end
