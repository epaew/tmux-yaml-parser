# frozen_string_literal: true

require 'simplecov'
require 'simplecov-console'
require 'test/unit'
require 'test/unit/rr'

SimpleCov.formatter = SimpleCov::Formatter::Console if ENV['CI']
SimpleCov.start { add_filter '/test/' }

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'tmux-erb-parser'

module TmuxERBParser
  class MyTestCase < Test::Unit::TestCase
    setup do
      stub(Helpers).prefix_key { 'C-t' }
    end

    teardown do
      File.delete(log_file_path) if File.exist?(log_file_path)
    end

    private

    def log_file_path
      File.expand_path("log/#{File.basename($PROGRAM_NAME)}.log", __dir__)
    end

    def input_file_path
      File.expand_path('fixtures/sample.tmux.conf.erb', __dir__)
    end
  end
end
