# frozen_string_literal: true

require 'test_helper'

module TmuxERBParser
  module Helpers
    class TestEnvironmentHelper < MyTestCase
      def test_prefix_key
        # NOTE: cannot test
      end

      def test_server_started?
        ENV['TMUX'] = nil
        assert_false(helper.server_started?)

        ENV['TMUX'] = 'some string'
        assert_true(helper.server_started?)
      end

      def test_tmux_version
        ENV['TMUX_VERSION'] = '2.6'
        assert_equal(helper.tmux_version, 2.6)
      end

      def test_uname
        ENV['UNAME'] = nil
        assert_equal(helper.uname, `uname`.chomp)

        ENV['UNAME'] = 'Linux'
        assert_equal(helper.uname, 'Linux')
      end

      private

      def helper
        TmuxERBParser::Helpers::EnvironmentHelper
      end
    end
  end
end
