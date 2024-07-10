require 'minitest/autorun'
require_relative 'helper'

class InlineKbdTest < Minitest::Test
  def test_single_key
    xml = <<~EOF.chomp.to_dita
    :experimental:
    Press kbd:[Q] to quit.
    EOF

    assert_xpath_equal xml, 'Q', '//uicontrol[@outputclass="key"]/text()'
  end

  def test_key_combination
    xml = <<~EOF.chomp.to_dita
    :experimental:
    Press kbd:[Ctrl+Alt+Q] to quit.
    EOF

    assert_xpath_includes xml, 'Ctrl', '//uicontrol[@outputclass="key"]/text()'
    assert_xpath_includes xml, 'Alt', '//uicontrol[@outputclass="key"]/text()'
    assert_xpath_includes xml, 'Q', '//uicontrol[@outputclass="key"]/text()'
  end
end
