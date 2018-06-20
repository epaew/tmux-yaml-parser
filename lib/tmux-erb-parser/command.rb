require 'optparse'

module TmuxERBParser
  class Command
    def initialize(args)
      @command_name = File.basename($0)
      @args         = args.empty? ? ["--help"] : args
      @options      = {}
      @logger       = Logger.instance
    end

    def run
      @opts = OptionParser.new(&method(:set_opts))
      @opts.parse!(@args)
      process
      exit 0
    rescue => e
      err_msg = "#{e.message}\n#{e.backtrace.join("\n\t")}"
      STDERR.puts err_msg unless @options[:quiet]
      @logger.error err_msg
      exit 1
    end

    private

    def process
      raise ArgumentError.new "INPUT_ERB_FILES are required." if @args.empty?
      unless @options[:inline] ^ @options[:output]
        raise ArgumentError.new "Please specify either --inline or --output option."
      end

      args = @args.dup
      args.each do |arg|
        @logger.info "open #{arg}."
        File.open(arg, "r") do |input|
          p = Parser.new(input,
                         @options[:output],
                         File.extname(arg.downcase)[1..-1].to_sym,
                         @options)
          p.parse
        end
      end
    end

    def set_opts(opts)
      opts.banner = "Usage: #{@command_name} INPUT_FILES [options]"

      opts.on('-i', '--inline', 'Exec tmux subcommands to the current tmux-server.') do
        @options[:inline] = true
      end

      opts.on('-o',
              '--output [OUTPUT_FILE_NAME]',
              String,
              'Output the configuration to a file with the specified name.'\
              ' If the file name is omitted, output to stdout') do |fname|
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
