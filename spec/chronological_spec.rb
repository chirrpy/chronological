require 'spec_helper'

class ChronologicableStrategyClass < ActiveRecord::Base
  extend Chronological
end

describe Chronological do
  describe '.timeframe' do
    context 'when it is called with a symbol representing a strategy' do
      before do
        ChronologicableStrategyClass.class_eval do
          timeframe type:       :absolute
        end
      end

      let(:chronologicable) { ChronologicableStrategyClass.new }

      pit 'is translated properly' do
        ChronologicableStrategyClass.class_variable_get(:@@chronological_strategy).should eql Chronological::AbsoluteStrategy
      end

      it { chronologicable.should respond_to :scheduled? }
      it { chronologicable.should respond_to :partially_scheduled? }
      it { chronologicable.should respond_to :inactive? }
      it { chronologicable.should respond_to :in_progress? }
      it { chronologicable.should respond_to :active? }
      it { chronologicable.should respond_to :duration }
      it { chronologicable.should respond_to :started_on }
      it { chronologicable.should respond_to :ended_on }

      it { ChronologicableStrategyClass.should respond_to :by_date }
      it { ChronologicableStrategyClass.should respond_to :ended }
      it { ChronologicableStrategyClass.should respond_to :not_yet_ended }
      it { ChronologicableStrategyClass.should respond_to :in_progress }
      it { ChronologicableStrategyClass.should respond_to :active }
      it { ChronologicableStrategyClass.should respond_to :started }
      it { ChronologicableStrategyClass.should respond_to :in_progress? }
      it { ChronologicableStrategyClass.should respond_to :active? }
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
