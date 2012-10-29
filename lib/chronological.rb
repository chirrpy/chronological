require 'chronological/version'
require 'chronological/base'
require 'chronological/errors'
require 'chronological/strategy_resolver'
require 'chronological/strategies'

module Chronological
  def timeframe(*args)
    options = args.first.is_a?(Hash) ? args.pop : {}

    strategy = Chronological::StrategyResolver.resolve(options)

    extend Chronological::Base
    extend strategy.module

    base_timeframe     strategy.field_names
    strategy_timeframe strategy.field_names
  end
end
