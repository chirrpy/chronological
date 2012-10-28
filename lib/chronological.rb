require 'chronological/version'
require 'chronological/base'
require 'chronological/errors'
require 'chronological/strategy_resolver'
require 'chronological/strategies'

module Chronological
  def timeframe(*args)
    strategy = args.first.is_a?(Symbol) ? args.shift    : nil
    options  = args.first.is_a?(Hash)   ? args.pop      : {}

    include Chronological::StrategyResolver.resolve(strategy)

    absolute_timeframe options
  end
end
