require 'minitest/autorun'
require_relative 'helper'

class ParagraphTest < Minitest::Test
  def test_multiple_paragraphs
    xml = <<~EOF.chomp.to_dita
    First paragraph.
    Second sentence of the first paragraph.

    Second paragraph.
    EOF

    assert_xpath_count xml, 2, '//p'
    assert_xpath_equal xml, 'Second paragraph.', '//p[2]/text()'
  end
end
