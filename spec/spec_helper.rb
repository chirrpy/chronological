require 'sqlite3'
require 'active_record'
require 'timecop'
require 'chronological'

Dir[File.expand_path('../support/**/*.rb',   __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.before(:all) do
    SQLite3::Database.new 'tmp/test.db'

    ActiveRecord::Base.establish_connection(
      :adapter  => 'sqlite3',
      :database => 'tmp/test.db'
    )

    class SetupTests < ActiveRecord::Migration
      def up
        create_table :chronologicables do |t|
          t.datetime :started_at_utc
          t.datetime :ended_at_utc
        end
      end
    end

    SetupTests.new.migrate(:up)
  end

  config.after(:all) do
    `rm -f ./tmp/test.db`
  end
end
