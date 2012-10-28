require 'spec_helper'

describe Chronological::StrategyResolver do
  context 'when passed a strategy name' do
    it 'resolves to the proper class' do
      Chronological::StrategyResolver.resolve(:absolute).should eql Chronological::AbsoluteStrategy
    end
  end
end
