require 'spec_helper'

describe Chronological::StrategyResolver do
  describe '.resolve' do
    let(:resolved_strategy) { Chronological::StrategyResolver.resolve(options_to_resolve) }

    context 'when passed a strategy name' do
      let(:options_to_resolve) { { :type => :absolute } }

      it 'resolves to the proper class' do
        resolved_strategy.should be_an Chronological::AbsoluteStrategy
      end

      it 'tells the strategy to create itself with the default fields' do
        Chronological::AbsoluteStrategy.should_receive(:new).with starting_time:  :started_at,
                                                                  ending_time:    :ended_at

        resolved_strategy
      end
    end
  end
end
