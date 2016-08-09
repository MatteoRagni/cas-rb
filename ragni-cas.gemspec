#!/usr/bin/env ruby

changelog = File.expand_path('CHANGELOG', File.dirname(__FILE__))
changelog = (IO.readlines(changelog).map! { |l| l.chomp } - [""])[-1]

version_MAYOR = "0"
version_MINOR = "0"
version_PATCH = "0"

if changelog =~ /Version\s(\d+)\.(\d+)\.(\d+):/
  version_MAYOR = $1
  version_MINOR = $2
  version_PATCH = $3
end

VERSION = "#{version_MAYOR}.#{version_MINOR}.#{version_PATCH}"
version_rb = <<-EOV

#!/usr/bin/env ruby

module CAS
  VERSION = [#{version_MAYOR}, #{version_MINOR}, #{version_PATCH}]
end

EOV

File.open(File.expand_path('lib/version.rb', File.dirname(__FILE__)), "w") { |f| f.puts version_rb }

DATE = Time.new

Gem::Specification.new do |s|
  s.name = 'ragni-cas'
  s.version = VERSION
  s.date = "#{'%04d' % DATE.year}-#{'%02d' % DATE.month}-#{'%02d' % DATE.day}"
  s.summary = 'An extremely simple CAS, for rapid prototyping and meta-programming'
  s.authors = ['Matteo Ragni']
  s.email = 'info@ragni.me'
  s.files = [
    'lib/ragni-cas.rb',
    # Overloading
    'lib/overloading/fixnum.rb',
    'lib/overloading/float.rb',
    # Operators
    'lib/operators/op.rb',
    'lib/operators/bary-op.rb',
    'lib/operators/nary-op.rb',
    # Numbers
    'lib/numbers/constants.rb',
    'lib/numbers/variables.rb',
    # Functions
    'lib/functions/fnc-base.rb',
    'lib/functions/fnc-trig.rb',
    'lib/functions/fnc-trsc.rb',
    'lib/functions/fnc-conditions.rb',
    'lib/functions/fnc-box-conditions.rb',
    'lib/functions/fnc-piecewise.rb',
    # Versioning
    'lib/version.rb'
  ]
  s.homepage = 'https://github.com/MatteoRagni/cas-rb'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.0'

  s.cert_chain  = ['certs/MatteoRagni.pem']
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/
end
