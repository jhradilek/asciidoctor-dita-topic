require 'minitest/autorun'
require_relative 'helper'

class InlineQuotedTest < Minitest::Test
  def test_markup_types
    xml = <<~EOF.chomp.to_dita
    Inline markup for _emphasis_, *strong*, `monospace`,
    ^superscript^, and ~subscript~.
    EOF

    assert_xpath_equal xml, 'emphasis', '//i/text()'
    assert_xpath_equal xml, 'strong', '//b/text()'
    assert_xpath_equal xml, 'monospace', '//tt/text()'
    assert_xpath_equal xml, 'superscript', '//sup/text()'
    assert_xpath_equal xml, 'subscript', '//sub/text()'
  end

  def test_double_quotes
    xml = <<~EOF.chomp.to_dita
    "`double quotes`"
    EOF

    assert_xpath_equal xml, '&#8220;double quotes&#8221;', '//p/text()'
  end

  def test_single_quotes
    xml = <<~EOF.chomp.to_dita
    '`single quotes`'
    EOF

    assert_xpath_equal xml, '&#8216;single quotes&#8217;', '//p/text()'
  end

  def test_asciimath
    xml = <<~EOF.chomp.to_dita
    :stem: asciimath
    A line with inline STEM content: stem:[sqrt(16) = 4]
    EOF

    assert_xpath_count xml, 2, '//p/comment()'
    assert_xpath_equal xml, 'asciimath start', '//p/comment()[1]'
    assert_xpath_equal xml, 'asciimath end', '//p/comment()[2]'
    assert_xpath_equal xml, 'sqrt(16) = 4', '//p/text()[2]'
  end

  def test_latexmath
    xml = <<~EOF.chomp.to_dita
    :stem: latexmath
    A line with inline STEM content: stem:[\\alpha = \\beta + \\gamma]
    EOF

    assert_xpath_count xml, 2, '//p/comment()'
    assert_xpath_equal xml, 'latexmath start', '//p/comment()[1]'
    assert_xpath_equal xml, 'latexmath end', '//p/comment()[2]'
    assert_xpath_equal xml, '\alpha = \beta + \gamma', '//p/text()[2]'
  end
end
