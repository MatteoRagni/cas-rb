#!/usr/bin/env ruby

#  __  __      _   _      _      ___ _           _
# |  \/  |__ _| |_| |__ _| |__  | _ \ |_  _ __ _(_)_ _
# | |\/| / _` |  _| / _` | '_ \ |  _/ | || / _` | | ' \
# |_|  |_\__,_|\__|_\__,_|_.__/ |_| |_|\_,_\__, |_|_||_|
#                                          |___/

module CAS
  {
    # Terminal nodes
    CAS::Constant              => Proc.new { |_v| "#{x}", nil },
    CAS::Variable              => Proc.new { |_v| "#{name}", nil },
    CAS::PI_CONSTANT           => Proc.new { |_v| "pi", nil },
    CAS::INFINITY_CONSTANT     => Proc.new { |_v| "Inf", nil },
    CAS::NEG_INFINITY_CONSTANT => Proc.new { |_v| "(-Inf)", nil },
    CAS::E_CONSTANT            => Proc.new { |_v|
    },
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
    # CAS::BoxConditionOpen => Proc.new {
    #   ["double __t_#{x.object_id} = #{x.to_c};",
    #    "(__t_#{x.object_id} > #{lower.latex} && __t_#{x.object_id} < #{upper.latex})"]
    # },
    # CAS::BoxConditionUpperClosed => Proc.new {
    #   ["double __t_#{x.object_id} = #{x.to_c};",
    #    "(__t_#{x.object_id} > #{lower.latex} && __t_#{x.object_id} <= #{upper.latex})"]
    # },
    # CAS::BoxConditionLowerClosed => Proc.new {
    #   ["double __t_#{x.object_id} = #{x.to_c};",
    #    "(__t_#{x.object_id} >= #{lower.latex} && __t_#{x.object_id} < #{upper.latex})"]
    # },
    # CAS::BoxConditionClosed => Proc.new {
    #   ["double __t_#{x.object_id} = #{x.to_c};",
    #    "(__t_#{x.object_id} >= #{lower.latex} && __t_#{x.object_id} <= #{upper.latex})"]
    # },

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
    cls.send(:define_method, "__to_matlab", &blk)
  end

  class Op
    def to_c_lib(name)
      CAS::Help.assert(name, String)
      [CAS::C_PLUGIN.write_header(self, name), CAS::C_PLUGIN.write_source(self, name)]
    end
  end

end
