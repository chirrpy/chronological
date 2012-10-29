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

    define_method(:scheduled?) do
      strategy.scheduled?(self)
    end

    define_method(:partially_scheduled?) do
      strategy.partially_scheduled?(self)
    end

    base_timeframe     strategy.field_names
    strategy_timeframe strategy.field_names
  end
end
