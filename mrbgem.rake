#!/usr/bin/env mruby

require File.expand_path("lib/version.rb", File.dirname(__FILE__))

MRuby::Gem::Specification.new('ragni-cas') do |s|
  s.authors  = ['Matteo Ragni']
  s.summary = 'An extremely simple CAS, for rapid prototyping and meta-programming'
  s.license = 'MIT'
  s.version = CAS::VERSION.join(".")
  spec.add_dependency('mruby-pcre', '>= 0.0.0', :github => 'mattn/mruby-uv')
end
