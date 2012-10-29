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

    ###
    # Scopes
    #
    define_singleton_method(:by_date) do |direction = :asc|
      strategy.class.by_date(self, strategy.field_names, direction)
    end

    define_singleton_method(:expired) do
      strategy.class.expired(self, strategy.field_names)
    end

    define_singleton_method(:current) do
      strategy.class.current(self, strategy.field_names)
    end

    base_timeframe     strategy.field_names
    strategy_timeframe strategy.field_names
  end
end
