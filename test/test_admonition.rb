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

  def test_supported_roles
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux product:asciidoctor audience:novice otherprops:pdf"]
    TIP: This is a tip.
    EOF

    assert_xpath_equal xml, 'linux', '//note/@platform'
    assert_xpath_equal xml, 'asciidoctor', '//note/@product'
    assert_xpath_equal xml, 'novice', '//note/@audience'
    assert_xpath_equal xml, 'pdf', '//note/@otherprops'
  end

  def test_multiple_roles
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux platform:mac"]
    TIP: This is a tip.
    EOF

    assert_xpath_equal xml, 'linux mac', '//note/@platform'
  end

  def test_no_roles
    xml = <<~EOF.chomp.to_dita
    [role=""]
    TIP: This is a tip.
    EOF

    assert_xpath_count xml, 0, '//note/@platform'
  end

  def test_invalid_roles
    xml = <<~EOF.chomp.to_dita
    [role="invalid:value"]
    TIP: This is a tip.
    EOF

    assert_xpath_count xml, 0, '//note/@platform'
  end
end
