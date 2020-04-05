# frozen_string_literal: true

require 'erb'
require 'yaml'
require 'test_helper'

module TmuxERBParser
  class TestParser < MyTestCase
    setup do
      @patterns = YAML.safe_load(
        ERB.new(
          IO.read(File.expand_path('../fixtures/patterns.yml', __dir__))
        ).result,
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
