# frozen_string_literal: true

module TmuxERBParser
  class Converter
    class << self
      def convert(structured)
        structured = [structured] if structured.is_a?(Hash)

        structured.inject([], &method(:convert_line))
      end

      private

      def convert_line(result, line)
        result << '' unless result.empty?

        comment = line.is_a?(Hash) && line.delete('comment')
        result << "# #{comment}" if comment

        result.push(*convert_structured(line))
      end

      def convert_hash(hash, prefix = [])
        converted = hash.map do |key, value|
          case key
          when '"'
            convert_structured(value, [*prefix, %('"')])
          when 'if', 'if-shell', 'run', 'run-shell'
            convert_structured_shell(value, [*prefix, key])
          when /style/
            convert_structured_style(value, [*prefix, key])
          else
            convert_structured(value, [*prefix, key])
          end
        end
        converted.flatten
      end

      def convert_string(string, prefix = [])
        [*prefix, string].join(' ')
      end

      def convert_structured(item, prefix = [])
        case item
        when Array
          item.map { |i| convert_structured(i, prefix) }
        when Hash
          convert_hash(item, prefix)
        else
          convert_string(item, prefix)
        end
      end

      def convert_structured_shell(item, prefix = [])
        case item
        when Array
          args = item.map { |i| convert_structured(i, []) }
          args = args.flatten.map do |arg|
            arg.include?(' ') ? %('#{arg}') : arg
          end

          [*prefix, *args].join(' ')
        else
          convert_string(item, prefix)
        end
      end

      def convert_structured_style(item, prefix = [])
        case item
        when Array
          convert_string(item.join(','), prefix)
        when Hash
          convert_string(
            item.map { |key, value| "#{key}=#{value}" }.join(','),
            prefix
          )
        else
          convert_string(item, prefix)
        end
      end
    end
  end
end
