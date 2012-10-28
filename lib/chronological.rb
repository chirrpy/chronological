require 'chronological/version'
require 'chronological/base'
require 'chronological/absolute_timeframe'
require 'chronological/relative_timeframe'

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
    strategy = args.first.is_a?(Symbol) ? args.pop    : nil

    class_variable_set(:@@chronological_strategy, strategy)
  end
end
