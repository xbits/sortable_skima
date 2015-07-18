# coding: utf-8
#lib = File.expand_path('../lib', __FILE__)
#$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
#require 'layout_skima/version'

Gem::Specification.new do |spec|
  spec.name          = "sortable_skima"
  spec.version       = '0.2.0.23'
  spec.authors       = ["xbits"]
  spec.email         = ["joao.costaxl@gmail.com"]
  spec.summary       = "Skima.net sortable tables"
  spec.description   = "Adds sorting, filters and pagination to html tables. testing"
  spec.homepage      = "http://skima.net"
  spec.license       = "MIT"
  #spec.files         = `git ls-files -z`.split("\x0")
  #spec.files = Dir["lib/**/*"] + Dir["config/**/*"] + Dir["vendor/**/**/*"] + Dir["app/**/*"] + Dir["db/**/*"]

  spec.has_rdoc          = true
  spec.extra_rdoc_files  = %w[README.rdoc]
  spec.rdoc_options      = %w[--main README.rdoc]
  spec.files = %w[README.rdoc] + Dir['{lib,config,app,db,doc}/**/*'] + Dir["vendor/**/**/*"]
  spec.post_install_message =
        "sortable: Skima.net  is da bomb!! "+
    "\n ---->REMEMBER TO CREATE BOTH MIGRATIONS Sortable AND Backtrace <---"+
    "\n Ex: ========================================="
    "\n   create_table :sortables do |t|"+
    "\n     t.text :query"+
    "\n     t.timestamps"+
    "\n   end"+
    "\n   create_table :backtraces do |t|"+
    "\n     t.integer  :user_id"+
    "\n     t.string   :action"+
    "\n     t.string   :value"+
    "\n     t.timestamps"+
    "\n   end"+
    "\n ============================================="


 # spec.add_dependency "sprockets"
end

#desc 'Turn this plugin into a gem.'
#Rake::GemPackageTask.new(spec) do |pkg|
#  pkg.gem_spec = spec
#end
