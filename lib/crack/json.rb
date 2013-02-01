require 'multi_json'

module Crack
  # Look for and parse json strings that look like ISO 8601 times.
  DATE_REGEX = /^(?:\d{4}-\d{2}-\d{2}|\d{4}-\d{1,2}-\d{1,2}[T \t]+\d{1,2}:\d{2}:\d{2}(\.[0-9]*)?(([ \t]*)Z|[-+]\d{2}?(:\d{2})?))$/ 

  module JSON
    class << self
      # Parses a JSON string (JavaScript Object Notation) into a hash.
      # See www.json.org for more info.
      #
      #   ActiveSupport::JSON.decode("{\"team\":\"rails\",\"players\":\"36\"}")
      #   => {"team" => "rails", "players" => "36"}
      def parse(json, options ={})
        data = MultiJson.load(json, options)
        convert_dates_from(data)
      rescue MultiJson::DecodeError => e
        raise Crack::ParseError.new(e.message)
      end

      private

      def convert_dates_from(data)
        case data
        when nil
          nil
        when DATE_REGEX
          begin
            DateTime.parse(data)
          rescue ArgumentError
            data
          end
        when Array
          data.map! { |d| convert_dates_from(d) }
        when Hash
          data.each do |key, value|
            data[key] = convert_dates_from(value)
          end
        else
          data
        end
      end
    end
  end
end
