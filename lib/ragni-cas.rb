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

#  ___               _
# | _ \___ __ _ _  _(_)_ _ ___ ___
# |   / -_) _` | || | | '_/ -_|_-<
# |_|_\___\__, |\_,_|_|_| \___/__/
#            |_|

%w|operators/op.rb operators/bary-op.rb operators/nary-op.rb
   numbers/constants.rb numbers/variables.rb
   functions/fnc-base.rb functions/fnc-trig.rb functions/fnc-trsc.rb functions/fnc-branch.rb
   overloading/fixnum.rb overloading/float.rb
   version.rb|.each do |r|
  require File.expand_path(r, File.dirname(__FILE__))
end

module CAS

  # Return a string representation of the graph that is
  # a Graphviz tree. Requires a `CAS::Op` as argument.
  # In the next releases probably it will be moved inside
  # `CAS::Op`.
  # <- `CAS::Op` instance
  # -> `String`
  def self.to_dot(op)
    CAS::Help.assert(op, CAS::Op)

    node = {}
    string = op.dot_graph(node)
    labels = ""
    lab = {}

    string.scan(/\w+\_\d+/) do |m|
      if m =~ /(\w+)\_\d+/
        case $1
        when "Sum"
          l = "+"
        when "Diff"
          l = "-"
        when "Prod"
          l = "×"
        when "Div"
          l = "÷"
        when "Sqrt"
          l = "√(∙)"
        when "Abs"
          l = "|∙|"
        when "Invert"
          l = "-(∙)"
        when "Exp"
          l = "exp(∙)"
        when "Log"
          l = "log(∙)"
        when "Pow"
          l = "(∙)^(∙)"
        when "ZERO_CONSTANT"
          l = "0"
        when "ONE_CONSTANT"
          l = "1"
        when "TWO_CONSTANT"
          l = "2"
        when "PI_CONSTANT"
          l= "π"
        when "INFINITY_CONSTANT"
          l = "∞"
        when "E_CONSTANT"
          l = "e"
        when "MINUS_ONE_CONSTANT"
          l = "-1"
        else
          l = $1
        end
        lab[m] = l
      end
    end
    lab.each { |k, v| labels += "  #{k} [label=\"#{v}\"]\n" }

    return <<-EOG
digraph Op {
  #{string}#{labels}}
    EOG
  end

  # Export the input `CAS::Op` graphviz representation to a file.
  # <- `String` with filename
  # <- `CAS::Op` with the tree
  # -> `CAS::Op` in input
  def self.export_dot(fl, op)
    CAS::Help.assert(fl, String)
    CAS::Help.assert(op, CAS::Op)

    File.open(fl, "w") do |f| f.puts CAS.to_dot(op) end
    return op
  end


  # Support functions are in this separate Helper class
  module Help
    # Check input `obj.class` against a `type` class
    # raises an ArgumentError if check fails
    def self.assert(obj, type)
      raise ArgumentError, "required #{type}, received #{obj.class}" unless obj.is_a? type
    end
  end
end
