# frozen_string_literal: true

require 'erb'
require 'json'
require 'yaml'
require_relative 'converter'
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

    def parse_string(input, type)
      erb_result = ERB.new(input).result(TmuxERBParser::Helpers.binding)

      parse_structure(erb_result, type)
    end

    def parse_structure(erb_result, type)
      case type
      when :json
        Converter.convert(JSON.parse(erb_result))
      when :yml, :yaml
        if RUBY_VERSION.to_f < 2.6
          Converter.convert(YAML.safe_load(erb_result, [], [], true))
        else
          Converter.convert(YAML.safe_load(erb_result, aliases: true))
        end
      else
        erb_result
          .gsub(/(\R){3,}/) { Regexp.last_match(1) * 2 } # reduce continuity blankline # rubocop:disable Layout/LineLength
          .each_line(chomp: true)
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
