require 'chronological/version'
require 'chronological/base'
require 'chronological/errors'
require 'chronological/strategy_resolver'
require 'chronological/strategies'

module Chronological
  def timeframe(*args)
    options             = args.first.is_a?(Hash)   ? args.pop      : {}

    strategy = Chronological::StrategyResolver.resolve(options)

    include strategy.module

    strategy_timeframe options
  end
end
