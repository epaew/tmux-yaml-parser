# frozen_string_literal: true

require 'logger'
require 'singleton'

module TmuxERBParser
  class Logger < ::Logger
    include Singleton

    def initialize
      super(File.join(File.dirname(__FILE__),
                      "../../log/#{File.basename($PROGRAM_NAME)}.log"))
      self.level = ENV['DEBUG'] ? DEBUG : WARN
    end
  end
end
