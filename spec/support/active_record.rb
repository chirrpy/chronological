test_db_root = File.expand_path('../../../tmp/', __FILE__)
Dir.mkdir test_db_root unless Dir.exists? test_db_root

SQLite3::Database.new "#{test_db_root}/test.db"

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => 'tmp/test.db'
)

ActiveRecord::Base.connection.create_table :base_chronologicables do |t|
  t.datetime :started_at
  t.datetime :ended_at
end

ActiveRecord::Base.connection.create_table :relative_chronologicables do |t|
  t.integer  :starting_offset
  t.integer  :ending_offset
  t.datetime :base_datetime_utc
end

ActiveRecord::Base.connection.create_table :absolute_chronologicables do |t|
  t.datetime :started_at_utc
  t.datetime :ended_at_utc
end

ActiveRecord::Base.connection.create_table :chronologicable_with_time_zones do |t|
  t.datetime :started_at_utc
  t.datetime :ended_at_utc
  t.string   :time_zone
end

RSpec.configure do |config|
  config.before(:each) do
    ActiveRecord::Base.connection.execute 'DELETE FROM base_chronologicables'
    ActiveRecord::Base.connection.execute 'DELETE FROM relative_chronologicables'
    ActiveRecord::Base.connection.execute 'DELETE FROM absolute_chronologicables'
    ActiveRecord::Base.connection.execute 'DELETE FROM chronologicable_with_time_zones'
  end

  config.after(:suite) do
    `rm -f ./tmp/test.db`
  end
end
