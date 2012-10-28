require 'spec_helper'

describe Chronological::StrategyResolver do
  context 'when passed a strategy name' do
    it 'resolves to the proper class' do
      Chronological::StrategyResolver.resolve(:absolute).should be_an Chronological::AbsoluteStrategy
    end
  end
end
