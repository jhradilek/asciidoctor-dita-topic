require 'minitest/autorun'
require_relative 'helper'

class OlistTest < Minitest::Test
  def test_simple_ordered_list
    xml = <<~EOF.chomp.to_dita
    . Item one
    . Item two
    EOF

    assert_xpath_equal xml, 'Item one', '//ol/li[1]/text()'
    assert_xpath_equal xml, 'Item two', '//ol/li[2]/text()'
  end

  def test_compound_ordered_list
    xml = <<~EOF.chomp.to_dita
    . Item one
    +
    Additional paragraph
    . Item two
    EOF

    assert_xpath_equal xml, 'Item one', '//ol/li[1]/text()'
    assert_xpath_equal xml, 'Additional paragraph', '//ol/li[1]/p[1]/text()'
  end

  def test_ordered_list_title
    xml = <<~EOF.chomp.to_dita
    .An ordered list title
    . Item one
    . Item two
    EOF

    assert_xpath_equal xml, 'An ordered list title', '//p[@outputclass="title"]/b/text()'
    assert_xpath_count xml, 2, '//ol/li'
  end

  def test_ordered_list_role
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    . Item one
    . Item two
    EOF

    assert_xpath_equal xml, 'linux', '//ol/@platform'
  end
end
