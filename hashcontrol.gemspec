require './lib/hash_control/version'

Gem::Specification.new do |gem|
  gem.name        = File.basename(ARGV[1], '.gemspec')
  gem.summary     = 'Conveniently validating and manipulating hash-like data.'
  gem.description = <<-END
      Provides some conveniences for validating and manipulating hash-like data.
    END

  gem.version     = ::HashControl::VERSION
  gem.date        = '2014-08-22'

  gem.homepage    = 'https://github.com/szhu/hashcontrol'
  gem.authors     = ['Sean Zhu']
  gem.email       = 'interestinglythere+code@gmail.com'
  gem.license     = 'MIT'

  gem.add_dependency 'activesupport', '~> 4.0'
  gem.files       = `git ls-files`.split($RS)
  gem.require_paths = ['lib']
end
