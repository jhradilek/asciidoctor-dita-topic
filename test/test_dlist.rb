require 'minitest/autorun'
require_relative 'helper'

class DlistTest < Minitest::Test
  def test_simple_description_list
    xml = <<~EOF.chomp.to_dita
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, 'Term1', '//dl/dlentry[1]/dt/text()'
    assert_xpath_equal xml, 'Definition one', '//dl/dlentry[1]/dd/text()'
    assert_xpath_equal xml, 'Term2', '//dl/dlentry[2]/dt/text()'
    assert_xpath_equal xml, 'Definition two', '//dl/dlentry[2]/dd/text()'
  end

  def test_compound_description_list
    xml = <<~EOF.chomp.to_dita
    Term1::
      Definition one
      * Item one
      * Item two
    Term2::
      Definition two
    EOF

    assert_xpath_equal xml, 'Term1', '//dl/dlentry[1]/dt/text()'
    assert_xpath_equal xml, 'Definition one', '//dl/dlentry[1]/dd/p/text()'
    assert_xpath_equal xml, 'Item one', '//dl/dlentry[1]/dd/ul/li[1]/text()'
    assert_xpath_equal xml, 'Item two', '//dl/dlentry[1]/dd/ul/li[2]/text()'
    assert_xpath_equal xml, 'Term2', '//dl/dlentry[2]/dt/text()'
    assert_xpath_equal xml, 'Definition two', '//dl/dlentry[2]/dd/text()'
  end

  def test_nested_description_list
    xml = <<~EOF.chomp.to_dita
    Term1::
      Subterm1::: Subdefinition one
      Subterm2::: Subdefinition two
    Term2::
      Definition two
    EOF

    assert_xpath_equal xml, 'Term1', '//body/dl/dlentry[1]/dt/text()'
    assert_xpath_equal xml, 'Subterm1', '//body/dl/dlentry[1]/dd/dl/dlentry[1]/dt/text()'
    assert_xpath_equal xml, 'Subdefinition one', '//body/dl/dlentry[1]/dd/dl/dlentry[1]/dd/text()'
    assert_xpath_equal xml, 'Subterm2', '//body/dl/dlentry[1]/dd/dl/dlentry[2]/dt/text()'
    assert_xpath_equal xml, 'Subdefinition two', '//body/dl/dlentry[1]/dd/dl/dlentry[2]/dd/text()'
    assert_xpath_equal xml, 'Term2', '//body/dl/dlentry[2]/dt/text()'
    assert_xpath_equal xml, 'Definition two', '//body/dl/dlentry[2]/dd/text()'
  end

  def test_description_list_title
    xml = <<~EOF.chomp.to_dita
    .A description list title
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, 'A description list title', '//p[@outputclass="title"]/b/text()'
    assert_xpath_count xml, 2, '//dl/dlentry'
  end

  def test_description_list_role
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    .A description list title
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, 'linux', '//dl/@platform'
    assert_xpath_equal xml, 'linux', '//p[@outputclass="title"]/@platform'
  end

  def test_description_list_item_role
    xml = <<~EOF.chomp.to_dita
    [.platform:linux]#\{empty\}# Term1:: Definition one
    [.platform:linux]#\{empty\}# Term2:: Definition two
    EOF

    assert_xpath_equal xml, 'linux', '//dlentry[1]/@platform'
    assert_xpath_equal xml, 'linux', '//dlentry[2]/@platform'
  end

  def test_description_list_id
    xml = <<~EOF.chomp.to_dita
    [#dlist-id]
    .A description list title
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, 'dlist-id', '//dl/@id'
    assert_xpath_count xml, 0, '//p[@outputclass="title"]/@id'
  end

  def test_description_list_no_id
    xml = <<~EOF.chomp.to_dita
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_count xml, 0, '//dl/@id'
  end
end
