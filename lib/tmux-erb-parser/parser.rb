# frozen_string_literal: true

require 'erb'
require 'json'
require 'yaml'

module TmuxERBParser
  PARSER_CMD = File.expand_path('../../bin/tmux-erb-parser', __dir__)

  class ParseError < StandardError; end

  class Parser
    def initialize(input, output, type = :erb, options = {})
      @input = input
      @output = output
      @type = type
      @options = options
      @logger = Logger.instance
    end

    def parse
      exec(convert(@input, @type), @output)
    end

    private

    def convert(input, type)
      plain = parse_file(input, type)

      plain.map do |line|
        lstriped = line.lstrip

        # source file -> run-shell "parser --inline file"
        if lstriped =~ /source/ && lstriped !~ /run(-shell)?/
          line.gsub!(/"source(-file)?( -q)?\s([^\s\\]+)"/) do
            %("run-shell \\"#{PARSER_CMD} --inline #{Regexp.last_match(3)}\\"")
          end
          line.gsub!(/source(-file)?( -q)?\s([^\s\\]+)/) do
            %(run-shell "#{PARSER_CMD} --inline #{Regexp.last_match(3)}")
          end
        end
        line
      end
    end

    def exec(commands, output = nil)
      if output
        commands.each(&output.method(:puts))
      else
        commands.inject('') { |result, line| exec_tmux(result, line) }
      end
    end

    def exec_tmux(buf, line)
      buf << line
      buf = strip_comments(buf)
      return buf if buf.empty?

      if buf.end_with?('\\')
        buf.chop!
      else
        command = "tmux #{buf.gsub(%(\\;), %( '\\;'))}"
        @logger.debug "exec: #{command}"

        `#{command}` unless ENV['DEBUG']
        buf.clear
      end
    end

    def generate_conf(_structured)
      # TODO
      parse_result = []
    end

    def parse_file(input, type)
      erb_result = ERB.new(input.read).result

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

    def strip_comments(str)
      return '' if str.empty? || str.lstrip.start_with?('#')

      strip_eol_comments(str)
    end

    # TODO: refactoring
    def strip_eol_comments(str)
      flags = {}
      str = str.each_char.inject('') do |result, char|
        case char
        when '\''
          if !flags[:double] || (flags[:single] && result[-1] != '\\')
            flags[:single] = !flags[:single]
          end
        when '"'
          if !flags[:single] || (flags[:double] && result[-1] != '\\')
            flags[:double] = !flags[:double]
          end
        when '#'
          break result if flags.values.none?
        end

        result << char
      end
      str.rstrip
    end
  end
end
