source 'https://rubygems.org'

gemspec

gem 'jruby-openssl',	'~> 0.7', platforms: :jruby

# Ronin dependencies
gem 'ronin-support',     '~> 1.0', github: "ronin-rb/ronin-support",
                                   branch: '1.0.0'
gem 'ronin-web-server',  '~> 0.1', github: "ronin-rb/ronin-web-server",
                                   branch: 'main'

group :development do
  gem 'rake'
  gem 'rubygems-tasks', '~> 0.2'

  gem 'rspec',          '~> 3.0'
  gem 'simplecov',      '~> 0.20'

  gem 'kramdown',      '~> 2.0'
  gem 'kramdown-man',  '~> 0.1'

  gem 'redcarpet',       platform: :mri
  gem 'yard',           '~> 0.9'
  gem 'yard-spellcheck', require: false

  gem 'dead_end', require: false
end
