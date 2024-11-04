require 'minitest/autorun'
require_relative 'helper'

class ListingTest < Minitest::Test
  def test_block_code
    xml = <<~EOF.chomp.to_dita
    [source, ruby]
    ----
    Hello world
    ----
    EOF

    assert_xpath_equal xml, 'Hello world', '//codeblock/text()'
  end
end
