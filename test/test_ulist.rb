require 'minitest/autorun'
require_relative 'helper'

class UlistTest < Minitest::Test
  def test_simple_unordered_list
    xml = <<~EOF.chomp.to_dita
    * Item one
    * Item two
    EOF

    assert_xpath_equal xml, 'Item one', '//ul/li[1]/text()'
    assert_xpath_equal xml, 'Item two', '//ul/li[2]/text()'
  end

  def test_compound_unordered_list
    xml = <<~EOF.chomp.to_dita
    * Item one
    +
    Additional paragraph
    * Item two
    EOF

    assert_xpath_equal xml, 'Item one', '//ul/li[1]//text()'
    assert_xpath_equal xml, 'Additional paragraph', '//ul/li[1]/p[1]/text()'
  end

  def test_checklist
    xml = <<~EOF.chomp.to_dita
    * [*] Item one
    * [x] Item two
    * [ ] Item three
    EOF

    assert_xpath_equal xml, '&#10003; Item one', '//ul/li[1]/text()'
    assert_xpath_equal xml, '&#10003; Item two', '//ul/li[2]/text()'
    assert_xpath_equal xml, '&#10063; Item three', '//ul/li[3]/text()'
  end

  def test_unordered_list_title
    xml = <<~EOF.chomp.to_dita
    .An unordered list title
    * Item one
    * Item two
    EOF

    assert_xpath_equal xml, 'An unordered list title', '//p[@outputclass="title"]/b/text()'
    assert_xpath_count xml, 2, '//ul/li'
  end

  def test_unordered_list_role
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    * Item one
    * Item two
    EOF

    assert_xpath_equal xml, 'linux', '//ul/@platform'
  end
end
