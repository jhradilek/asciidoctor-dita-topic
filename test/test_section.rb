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

  def test_section_id_variants
    xml = <<~EOF.chomp.to_dita
    = Topic title

    [#first-section]
    == First section

    Section contents.

    [[second-section]]
    == Second section

    Section contents.

    [id="third-section"]
    == Third section

    Section contents.
    EOF

    assert_xpath_count xml, 3, '//section'
    assert_xpath_equal xml, 'first-section', '//section[1]/@id'
    assert_xpath_equal xml, 'second-section', '//section[2]/@id'
    assert_xpath_equal xml, 'third-section', '//section[3]/@id'
  end

  def test_auto_section_id
    xml = <<~EOF.chomp.to_dita
    = Topic title

    == Section title

    Section contents.
    EOF

    assert_xpath_equal xml, '_section_title', '//section/@id'
  end
end
