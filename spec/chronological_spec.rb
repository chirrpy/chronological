require 'spec_helper'

class ChronologicableStrategyClass
  extend Chronological
end

describe Chronological do
  describe '.timeframe' do
    context 'when it is called with a symbol representing a strategy' do
      before do
        ChronologicableStrategyClass.class_eval do
          timeframe :absolute,
                    start_utc:  :started_at_utc,
                    end_utc:    :ended_at_utc
        end
      end

      it 'is translated properly' do
        ChronologicableStrategyClass.class_variable_get(:@@chronological_strategy).should eql Chronological::AbsoluteStrategy
      end
    end

    context 'when it is called with a symbol that does not represent a strategy' do
      it 'it throws an error' do
        lambda do
          ChronologicableStrategyClass.class_eval do
            timeframe :grey_goose
          end
        end.should raise_error Chronological::UndefinedStrategy
      end
    end
  end
end
