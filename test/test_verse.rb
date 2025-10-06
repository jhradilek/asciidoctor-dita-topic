require 'minitest/autorun'
require_relative 'helper'

class VerseTest < Minitest::Test
  def test_explicit_verse
    xml = <<~EOF.chomp.to_dita
    [verse]
    First line
    Second line
    EOF

    assert_xpath_equal xml, "First line\nSecond line", '//lines/text()'
  end

  def test_delimited_verse
    xml = <<~EOF.chomp.to_dita
    [verse]
    ____
    First line

    Second line
    ____
    EOF

    assert_xpath_equal xml, "First line\n\nSecond line", '//lines/text()'
  end

  def test_verse_author
    xml = <<~EOF.chomp.to_dita
    [verse,Author Name]
    Verse line
    EOF

    assert_xpath_equal xml, "Verse line\n&#8212; Author Name", '//lines/text()'
  end

  def test_verse_source
    xml = <<~EOF.chomp.to_dita
    [verse,,Citation source]
    Verse line
    EOF

    assert_xpath_equal xml, 'Verse line', '//lines/text()'
    assert_xpath_equal xml, 'Citation source', '//lines/cite/text()'
  end

  def test_verse_role
    xml = <<~EOF.chomp.to_dita
    [verse,role="platform:linux"]
    First line
    Second line
    EOF

    assert_xpath_equal xml, 'linux', '//lines/@platform'
  end

  def test_verse_id
    xml = <<~EOF.chomp.to_dita
    [verse,id="verse-id"]
    First line
    Second line
    EOF

    assert_xpath_equal xml, 'verse-id', '//lines/@id'
  end

  def test_verse_no_id
    xml = <<~EOF.chomp.to_dita
    [verse]
    First line
    Second line
    EOF

    assert_xpath_count xml, 0, '//lines/@id'
  end
end
