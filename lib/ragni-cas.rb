#!/usr/bin/env ruby

# ragni-cas
# A very simple CAS engine with encapsuled graph
# representation. This will make impossible to
# perform complex high level simplifications, but
# it is powerful enough to define simple algorithm
# in a symbolic way.
#
# Mathematically, this is an implementation of the
# forward chain rule for automatic differentiaition.
# Each function is a container of function and the
# derivation is in the form:
#
# ```
#   d(f(g(x))
#   --------- = g'(x) * f'(g(x))
#      dx
# ```
#
# Author:: Matteo Ragni (mailto:info@ragni.me)
# Copyright:: Copyright (c) 2016 Matteo Ragni
# License:: Distributed under MIT license terms

module CAS

  # Return a string representation of the graph that is
  # a Graphviz tree. Requires a `CAS::Op` as argument.
  # In the next releases probably it will be moved inside
  # `CAS::Op`.
  #
  #  * **argument**: `CAS::Op` instance
  #  * **returns**: `String`
  def self.to_dot(op)
    CAS::Help.assert(op, CAS::Op)
    string = op.dot_graph
    labels = ""

    lab = {}
    string.scan(/\w+\_\d+/) do |m|
      if m =~ /(\w+)\_\d+/
        lab[m] = ($dot_subs_hash[$1] ? $dot_subs_hash[$1] : $1)
      end
    end
    lab.each { |k, v| labels += "  #{k} [label=\"#{v}\"]\n" }

    return "digraph Op {\n  #{string}#{labels}}"
  end

  # Export the input `CAS::Op` graphviz representation to a file.
  #
  #  * **argument**: `String` with filename
  #  * **argument**: `CAS::Op` with the tree
  #  * **returns**: `CAS::Op` in input
  def self.export_dot(fl, op)
    CAS::Help.assert(fl, String)
    CAS::Help.assert(op, CAS::Op)

    File.open(fl, "w") do |f| f.puts CAS.to_dot(op) end
    return op
  end
  $dot_subs_hash = {
    "Sum"                => "+",
    "Diff"               => "-",
    "Prod"               => "×",
    "Div"                => "÷",
    "Sqrt"               => "√(∙)",
    "Abs"                => "|∙|",
    "Invert"             => "-(∙)",
    "Exp"                => "exp(∙)",
    "Log"                => "log(∙)",
    "Pow"                => "(∙)^(∙)",
    "ZERO_CONSTANT"      => "0",
    "ONE_CONSTANT"       => "1",
    "TWO_CONSTANT"       => "2",
    "PI_CONSTANT"        => "π",
    "INFINITY_CONSTANT"  => "∞",
    "E_CONSTANT"         => "e",
    "MINUS_ONE_CONSTANT" => "-1"
  }

  # Support functions are in this separate Helper class
  module Help
    # Check input `obj.class` against a `type` class
    # raises an ArgumentError if check fails
    def self.assert(obj, type)
      raise ArgumentError, "required #{type}, received #{obj.class}" unless obj.is_a? type
    end
  end
end

#  ___               _
# | _ \___ __ _ _  _(_)_ _ ___ ___
# |   / -_) _` | || | | '_/ -_|_-<
# |_|_\___\__, |\_,_|_|_| \___/__/
#            |_|

%w|operators/op.rb operators/bary-op.rb operators/nary-op.rb
   numbers/constants.rb numbers/variables.rb
   functions/fnc-base.rb functions/fnc-trig.rb functions/fnc-trsc.rb
   functions/fnc-conditions.rb functions/fnc-box-conditions.rb functions/fnc-piecewise.rb
   overloading/fixnum.rb overloading/float.rb
   version.rb|.each do |r|
  require File.expand_path(r, File.dirname(__FILE__))
end

module CAS
  CAS::NumericToConst[(-Math::PI)] = (-CAS::Pi)
  CAS::NumericToConst[(-Math::E) ] = (-CAS::E)
  CAS::NumericToConst[(-1.0/0.0)]  = (CAS::NegInfinity)
end
