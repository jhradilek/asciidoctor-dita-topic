require 'minitest/autorun'
require_relative 'helper'

class InlineButtonTest < Minitest::Test
  def test_inline_button
    xml = <<~EOF.chomp.to_dita
    :experimental:
    Press the btn:[OK] button.
    EOF

    assert_xpath_equal xml, 'OK', '//uicontrol[@outputclass="button"]/text()'
  end
end
