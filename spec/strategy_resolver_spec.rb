require 'spec_helper'

describe Chronological::StrategyResolver do
  describe '.resolve' do
    context 'when passed a strategy name' do
      it 'resolves to the proper class' do
        Chronological::StrategyResolver.resolve(:type => :absolute).should be_an Chronological::AbsoluteStrategy
      end
    end
  end
end
