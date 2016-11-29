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

# Copyright (c) 2016 Matteo Ragni
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

module CAS
  # Version of the library
  # Array of three `Fixnum` values:
  #
  #  * Major version
  #  * Minor version
  #  * Patchlevel
  VERSION = [#{version_MAYOR}, #{version_MINOR}, #{version_PATCH}]
end

EOV

File.open(File.expand_path('lib/version.rb', File.dirname(__FILE__)), "w") { |f| f.puts version_rb }

DATE = Time.new

Gem::Specification.new do |s|
  s.name = 'Mr.CAS'
  s.version = VERSION
  s.date = "#{'%04d' % DATE.year}-#{'%02d' % DATE.month}-#{'%02d' % DATE.day}"
  s.summary = 'A Minimalistic Ruby CAS, for rapid prototyping and meta-programming'
  s.authors = ['Matteo Ragni']
  s.email = 'info@ragni.me'
  s.files = Dir["lib/**/**"]
  s.homepage = 'https://github.com/MatteoRagni/cas-rb'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.0'

  s.cert_chain  = ['certs/MatteoRagni.pem']
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/
end
