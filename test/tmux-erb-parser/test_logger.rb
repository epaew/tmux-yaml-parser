# frozen_string_literal: true

require 'test_helper'

module TmuxERBParser
  class TestLogger < MyTestCase
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
  end
end
