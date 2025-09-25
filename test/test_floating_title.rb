require 'minitest/autorun'
require_relative 'helper'

class FloatingTitleTest < Minitest::Test
  def test_section_levels
    xml = <<~EOF.chomp.to_dita
    [discrete]
    = Section 0

    [discrete]
    == Section 1

    [discrete]
    === Section 2

    [discrete]
    ==== Section 3

    [discrete]
    ===== Section 4

    [discrete]
    ====== Section 5
    EOF

    assert_xpath_includes xml, 'Section 0', '//p[@outputclass="title sect0"]/b/text()'
    assert_xpath_includes xml, 'Section 1', '//p[@outputclass="title sect1"]/b/text()'
    assert_xpath_includes xml, 'Section 2', '//p[@outputclass="title sect2"]/b/text()'
    assert_xpath_includes xml, 'Section 3', '//p[@outputclass="title sect3"]/b/text()'
    assert_xpath_includes xml, 'Section 4', '//p[@outputclass="title sect4"]/b/text()'
    assert_xpath_includes xml, 'Section 5', '//p[@outputclass="title sect5"]/b/text()'
  end

  def test_section_role
    xml = <<~EOF.chomp.to_dita
    [discrete,role="platform:linux"]
    == Section 1
    EOF

    assert_xpath_equal xml, 'linux', '//p[@outputclass="title sect1"]/@platform'
  end
end
