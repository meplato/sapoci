# -*- encoding: utf-8 -*-
#require File.expand_path('../lib/sapoci', __FILE__)

extra_rdoc_files = ['CHANGELOG.md', 'LICENSE', 'README.md']

Gem::Specification.new do |s|
  s.name = 'sapoci'
  s.version = '0.3.5'
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ['Oliver Eilhard']
  s.description = %q{Ruby library and Rails plugin for punchout via SAP OCI protocol.}
  s.summary = %q{SAP OCI enables users to parse SAP OCI compliant data from online shops.}
  s.license = "MIT"
  s.email = ['oliver.eilhard@gmail.com']
  s.extra_rdoc_files = extra_rdoc_files
  s.homepage = 'http://github.com/meplato/sapoci'
  s.rdoc_options = ['--charset=UTF-8']
  s.required_ruby_version = '~> 2.2'
  s.require_paths = ['lib']
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files -- {bin,lib,spec}/*`.split("\n") + extra_rdoc_files
  s.test_files = `git ls-files -- {spec}/*`.split("\n")

  s.add_dependency("nokogiri", "~> 1.8.2", ">= 1.8.2")
  s.add_development_dependency("bundler", "~> 1.10")
  s.add_development_dependency("rdoc", "~> 3.12", ">= 3.12.1")
  s.add_development_dependency("rake", "~> 10.4")
end

