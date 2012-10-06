RSpec.configure do |config|
  config.after(:each, :timecop => true) do
    Timecop.return
  end
end
