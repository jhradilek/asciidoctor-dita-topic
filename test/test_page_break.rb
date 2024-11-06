require 'minitest/autorun'
require_relative 'helper'

class PageBreakTest < Minitest::Test
  def test_page_break
    xml = <<~EOF.chomp.to_dita
    <<<
    EOF

    assert_xpath_count xml, 1, '//p[@outputclass="page-break"]'
  end
end
