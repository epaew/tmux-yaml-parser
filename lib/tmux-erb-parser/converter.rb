# frozen_string_literal: true

module TmuxERBParser
  class Converter
    class << self
      def convert(structured)
        structured.inject([]) do |result, hash|
          result << '' unless result.empty?

          comment = hash.is_a?(Hash) && hash.delete('comment')
          result << "# #{comment}" if comment

          result.concat([*convert_structured(hash)])
        end
      end

      private

      def convert_array(array, prefix = [])
        case prefix.last
        when 'if', 'if-shell', 'run', 'run-shell'
          strings = array.map do |item|
            converted = convert_structured(item, [])
            converted = %('#{converted}') if converted.include?(' ')
            converted
          end

          [*prefix, *strings].join(' ')
        else
          array.map { |item| convert_structured(item, prefix) }
        end
      end

      def convert_hash(hash, prefix = [])
        converted = hash.map do |key, value|
          key = %('"') if key == '"'
          convert_structured(value, [*prefix, key])
        end
        converted.flatten
      end

      def convert_string(string, prefix = [])
        [*prefix, string].join(' ')
      end

      def convert_structured(item, prefix = [])
        case item
        when Array then convert_array(item, prefix)
        when Hash then convert_hash(item, prefix)
        else convert_string(item, prefix)
        end
      end
    end
  end
end
