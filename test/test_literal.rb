require 'minitest/autorun'
require_relative 'helper'

class LiteralTest < Minitest::Test
  def test_explicit_literal_block
    xml = <<~EOF.chomp.to_dita
    [literal]
    A literal block
    EOF

    assert_xpath_equal xml, 'A literal block', '//pre/text()'
  end

  def test_delimited_literal_block
    xml = <<~EOF.chomp.to_dita
    ....
    A literal block
    ....
    EOF

    assert_xpath_equal xml, 'A literal block', '//pre/text()'
  end

  def test_indented_literal_block
    # Note the hyphen in the heredoc syntax:
    xml = <<-EOF.chomp.to_dita
      A literal block
    EOF

    assert_xpath_equal xml, 'A literal block', '//pre/text()'
  end

  def test_literal_block_title
    xml = <<~EOF.chomp.to_dita
    .A literal block title
    ....
    A literal block
    ....
    EOF

    assert_xpath_equal xml, 'A literal block title', '//fig/title/text()'
    assert_xpath_equal xml, 'A literal block', '//fig/pre/text()'
  end

  def test_literal_block_role
    xml = <<~EOF.chomp.to_dita
    [literal,role="platform:linux"]
    .A literal block title
    A literal block
    EOF

    assert_xpath_equal xml, 'linux', '//fig/@platform'
    assert_xpath_count xml, 0, '//fig/pre/@platform'
  end

  def test_literal_block_id
    xml = <<~EOF.chomp.to_dita
    [literal,id="literal-id"]
    .A literal block title
    A literal block
    EOF

    assert_xpath_equal xml, 'literal-id', '//fig/@id'
    assert_xpath_count xml, 0, '//fig/pre/@id'
  end

  def test_literal_block_no_id
    xml = <<~EOF.chomp.to_dita
    [literal]
    A literal block
    EOF

    assert_xpath_count xml, 0, '//pre/@id'
  end
end
