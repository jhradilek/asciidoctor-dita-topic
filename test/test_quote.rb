require 'minitest/autorun'
require_relative 'helper'

class QuoteTest < Minitest::Test
  def test_explicit_quote
    xml = <<~EOF.chomp.to_dita
    [quote,Author Name,Quote source]
    Quoted line
    EOF

    assert_xpath_equal xml, 'Quoted line', '//lq/p[1]/text()'
    assert_xpath_equal xml, '&#8212; Author Name', '//lq/p[2]/text()'
    assert_xpath_equal xml, 'Quote source', '//lq/cite/text()'
  end

  def test_delimited_quote
    xml = <<~EOF.chomp.to_dita
    [quote,Author Name,Quote source]
    ____
    First line

    Second line
    ____
    EOF

    assert_xpath_equal xml, 'First line', '//lq/p[1]/text()'
    assert_xpath_equal xml, 'Second line', '//lq/p[2]/text()'
    assert_xpath_equal xml, '&#8212; Author Name', '//lq/p[3]/text()'
    assert_xpath_equal xml, 'Quote source', '//lq/cite/text()'
  end

  def test_quoted_paragraph
    xml = <<~EOF.chomp.to_dita
    "Quoted line"
    -- Author Name, Quote source
    EOF

    assert_xpath_equal xml, 'Quoted line', '//lq/p[1]/text()'
    assert_xpath_equal xml, '&#8212; Author Name', '//lq/p[2]/text()'
    assert_xpath_equal xml, 'Quote source', '//lq/cite/text()'
  end

  def test_quote_title
    xml = <<~EOF.chomp.to_dita
    .Quote title
    [quote,Author Name,Quote source]
    Quoted line
    EOF

    assert_xpath_equal xml, 'Quote title', '//lq/p[@outputclass="title"]/b/text()'
  end
end
