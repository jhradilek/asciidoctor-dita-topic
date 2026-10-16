require 'minitest/autorun'
require_relative 'helper'

class ListingTest < Minitest::Test
  def test_explicit_listing_block
    xml = <<~EOF.chomp.to_dita
    [listing]
    A listing block
    EOF

    assert_xpath_equal xml, 'A listing block', '//codeblock/text()'
  end

  def test_delimited_listing_block
    xml = <<~EOF.chomp.to_dita
    ----
    A listing block
    ----
    EOF

    assert_xpath_equal xml, 'A listing block', '//codeblock/text()'
  end

  def test_listing_block_title
    xml = <<~EOF.chomp.to_dita
    .A listing block title
    ----
    A listing block
    ----
    EOF

    assert_xpath_equal xml, 'A listing block title', '//p/b/text()'
    assert_xpath_equal xml, 'A listing block', '//codeblock/text()'
  end

  def test_explicit_source_block
    xml = <<~EOF.chomp.to_dita
    [source]
    A source code block
    EOF

    assert_xpath_equal xml, 'A source code block', '//codeblock/text()'
  end

  def test_implied_source_block
    xml = <<~EOF.chomp.to_dita
    [,ruby]
    ----
    puts "Hello"
    ----
    EOF

    assert_xpath_equal xml, 'puts "Hello"', '//codeblock/text()'
  end

  def test_source_block_title
    xml = <<~EOF.chomp.to_dita
    .A source block title
    [source]
    ----
    A source block
    ----
    EOF

    assert_xpath_equal xml, 'A source block title', '//p/b/text()'
    assert_xpath_equal xml, 'A source block', '//codeblock/text()'
  end

  def test_source_block_language
    xml = <<~EOF.chomp.to_dita
    [source,ruby]
    ----
    puts "Hello"
    ----
    EOF

    assert_xpath_equal xml, 'language-ruby', '//codeblock/@outputclass'
  end

  def test_source_block_role
    xml = <<~EOF.chomp.to_dita
    [source,role="platform:linux"]
    .A listing block title
    A source code block
    EOF

    assert_xpath_equal xml, 'linux', '//codeblock/@platform'
    assert_xpath_equal xml, 'linux', '//p/@platform'
  end

  def test_source_block_id
    xml = <<~EOF.chomp.to_dita
    [source,id="source-id"]
    A source code block
    EOF

    assert_xpath_equal xml, 'source-id', '//codeblock/@id'
    assert_xpath_count xml, 0, '//p/@id'
  end

  def test_source_block_title_id
    xml = <<~EOF.chomp.to_dita
    [source,id="source-id"]
    .A listing block title
    A source code block
    EOF

    assert_xpath_equal xml, 'source-id', '//p/@id'
    assert_xpath_count xml, 0, '//codeblock/@id'
  end

  def test_source_block_no_id
    xml = <<~EOF.chomp.to_dita
    [source]
    A source code block
    EOF

    assert_xpath_count xml, 0, '//codeblock/@id'
  end

  def test_source_block_no_title_id
    xml = <<~EOF.chomp.to_dita
    [source]
    .A listing block title
    A source code block
    EOF

    assert_xpath_count xml, 0, '//codeblock/@id'
    assert_xpath_count xml, 0, '//p/@id'
  end
end
