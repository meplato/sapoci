# -*- encoding: utf-8 -*-
#require File.expand_path('../lib/sapoci', __FILE__)

extra_rdoc_files = ['CHANGELOG.md', 'LICENSE', 'README.md']

Gem::Specification.new do |s|
  s.name = 'sapoci'
  s.version = '0.5.2'
  s.summary = %q{SAP OCI enables users to parse SAP OCI compliant data from online shops.}
  s.description = %q{Ruby library and Rails plugin for punchout via SAP OCI protocol.}
  s.authors = ['Oliver Eilhard']
  s.email = ['oliver.eilhard@gmail.com']
  s.license = "MIT"
  s.extra_rdoc_files = extra_rdoc_files
  s.homepage = 'http://github.com/meplato/sapoci'
  s.rdoc_options = ['--charset=UTF-8']
  s.required_ruby_version = '>= 2.6'
  s.require_paths = ['lib']
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files -- {bin,lib,spec}/*`.split("\n") + extra_rdoc_files
  s.test_files = `git ls-files -- {spec}/*`.split("\n")

  s.add_dependency("nokogiri", "~> 1.11.4")
  s.add_development_dependency("bundler", "~> 2.2.17")
  s.add_development_dependency("rdoc", "~> 6.3.1")
  s.add_development_dependency("rake", "~> 13.0.3")
end
