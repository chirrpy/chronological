postgres_connection_options = {
  :adapter      => 'postgresql',
  :host         => 'localhost',
  :database     => 'chronological',
  :username     => ENV['USER'],
  :min_messages => 'warning',
  :encoding     => 'utf8' }

ActiveRecord::Base.establish_connection       postgres_connection_options.merge(
                                                :database           => 'postgres',
                                                :schema_search_path => 'public')

ActiveRecord::Base.connection.drop_database   postgres_connection_options[:database] rescue nil
ActiveRecord::Base.connection.create_database postgres_connection_options[:database]

ActiveRecord::Base.establish_connection       postgres_connection_options

ActiveRecord::Base.connection.create_table :chronologicable_strategy_classes do |t|
  t.datetime :started_at
  t.datetime :ended_at
end

ActiveRecord::Base.connection.create_table :base_chronologicables do |t|
  t.datetime :started_at
  t.datetime :ended_at
end

ActiveRecord::Base.connection.create_table :relative_chronologicables do |t|
  t.integer  :starting_offset
  t.integer  :ending_offset
  t.datetime :base_datetime_utc
end

ActiveRecord::Base.connection.create_table :relative_chronologicable_with_time_zones do |t|
  t.integer  :starting_offset
  t.integer  :ending_offset
  t.datetime :base_datetime_utc
  t.string   :time_zone
end

ActiveRecord::Base.connection.create_table :absolute_chronologicables do |t|
  t.datetime :started_at_utc
  t.datetime :ended_at_utc
end

ActiveRecord::Base.connection.create_table :absolute_chronologicable_with_time_zones do |t|
  t.datetime :started_at_utc
  t.datetime :ended_at_utc
  t.string   :time_zone
end

RSpec.configure do |config|
  config.before(:each) do
    ActiveRecord::Base.connection.execute 'DELETE FROM chronologicable_strategy_classes'
    ActiveRecord::Base.connection.execute 'DELETE FROM base_chronologicables'
    ActiveRecord::Base.connection.execute 'DELETE FROM relative_chronologicables'
    ActiveRecord::Base.connection.execute 'DELETE FROM relative_chronologicable_with_time_zones'
    ActiveRecord::Base.connection.execute 'DELETE FROM absolute_chronologicables'
    ActiveRecord::Base.connection.execute 'DELETE FROM absolute_chronologicable_with_time_zones'
  end
end
