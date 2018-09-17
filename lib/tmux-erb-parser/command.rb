# frozen_string_literal: true

require 'optparse'

module TmuxERBParser
  class Command
    def initialize(args = [])
      @command_name = File.basename($PROGRAM_NAME)
      @args         = args.empty? ? ['--help'] : args
      @options      = {}
      @logger       = Logger.instance
    end

    def run
      @option_parser = OptionParser.new(&method(:command_opts))
      @option_parser.parse!(@args)
      process
      exit 0
    rescue StandardError => e
      err_msg = "#{e.message}\n#{e.backtrace.join("\n\t")}"
      warn err_msg unless @options[:quiet]
      @logger.error err_msg
      exit 1
    end

    private

    def check_args
      msg = 'INPUT_ERB_FILES are required.' if @args.empty?
      unless @options[:inline] ^ @options[:output]
        msg = 'Please specify either --inline or --output option.'
      end

      raise ArgumentError, msg if msg
    end

    def command_opts(opts) # rubocop:disable Metrics/MethodLength
      opts.banner = "Usage: #{@command_name} INPUT_FILES [options]"

      opts.on('-i',
              '--inline',
              'Exec tmux subcommands to the current tmux-server.') do
        @options[:inline] = true
      end

      opts.on('-o',
              '--output [OUTPUT_FILE_NAME]',
              String,
              'Output the configuration to a file with the specified name.'\
              ' If the file name is omitted, output to stdout') do |fname|
        @options[:output] = File.open(fname, 'w') if fname
        @options[:output] ||= $stdout
      end

      opts.on('-h', '--help', 'Print this help message') do
        puts opts
        exit
      end

      opts.on('-v', '--version', 'Print version information') do
        puts "#{@command_name} #{TmuxERBParser::VERSION}"
        exit
      end
    end

    def exec(commands, output = nil)
      if output
        commands.each(&output.method(:puts))
      else
        commands.inject(+'', &method(:exec_tmux))
      end
    end

    def exec_tmux(buf, line)
      buf << line
      return buf if buf.empty?
      return buf.chop! if buf.end_with?('\\')

      command = "tmux #{buf.gsub(%(\\;), %( '\\;'))}"
      @logger.debug "exec: #{command}"

      `#{command}` unless ENV['DEBUG']
      +''
    end

    def process
      check_args

      @args.each do |arg|
        @logger.info "open #{arg}."
        File.open(arg, 'r') do |input|
          p = Parser.new(input, File.extname(arg.downcase)[1..-1].to_sym)
          commands = p.parse(@options[:output].nil?)
          exec(commands, @options[:output])
        end
      end
    end
  end
end
