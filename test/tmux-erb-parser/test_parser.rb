# frozen_string_literal: true

require 'test_helper'

module TmuxERBParser
  class TestParser < MyTestCase
    sub_test_case '#parse' do # rubocop:disable Metrics/BlockLength
      def subject(line, strip_comments = false)
        @parser = Parser.new(line)
        @parser.parse(strip_comments).first
      end

      sub_test_case '.replace_source_file' do
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
        def test_strip_comments_whole_line
          before = '# test'
          after = ''
          assert_equal(subject(before, true), after)
        end

        def test_strip_comments_at_eol
          after = 'bind C-t send-prefix'
          before = %(#{after} # puts "C-t" twice, send "C-t")
          assert_equal(subject(before, true), after)
        end

        def test_strip_comments_without_sharp_in_quote
          after = %(bind c new-window -c '\#{pane_current_path}')
          before = %(#{after} # test)
          assert_equal(subject(before, true), after)
        end

        def test_strip_comments_without_sharp_in_dquote
          after = %(bind c new-window -c "\#{pane_current_path}")
          before = %(#{after} # test)
          assert_equal(subject(before, true), after)
        end
      end
    end
  end
end
