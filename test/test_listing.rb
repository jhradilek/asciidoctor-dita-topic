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

    assert_xpath_equal xml, 'A listing block title', '//p[@outputclass="title"]/b/text()'
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

    assert_xpath_equal xml, 'A source block title', '//p[@outputclass="title"]/b/text()'
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
end
