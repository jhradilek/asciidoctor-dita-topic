require 'minitest/autorun'
require_relative 'helper'

class InlineFootnoteTest < Minitest::Test
  def test_inline_footnote
    xml = <<~EOF.chomp.to_dita
    This is a paragraph.footnote:[This is a footnote.]
    EOF

    assert_xpath_equal xml, 'This is a footnote.', '//fn/text()'
  end

  def test_inline_footnote_reference
    xml = <<~EOF.chomp.to_dita
      This is a paragraph.footnote:important[This is a footnote.]

      This is a second paragraph.footnote:important[]
    EOF

    assert_xpath_equal xml, 'This is a footnote.', '//p[1]/fn/text()'
    assert_xpath_equal xml, '#./important', '//p[1]/xref/@href'
    assert_xpath_equal xml, '#./important', '//p[2]/xref/@href'
  end
end
