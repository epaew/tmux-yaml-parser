require 'erb'
require 'json'
require 'yaml'

module TmuxERBParser
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
      erb_result = ERB.new(input.read).result

      case type
      when :erb
        erb_result
          .gsub(/([\r\n(\r\n)]){3,}/) { $1 * 2 }  # reduce continuity blanklines
          .gsub(/([\r\n(\r\n)])+\z/) { $1 }       # remove blankline at last
          .each_line
          .map(&:chomp)
      when :json
        generate_conf(JSON::load(erb_result))
      when :yml, :yaml
        generate_conf(YAML::load_stream(erb_result))
      else
        ArgumentError.new "For INPUT_ERB_FILES only .erb/.json/.yaml are allowed."
      end
    end

    def exec(commands, output = nil)
      if output
        commands.each(&output.method(:puts))
      else
        commands.inject("") { |result, line| exec_tmux(result, line) }
      end
    end

    def exec_tmux(buf, line)
      buf << line
      buf = strip_comments(buf)
      return buf if buf.empty?

      if buf.end_with?('\\')
        buf.chop!
      else
        command = "tmux #{buf}"
        @logger.debug "exec: #{command}"

        `#{command}` unless ENV['DEBUG']
        buf.clear
      end
    end

    def generate_conf(structured)
      # TODO
      parse_result = []
    end

    def strip_comments(str)
      return '' if str.empty? || str.lstrip.start_with?('#')

      # strip comment at end of line
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
