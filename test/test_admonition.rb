require 'minitest/autorun'
require_relative 'helper'

class AdmonitionTest < Minitest::Test
  def test_admonition_types
    xml = <<~EOF.chomp.to_dita
    NOTE: This is a note.

    TIP: this is a tip.

    IMPORTANT: This is an important note.

    CAUTION: This is a caution.

    WARNING: This is a warning.
    EOF

    assert_xpath_includes xml, 'note', '//note/@type'
    assert_xpath_includes xml, 'tip', '//note/@type'
    assert_xpath_includes xml, 'important', '//note/@type'
    assert_xpath_includes xml, 'caution', '//note/@type'
    assert_xpath_includes xml, 'warning', '//note/@type'
  end

  def test_paragraph_syntax
    xml = <<~EOF.chomp.to_dita
    TIP: This is a tip.
    EOF

    assert_xpath_equal xml, 'This is a tip.', '//note[@type="tip"]/text()'
  end

  def test_style_attribute_syntax
    xml = <<~EOF.chomp.to_dita
    [TIP]
    This is a tip.
    EOF

    assert_xpath_equal xml, 'This is a tip.', '//note[@type="tip"]/text()'
  end

  def test_block_syntax
    xml = <<~EOF.chomp.to_dita
    [TIP]
    ====
    This is a tip.
    ====
    EOF

    assert_xpath_equal xml, 'This is a tip.', '//note[@type="tip"]/p/text()'
  end

  def test_multiple_paragraphs
    xml = <<~EOF.chomp.to_dita
    [TIP]
    ====
    This is a tip.

    It has multiple paragraphs.
    ====
    EOF

    assert_xpath_count xml, 2, '//note[@type="tip"]/p'
  end
end
