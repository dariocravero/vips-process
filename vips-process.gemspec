# coding: utf-8
require File.expand_path('../lib/vips-process/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'vips-process'
  s.version       = Vips::Process::VERSION
  s.authors       = ['Darío Javier Cravero']
  s.email         = ['dario@uxtemple.com']
  s.summary       = %q{ruby-vips operation-oriented processing}
  s.description   = %q{Process your images with ruby-vips using an operation-oriented approach.}
  s.homepage      = 'https://github.com/dariocravero/vips-process'
  s.license       = 'MIT'
  s.files         = Dir['LICENSE', 'README.md', 'Rakefile', 'Gemfile', 'Gemfile.lock',
                        'vips-process.gemspec', 'lib/**/*.rb', 'test/*.rb']

  s.add_dependency              'ruby-vips',  '~> 0.3.9'
  s.add_development_dependency  'pry',        '~> 0.10.1'
  s.add_development_dependency  'cutest',     '~> 1.2.1'
  s.add_development_dependency  'bundler',    '~> 1.7'
  s.add_development_dependency  'rake',       '~> 10.0'
end
