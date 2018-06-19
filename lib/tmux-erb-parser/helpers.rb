module TmuxERBParser
  module Helpers
    def prefix_key
      `tmux show-option -g prefix`.split[1]
    end
    module_function :prefix_key

    def server_started?
      ! ENV['TMUX'].nil?
    end
    module_function :server_started?

    def tmux_version
      (ENV['TMUX_VERSION'] || `tmux -V`.split[1]).to_f
    end
    module_function :tmux_version

    def uname
      ENV['UNAME'] || `uname`.chomp
    end
    module_function :uname
  end
end
