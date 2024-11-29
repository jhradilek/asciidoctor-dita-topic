require 'minitest/autorun'
require_relative 'helper'

class PreambleTest < Minitest::Test
  def test_preamble
    xml = <<~EOF.chomp.to_dita
    = A document header

    A preamble.

    A preamble continued.

    == A section

    A paragraph.
    EOF

    assert_xpath_equal xml, 'A preamble.', '//body/p[1]/text()'
    assert_xpath_equal xml, 'A preamble continued.', '//body/p[2]/text()'
    assert_xpath_count xml, 2, '//body/p'
  end
end
