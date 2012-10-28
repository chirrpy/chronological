require 'chronological/version'
require 'chronological/base'
require 'chronological/errors'
require 'chronological/strategies'

module Chronological
  STRATEGIES = [
    :absolute,
    :relative,
    :dual_relative,
    :duration_from_start,
    :duration_until_end,
    :duration_from_relative_start,
    :duration_from_relative_end
  ]

  def timeframe(*args)
    strategy = args.first.is_a?(Symbol) ? args.shift    : nil

    raise Chronological::UndefinedStrategy unless STRATEGIES.include? strategy

    strategy_class = "Chronological::#{strategy.to_s.classify}Strategy".constantize

    class_variable_set(:@@chronological_strategy, strategy_class)
  end
end
