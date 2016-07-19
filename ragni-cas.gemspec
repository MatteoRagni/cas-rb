Gem::Specifications.new do |s|
  s.name = 'ragni-cas'
  s.version = '0.1.0'
  s.date = '2016-07-19'
  s.summary = 'An extremely simple CAS system for my optimizers'
  s.authors = ['Matteo Ragni']
  s.email = 'info@ragni.me'
  s.files = [
    'lib/cas.rb',
    'lib/op.rb',
    'lib/numbers.rb',
    'lib/fnc-base.rb',
    'lib/fnc-trig.rb',
    'lib/fnc-trsc.rb'
  ]
  s.homepage = 'https://github.com/MatteoRagni/cas-rb'
  s.license = 'MIT'

  s.cert_chain  = ['certs/MatteoRagni.pem']
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/
end
