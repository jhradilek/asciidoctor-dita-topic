require 'minitest/autorun'
require_relative 'helper'

class InlineQuotedTest < Minitest::Test
  def test_markup_types
    xml = <<~EOF.chomp.to_dita
    Inline markup for _emphasis_, *strong*, `monospace`,
    ^superscript^, ~subscript~, , and '`single quotes`'.
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
end
