require 'sqlite3'
require 'active_record'
require 'timecop'
require 'chronological'

Dir[File.expand_path('../support/**/*.rb',   __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    SQLite3::Database.new 'tmp/test.db'

    ActiveRecord::Base.establish_connection(
      :adapter  => 'sqlite3',
      :database => 'tmp/test.db'
    )

    class SetupTests < ActiveRecord::Migration
      def up
        create_table :base_chronologicables do |t|
          t.datetime :started_at
          t.datetime :ended_at
        end

        create_table :relative_chronologicables do |t|
          t.integer  :starting_offset
          t.integer  :ending_offset
          t.datetime :base_datetime_utc
        end

        create_table :absolute_chronologicables do |t|
          t.datetime :started_at_utc
          t.datetime :ended_at_utc
        end

        create_table :chronologicable_with_time_zones do |t|
          t.datetime :started_at_utc
          t.datetime :ended_at_utc
          t.string   :time_zone
        end
      end
    end

    SetupTests.new.migrate(:up)
  end

  config.before(:each) do
    ActiveRecord::Base.connection.execute 'DELETE FROM relative_chronologicables'
    ActiveRecord::Base.connection.execute 'DELETE FROM absolute_chronologicables'
    ActiveRecord::Base.connection.execute 'DELETE FROM chronologicable_with_time_zones'
  end

  config.after(:suite) do
    `rm -f ./tmp/test.db`
  end
end
