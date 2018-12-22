$LOAD_PATH.unshift 'lib'

APPLICATION_ENV = ENV.fetch('APPLICATION_ENV', 'development')

require 'bundler'
Bundler.require(:default, APPLICATION_ENV)

if defined?(Dotenv)
  dotenv_file = ".env.#{ APPLICATION_ENV }"
  if File.exist? dotenv_file
    puts "dotenev: Loading variables from #{ dotenv_file }"
    Dotenv.load(".env.#{ APPLICATION_ENV }")
  else
    puts "dotenv: #{ dotenv_file } not existing, skipping."
  end
else
  puts 'dotenv: Not available, skipping.'
end

# Provides required configuration, eg Issola persistence.
require 'larry/config'

# Ignore all uninitialized instance variable warnings
Warning.ignore(/instance variable @\w+ not initialized/)

Dotenv.load(".env.#{ APPLICATION_ENV }") if ['development', 'testing'].include? APPLICATION_ENV

require 'larry'
