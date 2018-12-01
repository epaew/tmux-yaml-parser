# frozen_string_literal: true

require 'erb'
require 'json'
require 'yaml'
require_relative 'helpers'

module TmuxERBParser
  PARSER_CMD = File.expand_path('../../bin/tmux-erb-parser', __dir__)

  class ParseError < StandardError; end

  class Parser
    def initialize(input, type = :erb)
      @input = case input
               when IO     then input.read
               when Array  then input.join("\n")
               when String then input
               else raise ArgumentError
               end
      @type = type
    end

    def parse(strip_comments = false)
      parse_string(@input, @type).map do |line|
        line = replace_source_file(line)
        line = strip_comment(line) if strip_comments
        line
      end
    end

    private

    def generate_conf(_structured)
      # TODO
      parse_result = []
    end

    def parse_string(input, type)
      erb_result = ERB.new(input).result(TmuxERBParser::Helpers.binding)

      case type
      when :json
        generate_conf(JSON.parse(erb_result))
      when :yml, :yaml
        generate_conf(YAML.load_stream(erb_result))
      else
        # rubocop:disable Metrics/LineLength
        erb_result
          .gsub(/(\R){3,}/) { Regexp.last_match(1) * 2 } # reduce continuity blanklines
          .gsub(/(\R)+\z/) { Regexp.last_match(1) }      # remove blankline at EOF
          .each_line
          .map(&:chomp)
        # rubocop:enable Metrics/LineLength
      end
    end

    def replace_source_file(line)
      # source file -> run-shell "parser --inline file"
      if line =~ /source/ && line !~ /run(-shell)?/
        line = line.gsub(/"source(-file)?( -q)?\s([^\s\\;]+)"/) do
          %("run-shell \\"#{PARSER_CMD} --inline #{Regexp.last_match(3)}\\"")
        end
        line = line.gsub(/source(-file)?( -q)?\s([^\s\\;]+)/) do
          %(run-shell "#{PARSER_CMD} --inline #{Regexp.last_match(3)}")
        end
      end
      line
    end

    def strip_comment(str)
      return '' if str.empty? || str.lstrip.start_with?('#')

      strip_eol_comment(str)
    end

    def strip_eol_comment(str)
      flags = {}
      str = str.each_char.inject(+'') do |result, char|
        flags = update_flags(flags, char)
        break result if char == '#' && flags.values.none?

        result << char
      end
      str.rstrip
    end

    def update_flags(current_flags, char)
      result = current_flags.dup
      result.delete(:'\\')

      case char
      when '\\'
        result[char.to_sym] = !current_flags[char.to_sym]
      when '\'', '"'
        result[char.to_sym] =
          current_flags.delete(char.to_sym) ^ current_flags.values.none?
      end
      result
    end
  end
end
