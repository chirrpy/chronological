module Chronological
  class StrategyResolver
    STRATEGIES = {
      absolute:                       [ :starting_time,           :ending_time ],
      relative:                       [ :base_of_offset,          :starting_offset, :ending_offset ],
      dual_relative:                  [ :base_of_starting_offset, :starting_offset, :base_of_ending_offset, :ending_offset ],
      duration_from_start:            [ :starting_time,           :duration ],
      duration_until_end:             [ :ending_time,             :duration ],
      duration_from_relative_start:   [ :base_of_starting_offset, :starting_offset, :duration ],
      duration_until_a_relative_end:  [ :base_of_ending_offset,   :ending_offset,   :duration ]
    }

    DEFAULT_FIELD_NAMES = {
      starting_time:                  :started_at,
      ending_time:                    :ended_at,
      base_of_offset:                 :base_of_range_offset,
      starting_offset:                :start_of_range_offset,
      ending_offset:                  :end_of_range_offset,
      base_of_starting_offset:        :base_of_range_starting_offset,
      base_of_ending_offset:          :base_of_range_ending_offset,
      duration:                       :duration_in_seconds,
      absolute_start_date_field:      :started_on,
      absolute_end_date_field:        :ended_on,
      absolute_start_time_field:      :started_at,
      absolute_end_time_field:        :ended_at
    }

    def self.resolve(options)
      raise Chronological::UndefinedStrategy unless STRATEGIES.include? options[:type]

      strategy_options = parse(options)

      "Chronological::#{options[:type].to_s.classify}Strategy".constantize.new(strategy_options)
    end

  private
    def self.parse(options)
      strategy        = options[:type]
      required_fields = STRATEGIES[strategy]

      DEFAULT_FIELD_NAMES.select { |option_name, default_field_name| required_fields.include? option_name }
    end
  end
end

