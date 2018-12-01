# frozen_string_literal: true

require 'test_helper'

module TmuxERBParser
  class TestHelpers < MyTestCase
    # degrade check
    def test_tmux_version
      ENV['TMUX_VERSION'] = '2.6'
      assert_equal(
        TmuxERBParser::Helpers.tmux_version,
        TmuxERBParser::Helpers::EnvironmentHelper.tmux_version
      )
    end
  end
end
