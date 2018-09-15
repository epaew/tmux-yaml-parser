# frozen_string_literal: true

require 'simplecov'
require 'simplecov-console'
require 'test/unit'
require 'test/unit/rr'

SimpleCov.formatter = SimpleCov::Formatter::Console
SimpleCov.start { add_filter '/test/' }

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'tmux-erb-parser'
