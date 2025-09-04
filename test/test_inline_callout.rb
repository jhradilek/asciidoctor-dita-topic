require 'minitest/autorun'
require_relative 'helper'

class InlineCalloutTest < Minitest::Test
  def test_callout_number_outputclass
    xml = <<~EOF.chomp.to_dita
    :dita-topic-callouts: on

    ....
    puts "Testing a callout" <1>
    ....
    EOF

    assert_xpath_equal xml, 'callout', '//pre/b/@outputclass'
  end

  def test_callout_number_range
    xml = <<~EOF.chomp.to_dita
    :dita-topic-callouts: on

    ....
    1: <1>
    ....
    ....
    20: <20>
    ....
    ....
    21: <21>
    ....
    ....
    35: <35>
    ....
    ....
    36: <36>
    ....
    ....
    50: <50>
    ....
    EOF

    # Three ranges of symbols are used to cover numbers between 1 and 50:
    assert_xpath_equal xml, '&#9312;', '//pre[contains(., "1:")]/b/text()'
    assert_xpath_equal xml, '&#9331;', '//pre[contains(., "20:")]/b/text()'
    assert_xpath_equal xml, '&#12881;', '//pre[contains(., "21:")]/b/text()'
    assert_xpath_equal xml, '&#12895;', '//pre[contains(., "35:")]/b/text()'
    assert_xpath_equal xml, '&#12977;', '//pre[contains(., "36:")]/b/text()'
    assert_xpath_equal xml, '&#12991;', '//pre[contains(., "50:")]/b/text()'
  end
end
