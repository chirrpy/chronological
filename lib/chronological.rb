require 'chronological/version'
require 'chronological/base'
require 'chronological/errors'
require 'chronological/strategy_resolver'
require 'chronological/strategies'

module Chronological
  def timeframe(*args)
    requested_strategy  = args.first.is_a?(Symbol) ? args.shift    : nil
    options             = args.first.is_a?(Hash)   ? args.pop      : {}

    strategy = Chronological::StrategyResolver.resolve(requested_strategy)

    include strategy.module

    strategy_timeframe options
  end
end
