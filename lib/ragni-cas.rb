#!/usr/bin/env ruby

require_relative 'op.rb'
require_relative 'numbers.rb'
require_relative 'fnc-base.rb'
require_relative 'fnc-trig.rb'
require_relative 'fnc-trsc.rb'

module CAS
  def self.as_proc(obj, op)
    eval("Proc.new do |var|; #{op.to_code}; end")
  end
end
