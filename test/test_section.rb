require 'minitest/autorun'
require_relative 'helper'

class SectionTest < Minitest::Test
  def test_section_structure
    xml = <<~EOF.chomp.to_dita
    [#topic-id]
    = Topic title

    [#section-id]
    == Section title

    Section contents.
    EOF

    assert_xpath_equal xml, 'section-id', '//section/@id'
    assert_xpath_equal xml, 'Section title', '//section/title/text()'
    assert_xpath_equal xml, 'Section contents.', '//section/p/text()'
  end
end
