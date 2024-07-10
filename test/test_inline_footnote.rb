require 'minitest/autorun'
require_relative 'helper'

class InlineFootnoteTest < Minitest::Test
  def test_inline_footnote
    xml = <<~EOF.chomp.to_dita
    This is a paragraph.footnote:[This is a footnote.]
    EOF

    assert_xpath_equal xml, 'This is a footnote.', '//fn/text()'
  end
end
