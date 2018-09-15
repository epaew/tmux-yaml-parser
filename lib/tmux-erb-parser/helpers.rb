# frozen_string_literal: true

module TmuxERBParser
  module Helpers
    module_function

    def prefix_key
      `tmux show-option -g prefix`.split[1]
    end

    def server_started?
      !ENV['TMUX'].nil?
    end

    def tmux_version
      (ENV['TMUX_VERSION'] || `tmux -V`.split[1]).to_f
    end

    def uname
      ENV['UNAME'] || `uname`.chomp
    end
  end
end
