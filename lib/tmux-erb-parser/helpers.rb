# frozen_string_literal: true

module TmuxERBParser
  module Classifyable
    refine String do
      def classify
        snake_case = File.basename(self, '.rb')
        splitted = snake_case.split('_').map do |w|
          w[0] = w[0].upcase
          w
        end
        splitted.join
      end
    end
  end

  module Helpers
    using Classifyable

    Dir[File.expand_path('helpers/*.rb', __dir__)].each do |h|
      require h
      klass = const_get(h.classify)
      self.class.class_eval do
        prepend klass
      end
    end

    def self.binding
      super # NOTE: Kernel.#binding is private
    end
  end
end
