require 'optparse'

module TmuxERBParser
  class Command
    def initialize(args)
      @command_name = File.basename($0)
      @args         = args.empty? ? ["--help"] : args
      @options      = {}
    end

    def run
      @opts = OptionParser.new(&method(:set_opts))
      @opts.parse!(@args)
      process
      exit 0
    rescue => e
      err_msg = "#{e.message}\n#{e.backtrace.join("\n\t")}"
      STDERR.puts err_msg unless @options[:quiet]
      exit 1
    end

    private

    def process
      # TODO
    end

    def set_opts(opts)
      opts.banner = "Usage: #{@command_name} INPUT_FILES [options]"

      opts.on('-i', '--inline', 'Exec tmux subcommands to the current tmux-server.') do
        raise 'this option is currently unsupported.'
        @options[:inline] = true
      end

      opts.on('-o',
              '--output [OUTPUT_FILE_NAME]',
              String,
              'Output the configuration to a file with the specified name.'\
              ' If the file name is omitted, output to stdout') do |fname|
        raise 'this option is currently unsupported.'
        @options[:output] = File.open(fname, "w") if fname
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
  end
end
