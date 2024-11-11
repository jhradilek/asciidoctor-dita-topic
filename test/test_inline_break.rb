require 'minitest/autorun'
require_relative 'helper'

class InlineBreakTest < Minitest::Test
  def test_inline_break
    xml = <<~EOF.chomp.to_dita
    This line +
    is broken in two.
    EOF

    assert_xpath_count xml, 2, '//p/text()'
    assert_xpath_equal xml, 'break', '//p/comment()'
  end
end
