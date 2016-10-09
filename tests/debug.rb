#!/usr/bin/env ruby

require_relative '../lib/ragni-cas.rb'
unless require 'pry-byebug'
  puts "Please install pry-byebug"
  exit 1
end

module CAS
  class Sin
    def simplify_debug
      #binding.pry
      self.simplify
    end
  end
end

if __FILE__ == $0
  puts (CAS::sin(CAS::Pi/2)).simplify_debug
end
