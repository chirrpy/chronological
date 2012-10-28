module Chronological
  class StrategyResolver
    STRATEGIES = [
      :absolute,
      :relative,
      :dual_relative,
      :duration_from_start,
      :duration_until_end,
      :duration_from_relative_start,
      :duration_from_relative_end
    ]

    def self.resolve(strategy)
      raise Chronological::UndefinedStrategy unless STRATEGIES.include? strategy

      "Chronological::#{strategy.to_s.classify}Strategy::MyModule".constantize
    end
  end
end

