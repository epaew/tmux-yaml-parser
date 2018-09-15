# frozen_string_literal: true

require 'test_helper'

module TmuxERBParser
  class TestCommand < MyTestCase
    setup do
      stub.instance_of(Parser).parse { true }
      $stdout = @stdout = StringIO.new
      $stderr = @stderr = StringIO.new
    end

    teardown do
      $stdout = STDOUT
      $stderr = STDERR
    end

    sub_test_case 'output help' do
      def test_run_with_no_option
        assert_raise(SystemExit) { run_command }
        assert_equal(@stdout.string,
                     @command.instance_variable_get(:@option_parser).to_s)
      end

      def test_run_with_help
        assert_raise(SystemExit) { run_command(['-h']) }
        assert_equal(@stdout.string,
                     @command.instance_variable_get(:@option_parser).to_s)
      end
    end

    sub_test_case 'output version' do
      def test_run_with_version
        assert_raise(SystemExit) { run_command(['-v']) }
        assert_equal(@stdout.string.chomp,
                     "#{File.basename($PROGRAM_NAME)} #{VERSION}")
      end
    end

    sub_test_case 'run with invalid arguments' do
      def test_run_inline_only
        assert_raise(SystemExit) { run_command(['--inline']) }
        assert_equal(@stderr.string.each_line.first.chomp,
                     'INPUT_ERB_FILES are required.')
      end

      def test_run_filename_only
        assert_raise(SystemExit) { run_command([input_file_path]) }
        assert_equal(@stderr.string.each_line.first.chomp,
                     'Please specify either --inline or --output option.')
      end
    end

    sub_test_case 'run with valid arguments' do
      def test_run_filename_and_inline
        e = assert_raise(SystemExit) do
          run_command([input_file_path, '--inline'])
        end
        assert_true(e.success?)
      end

      def test_run_filename_and_stdout
        e = assert_raise(SystemExit) do
          run_command([input_file_path, '--output'])
        end
        assert_true(e.success?)
      end
    end

    private

    def run_command(args = [])
      @command = Command.new(args)
      @command.run
    end
  end
end
