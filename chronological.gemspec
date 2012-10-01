# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'chronological/version'

Gem::Specification.new do |s|
  s.rubygems_version      = '1.3.5'

  s.name                  = 'chronological'
  s.rubyforge_project     = 'chronological'

  s.version               = Chronological::VERSION
  s.platform              = Gem::Platform::RUBY

  s.authors               = %w{jfelchner m5rk}
  s.email                 = 'support@chirrpy.com'
  s.date                  = Date.today
  s.homepage              = 'https://github.com/chirrpy/chronological'

  s.summary               = %q{Easy Accessors for ActiveModel Objects}
  s.description           = %q{}

  s.rdoc_options          = ["--charset = UTF-8"]
  s.extra_rdoc_files      = %w[README.md LICENSE]

  #= Manifest =#
  s.executables           = Dir["{bin}/**/*"]
  s.files                 = Dir["{app,config,db,lib}/**/*"] + %w{Rakefile README.md}
  s.test_files            = Dir["{test,spec,features}/**/*"]
  s.require_paths         = ["lib"]
  #= Manifest =#
end
