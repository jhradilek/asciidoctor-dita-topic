require 'minitest/autorun'
require_relative 'helper'

class QuandaDlistTest < Minitest::Test
  def test_simple_qanda_list
    xml = <<~EOF.chomp.to_dita
    [qanda]
    Question 1:: Answer one
    Question 2:: Answer two
    EOF

    assert_xpath_equal xml, 'Question 1', '//ol/li[1]/p[1][@outputclass="question"]/i/text()'
    assert_xpath_equal xml, 'Answer one', '//ol/li[1]/p[2]/text()'
    assert_xpath_equal xml, 'Question 2', '//ol/li[2]/p[1][@outputclass="question"]/i/text()'
    assert_xpath_equal xml, 'Answer two', '//ol/li[2]/p[2]/text()'
  end

  def test_doubled_quanda_list
    xml = <<~EOF.chomp.to_dita
    [qanda]
    Question 1::
    Question 2::
    Answer one
    Question 3::
    Answer two
    EOF

    assert_xpath_equal xml, 'Question 1', '//ol/li[1]/p[1][@outputclass="question"]/i/text()'
    assert_xpath_equal xml, 'Question 2', '//ol/li[1]/p[2][@outputclass="question"]/i/text()'
    assert_xpath_equal xml, 'Answer one', '//ol/li[1]/p[3]/text()'
    assert_xpath_equal xml, 'Question 3', '//ol/li[2]/p[1][@outputclass="question"]/i/text()'
    assert_xpath_equal xml, 'Answer two', '//ol/li[2]/p[2]/text()'
  end

  def test_qanda_list_title
    xml = <<~EOF.chomp.to_dita
    .A quanda list title
    [qanda]
    Question 1:: Answer one
    Question 2:: Answer two
    EOF

    assert_xpath_equal xml, 'A quanda list title', '//p[@outputclass="title"]/b/text()'
    assert_xpath_count xml, 2, '//ol/li'
  end

  def test_qanda_list_role
    xml = <<~EOF.chomp.to_dita
    [qanda,role="platform:linux"]
    .A quanda list title
    Question 1:: Answer one
    Question 2:: Answer two
    EOF

    assert_xpath_equal xml, 'linux', '//ol/@platform'
    assert_xpath_equal xml, 'linux', '//p[@outputclass="title"]/@platform'
  end

  def test_qanda_list_id
    xml = <<~EOF.chomp.to_dita
    [qanda,id="list-id"]
    .A quanda list title
    Question 1:: Answer one
    Question 2:: Answer two
    EOF

    assert_xpath_equal xml, 'list-id', '//ol/@id'
    assert_xpath_count xml, 0, '//p[@outputclass="title"]/@id'
  end

  def test_qanda_list_no_id
    xml = <<~EOF.chomp.to_dita
    [qanda]
    Question 1:: Answer one
    Question 2:: Answer two
    EOF

    assert_xpath_count xml, 0, '//ol/@id'
  end
end
