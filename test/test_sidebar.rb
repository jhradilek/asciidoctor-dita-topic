require 'minitest/autorun'
require_relative 'helper'

class SidebarTest < Minitest::Test
  def test_explicit_sidebar
    xml = <<~EOF.chomp.to_dita
    [sidebar]
    Sidebar text
    EOF

    assert_xpath_equal xml, 'sidebar', '//div/@outputclass'
    assert_xpath_equal xml, 'Sidebar text', '//div/p/text()'
  end

  def test_delimited_sidebar
    xml = <<~EOF.chomp.to_dita
    ****
    Sidebar text
    ****
    EOF

    assert_xpath_equal xml, 'sidebar', '//div/@outputclass'
    assert_xpath_equal xml, 'Sidebar text', '//div/p/text()'
  end

  def test_compound_sidebar
    xml = <<~EOF.chomp.to_dita
    ****
    First paragraph.

    Second paragraph.
    ****
    EOF

    assert_xpath_equal xml, 'sidebar', '//div/@outputclass'
    assert_xpath_count xml, 2, '//div/p'
  end

  def test_sidebar_title
    xml = <<~EOF.chomp.to_dita
    .A sidebar title
    ****
    Sidebar text
    ****
    EOF

    assert_xpath_equal xml, 'A sidebar title', '//div/p[@outputclass="title"]/b/text()'
    assert_xpath_equal xml, 'Sidebar text', '//div/p[2]/text()'
  end
end
