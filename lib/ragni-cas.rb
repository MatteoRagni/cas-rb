#!/usr/bin/env ruby

require_relative 'op.rb'
require_relative 'numbers.rb'
require_relative 'fnc-base.rb'
require_relative 'fnc-trig.rb'
require_relative 'fnc-trsc.rb'

module CAS
  def self.to_dot(op)
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

  def self.export_dot(fl, op)
    File.open(fl, "w") do |f| f.puts CAS.to_dot(op) end
  end
end
