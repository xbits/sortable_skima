# coding: utf-8
#lib = File.expand_path('../lib', __FILE__)
#$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
#require 'layout_skima/version'

Gem::Specification.new do |spec|
  spec.name          = "sortable_skima"
  spec.version       = '0.2.0.25'
  spec.authors       = ["xbits"]
  spec.email         = ["joao.costaxl@gmail.com"]
  spec.summary       = "Skima.net sortable tables"
  spec.description   = "Adds sorting, filters and pagination to html tables. TESTING"
  spec.homepage      = "https://github.com/xbits/sortable_skima"
  spec.license       = "MIT"
  #spec.files         = `git ls-files -z`.split("\x0")
  #spec.files = Dir["lib/**/*"] + Dir["config/**/*"] + Dir["vendor/**/**/*"] + Dir["app/**/*"] + Dir["db/**/*"]
  spec.add_runtime_dependency "railties", ">= 6.0"
  spec.add_runtime_dependency "pagy", "~> 9.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "activerecord", ">= 6.0"
  spec.add_development_dependency "actionpack", ">= 6.0"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "selenium-webdriver"
  spec.extra_rdoc_files  = %w[README.md]
  spec.rdoc_options      = %w[--main README.md]
  spec.files = %w[README.md] + Dir['{lib,app}/**/*']
end

#desc 'Turn this plugin into a gem.'
#Rake::GemPackageTask.new(spec) do |pkg|
#  pkg.gem_spec = spec
#end
