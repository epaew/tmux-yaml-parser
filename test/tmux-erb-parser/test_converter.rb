# frozen_string_literal: true

module TmuxERBParser
  class TestConverter < MyTestCase
    setup do
      @patterns = YAML.safe_load(
        File
          .expand_path('../fixtures/test_converter_patterns.yml', __dir__)
          .yield_self { |file| IO.read(file) }
          .yield_self { |string| ERB.new(string).result }
      )
    end

    def test_convert
      @patterns.each do |pattern|
        # require 'pry'; binding.pry
        assert_equal(
          [*pattern['after']],
          subject(pattern['before'])
        )
      end
    end

    private

    def subject(input)
      Converter.convert(input)
    end
  end
end
