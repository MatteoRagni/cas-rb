require 'rdoc/task'
require 'rake/clean'


module Support
  def self.list_gems
    fh = {}
    (Dir["*.gem"]).each do |f|
      if f =~ /(.+)-(\d+\.\d+\.\d+)\.gem/
        fh[$1] = [] unless fh[$1]
        fh[$1] << $2
      end
    end
    return fh
  end

  def self.gem_last_version
    fh = Support.list_gems
    fh.keys.each do |k|
      yield "#{k}-#{(fh[k].sort)[-1]}.gem"
    end
  end
end


RDoc::Task.new do |rdoc|
  rdoc.main = "README.doc"
  rdoc.rdoc_dir ="./doc"
  rdoc.rdoc_files.include(
    "README.md", "lib/*.rb", "lib/*/*.rb")
  rdoc.options << "--markup" << "markdown"
  rdoc.options << "--all"
end

CLEAN << Dir["*.gem"]
desc "Build local gems file"
task :build do
  (Dir["*.gemspec"]).each do |gs|
    `gem build #{gs}`
  end
end

desc "Install last version of the compiled gem"
task :install do
  Support.gem_last_version do |g|
    puts "Installing gem: #{g}"
    `gem install #{g}`
  end
end

desc "Publish last version of the compiled gem"
task :publish => [:build, :install] do
  Support.gem_last_version do |g|
    puts "New commit for gem: #{g}"
    `echo git add .`
    `echo git commit -m \"publishing version: #{g}\"`

    puts "Pushing gem: #{g}"
    `echo gem push #{g}`
  end
end

desc "Locally deploy the gem (build and install)"
task :deploy => [:rdoc, :build, :install] do
  puts "Deployed"
end
