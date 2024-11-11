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

    assert_xpath_equal xml, 'A literal block title', '//p[@outputclass="title"]/b/text()'
    assert_xpath_equal xml, 'A literal block', '//pre/text()'
  end
end
