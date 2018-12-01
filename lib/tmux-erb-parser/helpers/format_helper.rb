# frozen_string_literal: true

module TmuxERBParser
  module Helpers
    module FormatHelper
      def format_and(*args)
        return args.first if args.length < 2

        args.inject { |result, val| format_cond('&&', result, val) }
      end

      def format_or(*args)
        return args.first if args.length < 2

        args.inject { |result, val| format_cond('||', result, val) }
      end

      def format_cond(operator, arg1, arg2)
        "\#{#{operator}:#{arg1},#{arg2}}"
      end

      def format_if(cond, true_value, false_value = nil)
        "\#{?#{cond},#{true_value},#{false_value}}"
      end
    end
  end
end
