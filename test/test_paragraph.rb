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

  def test_abstract_paragraph
    xml = <<~EOF.chomp.to_dita
    [role="_abstract"]
    An abstract.

    A paragraph.
    EOF

    assert_xpath_equal xml, 'An abstract.', '//body/p[1]/text()'
    assert_xpath_equal xml, 'A paragraph.', '//body/p[2]/text()'
    assert_xpath_equal xml, 'abstract', '//body/p[1]/@outputclass'
    assert_xpath_count xml, 2, '//body/p'
  end
end
