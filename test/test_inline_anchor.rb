require 'minitest/autorun'
require_relative 'helper'

class InlineAnchorTest < Minitest::Test
  def test_inline_link
    xml = <<~EOF.chomp.to_dita
    Check out the link:http://example.com[example].
    EOF

    assert_xpath_equal xml, 'example', '//xref[@href="http://example.com"]/text()'
  end
end
