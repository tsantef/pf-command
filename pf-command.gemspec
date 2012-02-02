# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pf-command/version"

Gem::Specification.new do |s|
  s.name        = %q{pf-command}
  s.version     = Pf::Command::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tim Santeford"]
  s.email       = ["tim@phpfog.com"]
  s.homepage    = %q{http://www.phpfog.com}
  s.default_executable = %q{pf}
  s.summary     = %q{Command line interface for PHP Fog}
  s.description = %q{Allows users to mange their PHP Fog accounts from the command line}

  s.rubyforge_project = "pf-command"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
end
