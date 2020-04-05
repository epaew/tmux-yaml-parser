# frozen_string_literal: true

require 'erb'
require 'yaml'
require 'test_helper'

module TmuxERBParser
  class TestParser < MyTestCase
    setup do
      @patterns = YAML.safe_load(
        File
          .expand_path('../fixtures/test_parser_patterns.yml', __dir__)
          .yield_self { |file| IO.read(file) }
          .yield_self { |string| ERB.new(string).result },
        symbolize_names: true
      )
    end

    def test_parse
      @patterns.each do |pattern|
        assert_equal(
          [*pattern[:after]],
          subject(
            pattern[:before],
            pattern[:strip_comment],
            pattern[:type]&.to_sym
          )
        )
      end
    end

    private

    def subject(line, strip_comments = false, type = :erb)
      @parser = Parser.new(line, type)
      @parser.parse(strip_comments)
    end
  end
end
