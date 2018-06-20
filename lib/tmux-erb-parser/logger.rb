require 'logger'
require 'singleton'

module TmuxERBParser
  class Logger < ::Logger
    include Singleton

    def initialize
      super(
        File.join(File.dirname(__FILE__), "../../log/#{File.basename($0)}.log")
      )
      self.level = ENV['DEBUG'] ? DEBUG : WARN
    end
  end
end
