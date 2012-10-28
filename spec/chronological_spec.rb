require 'spec_helper'

class ChronologicableStrategyClass
  extend Chronological
end

describe Chronological do
  describe '.timeframe' do
    context 'when it is called with a symbol representing a strategy' do
      before do
        ChronologicableStrategyClass.class_eval do
          timeframe
        end
      end
    end
  end
end
