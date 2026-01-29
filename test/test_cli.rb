require 'minitest/autorun'
require_relative '../lib/dita-topic/cli'

class CliTest < Minitest::Test
  def test_defaults
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', []
    attr = cli.instance_variable_get :@attr
    opts = cli.instance_variable_get :@opts
    prep = cli.instance_variable_get :@prep

    assert_includes attr, 'experimental'
    assert_equal false, opts[:output]
    assert_equal true, opts[:standalone]
    assert_equal false, opts[:map]
    assert_equal 0, opts[:no_includes]
    assert_equal [], prep
  end

  def test_missing_file
    file = 'file.adoc'

    File.stub :exist?, false do
      File.stub :file?, true do
        error = assert_raises OptionParser::InvalidArgument do
          AsciidoctorDitaTopic::Cli.new 'script-name', [file]
        end

        assert_match(/not a file: #{file}/, error.message)
      end
    end
  end

  def test_not_a_file
    file = 'file.adoc'

    File.stub :exist?, true do
      File.stub :file?, false do
        error = assert_raises OptionParser::InvalidArgument do
          AsciidoctorDitaTopic::Cli.new 'script-name', [file]
        end

        assert_match(/not a file: #{file}/, error.message)
      end
    end
  end

  def test_file_not_readable
    file = 'file.adoc'

    File.stub :exist?, true do
      File.stub :file?, true do
        File.stub :readable?, false do
          error = assert_raises OptionParser::InvalidArgument do
            AsciidoctorDitaTopic::Cli.new 'script-name', [file]
          end

          assert_match(/file not readable: #{file}/, error.message)
        end
      end
    end
  end

  def test_out_file_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-o', 'file.dita']
    opts = cli.instance_variable_get :@opts

    assert_equal 'file.dita', opts[:output]
  end

  def test_out_file_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--out-file', 'file.dita']
    opts = cli.instance_variable_get :@opts

    assert_equal 'file.dita', opts[:output]
  end

  def test_out_file_stdout
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-o', '-']
    opts = cli.instance_variable_get :@opts

    assert_equal $stdout, opts[:output]
  end

  def test_attribute_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-a', 'version=3']
    assert_includes cli.instance_variable_get(:@attr), 'version=3'
  end

  def test_attribute_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--attribute', 'version=3']
    assert_includes cli.instance_variable_get(:@attr), 'version=3'
  end

  def test_attribute_multiple
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-a', 'version=3', '-a', 'release=1']
    attr = cli.instance_variable_get :@attr

    assert_includes attr, 'version=3'
    assert_includes attr, 'release=1'
  end

  def test_prepend_file_short
    file = 'attributes.adoc'

    File.stub :exist?, true do
      File.stub :file?, true do
        File.stub :readable?, true do
          cli = AsciidoctorDitaTopic::Cli.new 'script-name', ['-p', file]
          assert_includes cli.instance_variable_get(:@prep), file
        end
      end
    end
  end

  def test_prepend_file_long
    file = 'attributes.adoc'

    File.stub :exist?, true do
      File.stub :file?, true do
        File.stub :readable?, true do
          cli = AsciidoctorDitaTopic::Cli.new 'script-name', ['--prepend-file', file]
          assert_includes cli.instance_variable_get(:@prep), file
        end
      end
    end
  end

  def test_prepend_file_multiple
    first  = 'common-attributes.adoc'
    second = 'custom-attributes.adoc'

    File.stub :exist?, true do
      File.stub :file?, true do
        File.stub :readable?, true do
          cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-p', first, '-p', second]
          prep = cli.instance_variable_get(:@prep)

          assert_includes prep, first
          assert_includes prep, second
        end
      end
    end
  end

  def test_prepend_file_missing_file
    file = 'attributes.adoc'

    File.stub :exist?, false do
      File.stub :file?, true do
        error = assert_raises OptionParser::InvalidArgument do
          AsciidoctorDitaTopic::Cli.new 'script-name', ['-p', file]
        end

        assert_match(/not a file: #{file}/, error.message)
      end
    end
  end

  def test_prepend_file_not_a_file
    file = 'attributes.adoc'

    File.stub :exist?, true do
      File.stub :file?, false do
        error = assert_raises OptionParser::InvalidArgument do
          AsciidoctorDitaTopic::Cli.new 'script-name', ['-p', file]
        end

        assert_match(/not a file: #{file}/, error.message)
      end
    end
  end

  def test_prepend_file_not_readable
    file = 'attributes.adoc'

    File.stub :exist?, true do
      File.stub :file?, true do
        File.stub :readable?, false do
          error = assert_raises OptionParser::InvalidArgument do
            AsciidoctorDitaTopic::Cli.new 'script-name', ['-p', file]
          end

          assert_match(/file not readable: #{file}/, error.message)
        end
      end
    end
  end

  def test_no_includes_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-I']
    opts = cli.instance_variable_get :@opts

    assert_equal 1, opts[:no_includes]
  end

  def test_no_includes_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--no-includes']
    opts = cli.instance_variable_get :@opts

    assert_equal 1, opts[:no_includes]
  end

  def test_no_includes_prepended
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-II']
    opts = cli.instance_variable_get :@opts

    assert_equal 2, opts[:no_includes]
  end

  def test_no_header_footer_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-s']
    opts = cli.instance_variable_get :@opts

    assert_equal false, opts[:standalone]
  end

  def test_no_header_footer_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--no-header-footer']
    opts = cli.instance_variable_get :@opts

    assert_equal false, opts[:standalone]
  end

  def test_dita_map_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-m']
    opts = cli.instance_variable_get :@opts

    assert_equal true, opts[:map]
  end

  def test_dita_map_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--dita-map']
    opts = cli.instance_variable_get :@opts

    assert_equal true, opts[:map]
  end

  def test_author_line_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-l']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-authors=on'
  end

  def test_author_line_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--author-line']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-authors=on'
  end

  def test_section_type_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-t']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-type=on'
  end

  def test_section_type_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--section-type']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-type=on'
  end

  def test_no_callouts_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-C']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-callouts=off'
  end

  def test_no_callouts_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--no-callouts']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-callouts=off'
  end

  def test_no_sidebars_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-S']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-sidebars=off'
  end

  def test_no_sidebars_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--no-sidebars']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-sidebars=off'
  end

  def test_no_titles_short
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['-T']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-titles=off'
  end

  def test_no_titles_long
    cli  = AsciidoctorDitaTopic::Cli.new 'script-name', ['--no-titles']
    assert_includes cli.instance_variable_get(:@attr), 'dita-topic-titles=off'
  end

  def test_help_short
    assert_output(/^Usage: script-name /) do
      error = assert_raises SystemExit do
        AsciidoctorDitaTopic::Cli.new 'script-name', ['-h']
      end

      assert_equal 0, error.status
    end
  end

  def test_help_long
    assert_output(/^Usage: script-name /) do
      error = assert_raises SystemExit do
        AsciidoctorDitaTopic::Cli.new 'script-name', ['--help']
      end

      assert_equal 0, error.status
    end
  end

  def test_version_short
    assert_output(/^script-name \d+\.\d+\.\d+$/) do
      error = assert_raises SystemExit do
        AsciidoctorDitaTopic::Cli.new 'script-name', ['-v']
      end

      assert_equal 0, error.status
    end
  end

  def test_version_long
    assert_output(/^script-name \d+\.\d+\.\d+$/) do
      error = assert_raises SystemExit do
        AsciidoctorDitaTopic::Cli.new 'script-name', ['--version']
      end

      assert_equal 0, error.status
    end
  end
end
