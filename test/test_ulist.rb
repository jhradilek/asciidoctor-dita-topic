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
    .An unordered list title
    * Item one
    * Item two
    EOF

    assert_xpath_equal xml, 'linux', '//ul/@platform'
    assert_xpath_equal xml, 'linux', '//p[@outputclass="title"]/@platform'
  end

  def test_unordered_list_item_role
    doc = <<~EOF.chomp.parse_adoc
    * Item one
    * Item two
    +
    Additional paragraph

    // A comment separates two lists

    * [.platform:linux]#\{empty\}# Item one
    * [.platform:linux]#\{empty\}# Item two
    +
    Additional paragraph
    EOF

    first_list = doc.blocks[0]
    first_list.items[0].add_role 'platform:linux'
    first_list.items[1].add_role 'platform:linux'
    xml = doc.convert

    assert_xpath_equal xml, 'linux', '//ul[1]/li[1]/@platform'
    assert_xpath_equal xml, 'linux', '//ul[1]/li[2]/@platform'
    assert_xpath_equal xml, 'linux', '//ul[2]/li[1]/@platform'
    assert_xpath_equal xml, 'linux', '//ul[2]/li[2]/@platform'
    assert_xpath_equal xml, 'Item one', '//ul[2]/li[1]/text()'
    assert_xpath_equal xml, 'Item two', '//ul[2]/li[2]/text()'
    assert_xpath_count xml, 0, '//ph'
  end

  def test_unordered_list_id
    xml = <<~EOF.chomp.to_dita
    [#list-id]
    .An unordered list title
    * Item one
    * Item two
    EOF

    assert_xpath_equal xml, 'list-id', '//ul/@id'
    assert_xpath_count xml, 0, '//ul/li/@id'
    assert_xpath_count xml, 0, '//p[@outputclass="title"]/@id'
  end

  def test_unordered_list_no_id
    xml = <<~EOF.chomp.to_dita
    * Item one
    * Item two
    EOF

    assert_xpath_count xml, 0, '//ul/@id'
  end

  def test_unordered_list_item_id
    doc = <<~EOF.chomp.parse_adoc
    * Item one
    * Item two

    // A comment separates two lists

    * Item one
    +
    Additional paragraph

    * Item two
    EOF

    first_list = doc.blocks[0]
    first_list.items[0].id = 'first-id'
    second_list = doc.blocks[1]
    second_list.items[0].id = 'second-id'
    xml = doc.convert

    assert_xpath_equal xml, 'first-id', '//ul[1]/li[1]/@id'
    assert_xpath_equal xml, 'second-id', '//ul[2]/li[1]/@id'
  end

  def test_unordered_list_item_no_id
    xml = <<~EOF.chomp.to_dita
    * Item one
    * Item two

    // A comment separates two lists

    * Item one
    +
    Additional paragraph

    * Item two
    EOF

    assert_xpath_count xml, 0, '//ul/li/@id'
  end
end
