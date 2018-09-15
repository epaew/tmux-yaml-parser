# frozen_string_literal: true

require 'test_helper'

module TmuxERBParser
  class TestLogger < Test::Unit::TestCase
    teardown do
      File.delete(log_file_path) if File.exist?(log_file_path)
    end

    sub_test_case 'log file existence' do
      def test_log_file_presence
        Logger.send(:new)
        assert { `test -f #{log_file_path}` }
      end
    end

    sub_test_case 'logger level' do
      def test_logger_level_default
        ENV['DEBUG'] = nil
        logger = Logger.send(:new)
        assert_equal(logger.level, ::Logger::WARN)
      end

      def test_logger_level_with_env
        ENV['DEBUG'] = '1'
        logger = Logger.send(:new)
        assert_equal(logger.level, ::Logger::DEBUG)
      end
    end

    private

    def log_file_path
      File.join(File.dirname(__dir__),
                "../log/#{File.basename($PROGRAM_NAME)}.log")
    end
  end
end
