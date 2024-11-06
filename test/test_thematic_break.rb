require 'minitest/autorun'
require_relative 'helper'

class ThematicBreakTest < Minitest::Test
  def test_thematic_break
    xml = <<~EOF.chomp.to_dita
    '''

    ---

    - - -

    ***

    * * *
    EOF

    assert_xpath_count xml, 5, '//p[@outputclass="thematic-break"]'
  end
end
