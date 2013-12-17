source 'https://rubygems.org'

# specify ruby version as heroku told so
ruby '2.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'
gem 'bootstrap-sass', '~>2.0.0'


group :development, :test do
  # Use postgressql as the database for Active Record
  gem 'pg', '0.15.1'

  # used by rspec to automate testing
    gem 'guard-rspec', '0.5.5'

  # Use rspec as the test framework
  gem 'rspec-rails', '~>2.14.0'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 4.0.0'
  # Use CoffeeScript for .js.coffee assets and views
  gem 'coffee-rails', '~> 4.0.0'
  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'
end

group :test do
  gem 'capybara', '1.1.2'
    gem 'rb-fsevent', '~> 0.9.1', :require => false
  gem 'growl', '1.0.3'
end

group :production do
  gem 'pg', '0.15.1'
  gem 'rails_12factor'
end


# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
