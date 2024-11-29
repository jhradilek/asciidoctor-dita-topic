require 'minitest/autorun'
require_relative 'helper'

class InlineIndextermTest < Minitest::Test
  def test_explicit_flow_indexterm
    xml = <<~EOF.chomp.to_dita
    indexterm2:[A flow index term] as part of a paragraph.
    EOF

    assert_xpath_equal xml, 'A flow index term as part of a paragraph.', '//p/text()'
    assert_xpath_equal xml, 'A flow index term', '//p/indexterm/text()'
  end

  def test_compact_flow_indexterm
    xml = <<~EOF.chomp.to_dita
    ((A flow index term)) as part of a paragraph.
    EOF

    assert_xpath_equal xml, 'A flow index term as part of a paragraph.', '//p/text()'
    assert_xpath_equal xml, 'A flow index term', '//p/indexterm/text()'
  end

  def test_explicit_primary_indexterm
    xml = <<~EOF.chomp.to_dita
    indexterm:[Primary term]A paragraph.
    EOF

    assert_xpath_equal xml, 'A paragraph.', '//p/text()'
    assert_xpath_equal xml, 'Primary term', '//p/indexterm/text()'
    assert_xpath_count xml, 1, '//p/indexterm'
    assert_xpath_count xml, 0, '//p/indexterm/indexterm'
  end

  def test_compact_primary_indexterm
    xml = <<~EOF.chomp.to_dita
    (((Primary term)))A paragraph.
    EOF

    assert_xpath_equal xml, 'A paragraph.', '//p/text()'
    assert_xpath_equal xml, 'Primary term', '//p/indexterm/text()'
    assert_xpath_count xml, 1, '//p/indexterm'
    assert_xpath_count xml, 0, '//p/indexterm/indexterm'
  end

  def test_explicit_secondary_indexterm
    xml = <<~EOF.chomp.to_dita
    indexterm:[Primary term, Secondary term]A paragraph.
    EOF

    assert_xpath_equal xml, 'A paragraph.', '//p/text()'
    assert_xpath_equal xml, 'Primary term', '//p/indexterm/text()'
    assert_xpath_equal xml, 'Secondary term', '//p/indexterm/indexterm/text()'
    assert_xpath_count xml, 1, '//p/indexterm'
    assert_xpath_count xml, 1, '//p/indexterm/indexterm'
    assert_xpath_count xml, 0, '//p/indexterm/indexterm/indexterm'
  end

  def test_compact_secondary_indexterm
    xml = <<~EOF.chomp.to_dita
    (((Primary term, Secondary term)))A paragraph.
    EOF

    assert_xpath_equal xml, 'A paragraph.', '//p/text()'
    assert_xpath_equal xml, 'Primary term', '//p/indexterm/text()'
    assert_xpath_equal xml, 'Secondary term', '//p/indexterm/indexterm/text()'
    assert_xpath_count xml, 1, '//p/indexterm'
    assert_xpath_count xml, 1, '//p/indexterm/indexterm'
    assert_xpath_count xml, 0, '//p/indexterm/indexterm/indexterm'
  end

  def test_explicit_tertiary_indexterm
    xml = <<~EOF.chomp.to_dita
    indexterm:[Primary term, Secondary term, Tertiary term]A paragraph.
    EOF

    assert_xpath_equal xml, 'A paragraph.', '//p/text()'
    assert_xpath_equal xml, 'Primary term', '//p/indexterm/text()'
    assert_xpath_equal xml, 'Secondary term', '//p/indexterm/indexterm/text()'
    assert_xpath_equal xml, 'Tertiary term', '//p/indexterm/indexterm/indexterm/text()'
    assert_xpath_count xml, 1, '//p/indexterm'
    assert_xpath_count xml, 1, '//p/indexterm/indexterm'
    assert_xpath_count xml, 1, '//p/indexterm/indexterm/indexterm'
    assert_xpath_count xml, 0, '//p/indexterm/indexterm/indexterm/indexterm'
  end

  def test_compact_tertiary_indexterm
    xml = <<~EOF.chomp.to_dita
    (((Primary term, Secondary term, Tertiary term)))A paragraph.
    EOF

    assert_xpath_equal xml, 'A paragraph.', '//p/text()'
    assert_xpath_equal xml, 'Primary term', '//p/indexterm/text()'
    assert_xpath_equal xml, 'Secondary term', '//p/indexterm/indexterm/text()'
    assert_xpath_equal xml, 'Tertiary term', '//p/indexterm/indexterm/indexterm/text()'
    assert_xpath_count xml, 1, '//p/indexterm'
    assert_xpath_count xml, 1, '//p/indexterm/indexterm'
    assert_xpath_count xml, 1, '//p/indexterm/indexterm/indexterm'
    assert_xpath_count xml, 0, '//p/indexterm/indexterm/indexterm/indexterm'
  end
end
