require 'chronological/version'
require 'chronological/base'
require 'chronological/errors'
require 'chronological/strategy_resolver'
require 'chronological/strategies'

module Chronological
  def timeframe(*args)
    strategy = args.first.is_a?(Symbol) ? args.shift    : nil

    class_variable_set  :@@chronological_strategy,
                        Chronological::StrategyResolver.resolve(strategy)
  end
end
