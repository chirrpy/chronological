require 'sqlite3'
require 'active_record'
require 'timecop'
require 'chronological'

Dir[File.expand_path('../support/**/*.rb',   __FILE__)].each { |f| require f }

RSpec.configure do |config|
end
