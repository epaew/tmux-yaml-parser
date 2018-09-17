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

      if RUBY_VERSION.to_f < 2.5
        @patterns.map! do |pattern|
          pattern.each.with_object({}) do |(key, value), result|
            result[key.to_sym] = value
          end
        end
      end
    end

    def test_parse
      @patterns.each do |pattern|
        assert_equal(
          subject(pattern[:before], pattern[:strip_comment]),
          [*pattern[:after]]
        )
      end
    end

    private

    def subject(line, strip_comments = false)
      @parser = Parser.new(line)
      @parser.parse(strip_comments)
    end
  end
end
