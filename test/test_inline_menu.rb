require 'minitest/autorun'
require_relative 'helper'

class InlineMenuTest < Minitest::Test
  def test_menu_without_items
    xml = <<~EOF.chomp.to_dita
    :experimental:
    Select menu:Help[] to see information about this software.
    EOF

    assert_xpath_equal xml, 'Help', '//menucascade/uicontrol/text()'
    assert_xpath_count xml, 1, '//menucascade/uicontrol'
  end

  def test_menu_with_item
    xml = <<~EOF.chomp.to_dita
    :experimental:
    Select menu:File[Open] to open an existing file.
    EOF

    assert_xpath_includes xml, 'File', '//menucascade/uicontrol/text()'
    assert_xpath_includes xml, 'Open', '//menucascade/uicontrol/text()'
    assert_xpath_count xml, 2, '//menucascade/uicontrol'
  end

  def test_menu_with_submenu
    xml = <<~EOF.chomp.to_dita
    :experimental:
    Select menu:View[Sidebar > Bookmarks] to open the panel with bookmarks.
    EOF

    assert_xpath_includes xml, 'View', '//menucascade/uicontrol/text()'
    assert_xpath_includes xml, 'Sidebar', '//menucascade/uicontrol/text()'
    assert_xpath_includes xml, 'Bookmarks', '//menucascade/uicontrol/text()'
    assert_xpath_count xml, 3, '//menucascade/uicontrol'
  end
end
