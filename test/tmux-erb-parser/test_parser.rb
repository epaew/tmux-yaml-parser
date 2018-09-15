# frozen_string_literal: true

require 'test_helper'

module TmuxERBParser
  class TestParser < MyTestCase
    sub_test_case '#parse' do
      setup do
        @input = File.open(input_file_path, 'r')
        @output = StringIO.new
        @expected = File.readlines(
          File.expand_path('../fixtures/sample.tmux.conf.result', __dir__)
        )
      end

      def test_parse_to_output
        parser = Parser.new(@input, @output)
        parser.parse
        @output.each_line.with_index do |line, index|
          assert_equal(line, @expected[index])
        end
      end

      def test_parse_inline
        ENV['DEBUG'] = 'true'
        parser = Parser.new(@input, nil)
        parser.instance_variable_set(:@logger, ::Logger.new(@output))
        parser.parse
        @output.each_line.with_index do |line, index|
          striped = parser.send(:strip_comments, @expected[index])
          assert_equal(line, "exec: #{striped}")
        end
      end
    end

    sub_test_case 'private methods' do # rubocop:disable Metrics/BlockLength
      setup do
        @parser = Parser.new('', '')
      end

      sub_test_case '.replace_source_file' do
        def subject(line)
          @parser.send(:replace_source_file, line)
        end

        def test_replace_source_file
          # rubocop:disable Style/LineLength
          before = %(bind C-r source ${HOME}/.tmux.conf\; display-message "Reload Config.")
          after = %(bind C-r run-shell "#{TmuxERBParser::PARSER_CMD} --inline ${HOME}/.tmux.conf"\; display-message "Reload Config.")
          # rubocop:enable Style/LineLength
          assert_equal(subject(before), after)
        end

        def test_replace_nested_source_file
          # rubocop:disable Style/LineLength
          before = %(bind C-r "source ${HOME}/.tmux.conf"\; display-message "Reload Config.")
          after = %(bind C-r "run-shell \\"#{TmuxERBParser::PARSER_CMD} --inline ${HOME}/.tmux.conf\\""\; display-message "Reload Config.")
          # rubocop:enable Style/LineLength
          assert_equal(subject(before), after)
        end
      end

      sub_test_case '.strip_comments' do
        def subject(line)
          @parser.send(:strip_comments, line)
        end

        def test_strip_comments_whole_line
          before = '# test'
          after = ''
          assert_equal(subject(before), after)
        end

        def test_strip_comments_at_eol
          after = 'bind C-t send-prefix'
          before = %(#{after} # puts "C-t" twice, send "C-t")
          assert_equal(subject(before), after)
        end

        def test_strip_comments_without_sharp_in_quote
          after = %(bind c new-window -c '\#{pane_current_path}')
          before = %(#{after} # test)
          assert_equal(subject(before), after)
        end

        def test_strip_comments_without_sharp_in_dquote
          after = %(bind c new-window -c "\#{pane_current_path}")
          before = %(#{after} # test)
          assert_equal(subject(before), after)
        end
      end
    end
  end
end
