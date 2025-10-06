require 'minitest/autorun'
require_relative 'helper'

class HorizontalDlistTest < Minitest::Test
  def test_simple_horizontal_dlist
    xml = <<~EOF.chomp.to_dita
    [horizontal]
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, '2', '//table/tgroup/@cols'
    assert_xpath_equal xml, 'Term1', '//table/tgroup/tbody/row[1]/entry[1]/b/text()'
    assert_xpath_equal xml, 'Definition one', '//table/tgroup/tbody/row[1]/entry[2]/text()'
    assert_xpath_equal xml, 'Term2', '//table/tgroup/tbody/row[2]/entry[1]/b/text()'
    assert_xpath_equal xml, 'Definition two', '//table/tgroup/tbody/row[2]/entry[2]/text()'
  end

  def test_horizontal_dlist_outputclass
    xml = <<~EOF.chomp.to_dita
    [horizontal]
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, 'horizontal-dlist', '//table/@outputclass'
  end

  def test_horizontal_dlist_widths
    xml = <<~EOF.chomp.to_dita
    [horizontal,labelwidth=30,itemwidth=70]
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, '30*', '//table/tgroup/colspec[1]/@colwidth'
    assert_xpath_equal xml, '70*', '//table/tgroup/colspec[2]/@colwidth'
  end

  def test_horizontal_dlist_title
    xml = <<~EOF.chomp.to_dita
    .A description list title
    [horizontal]
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, 'A description list title', '//table/title/text()'
    assert_xpath_count xml, 2, '//table/tgroup/tbody/row'
  end

  def test_horizontal_dlist_role
    xml = <<~EOF.chomp.to_dita
    [horizontal,role="platform:linux"]
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, 'linux', '//table/@platform'
  end

  def test_horizontal_dlist_id
    xml = <<~EOF.chomp.to_dita
    [horizontal,id="list-id"]
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_equal xml, 'list-id', '//table/@id'
  end

  def test_horizontal_dlist_no_id
    xml = <<~EOF.chomp.to_dita
    [horizontal]
    Term1:: Definition one
    Term2:: Definition two
    EOF

    assert_xpath_count xml, 0, '//table/@id'
  end
end
