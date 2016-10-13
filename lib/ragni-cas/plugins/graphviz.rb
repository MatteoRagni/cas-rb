#!/usr/bin/env ruby

#   ___               _       _      ___ _           _
#  / __|_ _ __ _ _ __| |___ _(_)___ | _ \ |_  _ __ _(_)_ _
# | (_ | '_/ _` | '_ \ ' \ V / |_ / |  _/ | || / _` | | ' \
#  \___|_| \__,_| .__/_||_\_/|_/__| |_| |_|\_,_\__, |_|_||_|
#               |_|                            |___/

module CAS
  #   ___         _        _
  #  / __|___ _ _| |_ __ _(_)_ _  ___ _ _ ___
  # | (__/ _ \ ' \  _/ _` | | ' \/ -_) '_(_-<
  #  \___\___/_||_\__\__,_|_|_||_\___|_| /__/

  class Op
    # Return the local Graphviz node of the tree
    #
    #  * **returns**: `String` of local Graphiz node
    def dot_graph
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph}\n"
    end
  end

  class BinaryOp
    # Return the local Graphviz node of the tree
    #
    #  * **returns**: `String` of local Graphiz node
    def dot_graph
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph}\n  #{cls} -> #{@y.dot_graph}"
    end
  end

  class NaryOp
    # Return the local Graphviz node of the tree
    #
    #  * **returns**: `String` of local Graphiz node
    def dot_graph
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      ret = ""
      @x.each do |x|
        ret += "#{cls} -> #{x.dot_graph}\n"
      end
      return ret
    end
  end

  class Variable
    # Return the local Graphviz node of the tree
    #
    #  * **returns**: `String` of local Graphiz node
    def to_dot
      "#{@name}"
    end
  end

  class Constant
    # Return the local Graphviz node of the tree
    #
    #  * **returns**: `String` of local Graphiz node
    def to_dot
      "Const(#{@x})"
    end
  end

  class Piecewise
    # Convert piecewise function into a dot graphviz representation
    #
    #  * **returns**: `String`
    def dot_graph
      cls = "#{self.class.to_s.gsub("CAS::", "")}_#{self.object_id}"
      "#{cls} -> #{@x.dot_graph}\n  #{cls} -> #{@y.dot_graph}\n  #{cls} -> #{@condition.dot_graph}"
    end
  end

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

    dot_subs_hash = {
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

    lab = {}
    string.scan(/\w+\_\d+/) do |m|
      if m =~ /(\w+)\_\d+/
        lab[m] = dot_subs_hash[$1] || $1
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
end
