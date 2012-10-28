require 'spec_helper'

describe Chronological::StrategyResolver do
  describe '.resolve' do
    let(:resolved_strategy) { Chronological::StrategyResolver.resolve(options_to_resolve) }

    context 'when passed a strategy name' do
      let(:options_to_resolve) { { :type => :absolute } }

      it 'resolves to the proper class' do
        resolved_strategy.should be_a Chronological::AbsoluteStrategy
      end

      it 'tells the strategy to create itself with the default fields' do
        Chronological::AbsoluteStrategy.should_receive(:new).with starting_time:  :started_at,
                                                                  ending_time:    :ended_at

        resolved_strategy
      end

      context 'with some overridden field name options' do
        let(:options_to_resolve) { {  type:           :absolute,
                                      starting_time:  :my_starting_field } }

        it 'overrides the proper default fields and tells the strategy to create itself with those' do
          Chronological::AbsoluteStrategy.should_receive(:new).with starting_time:  :my_starting_field,
                                                                    ending_time:    :ended_at

          resolved_strategy
        end
      end
    end

    context 'when passed exact field names that relate to a strategy' do
      let(:options_to_resolve) { { starting_time: :my_starting_field,
                                   ending_time:   :my_ending_field } }

      it 'resolves the proper strategy to instantiate' do
        resolved_strategy.should be_a Chronological::AbsoluteStrategy
      end
    end

    context 'when passed something it does not know how to resolve' do
      let(:options_to_resolve) { { start_me_up:                             :my_starting_field,
                                   its_the_end_of_the_world_as_we_know_it:  :my_ending_field } }

      it 'resolves the proper strategy to instantiate' do
        lambda { Chronological::StrategyResolver.resolve(options_to_resolve) }.should raise_error Chronological::UndefinedStrategy
      end
    end
  end
end
