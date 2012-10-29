module Chronological
  class BaseStrategy
    def initialize(field_names = {})
      @field_names = field_names
    end

    def field_names
      @field_names.dup
    end
  end
end
