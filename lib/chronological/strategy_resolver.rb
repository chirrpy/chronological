module Chronological
  class StrategyResolver
    STRATEGIES = {
      absolute:                       Set[ :starting_time,           :ending_time ],
      relative:                       Set[ :base_of_offset,          :starting_offset, :ending_offset ],
      dual_relative:                  Set[ :base_of_starting_offset, :starting_offset, :base_of_ending_offset, :ending_offset ],
      duration_from_start:            Set[ :starting_time,           :duration ],
      duration_until_end:             Set[ :ending_time,             :duration ],
      duration_from_relative_start:   Set[ :base_of_starting_offset, :starting_offset, :duration ],
      duration_until_a_relative_end:  Set[ :base_of_ending_offset,   :ending_offset,   :duration ]
    }

    VALID_OPTIONS = [
      :starting_time,
      :ending_time,
      :base_of_offset,
      :starting_offset,
      :ending_offset,
      :base_of_starting_offset,
      :base_of_ending_offset,
      :duration,
      :absolute_start_date_field,
      :absolute_end_date_field,
      :absolute_start_time_field,
      :absolute_end_time_field,
    ]

    DEFAULT_FIELD_NAMES = [
      :started_at,
      :ended_at,
      :base_of_range_offset,
      :start_of_range_offset,
      :end_of_range_offset,
      :base_of_range_starting_offset,
      :base_of_range_ending_offset,
      :duration_in_seconds,
      :started_on,
      :ended_on,
      :started_at,
      :ended_at
    ]

    DEFAULT_FIELD_NAMES_FOR_OPTIONS = Hash[ VALID_OPTIONS.zip DEFAULT_FIELD_NAMES ]

    def self.resolve(options)
      strategy_name = resolve_strategy_name(options)
      field_names   = resolve_strategy_fields(strategy_name, options)

      "Chronological::#{strategy_name.to_s.classify}Strategy".constantize.new(field_names)
    end

  private
    def self.resolve_strategy_fields(strategy_name, options)
      strategy_option_names = STRATEGIES[strategy_name]
      overridden_options    = DEFAULT_FIELD_NAMES_FOR_OPTIONS.merge options

      overridden_options.select do |option_name, option_value|
        strategy_option_names.include? option_name
      end
    end

    def self.resolve_strategy_name(options)
      strategy_name = if options[:type]
                        options[:type]
                      else
                        resolve_strategy_name_from_options(options)
                      end

      raise Chronological::UndefinedStrategy unless STRATEGIES.include? strategy_name

      strategy_name
    end

    def self.resolve_strategy_name_from_options(options)
      option_names = Set.new options.keys

      resolved_strategy = STRATEGIES.find do |strategy_name, required_options|
                            required_options & option_names == required_options
                          end

      resolved_strategy ? resolved_strategy[0] : nil
    end
  end
end

