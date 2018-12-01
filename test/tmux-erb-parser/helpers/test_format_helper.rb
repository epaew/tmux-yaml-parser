# frozen_string_literal: true

require 'test_helper'

module TmuxERBParser
  module Helpers
    class TestEnvironmentHelper < MyTestCase
      def test_format_and
        assert_equal(helper.format_and('str1', 'str2'), "\#{&&:str1,str2}")
        assert_equal(helper.format_and('str1', 'str2', 'str3'),
                     "\#{&&:\#{&&:str1,str2},str3}")
      end

      def test_format_or
        assert_equal(helper.format_or('str1', 'str2'), "\#{||:str1,str2}")
        assert_equal(helper.format_or('str1', 'str2', 'str3'),
                     "\#{||:\#{||:str1,str2},str3}")
      end

      def test_format_if
        assert_equal(helper.format_if("\#{client_prefix}", '#[reverse]'),
                     "\#{?\#{client_prefix},#[reverse],}")
        assert_equal(
          helper.format_if("\#{client_prefix}", '#[reverse]', '#[default]'),
          "\#{?\#{client_prefix},#[reverse],#[default]}"
        )
      end

      private

      def helper
        TmuxERBParser::Helpers::FormatHelper
      end
    end
  end
end
