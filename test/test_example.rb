require 'minitest/autorun'
require_relative 'helper'

class ExampleTest < Minitest::Test
  def test_explicit_example_block
    xml = <<~EOF.chomp.to_dita
    [example]
    An example block
    EOF

    assert_xpath_equal xml, 'An example block', '//example/text()'
  end

  def test_delimited_example_block
    xml = <<~EOF.chomp.to_dita
    ====
    An example block
    ====
    EOF

    assert_xpath_equal xml, 'An example block', '//example/p/text()'
  end

  def test_example_block_title
    xml = <<~EOF.chomp.to_dita
    .An example block title
    ====
    An example block
    ====
    EOF

    assert_xpath_equal xml, 'An example block title', '//example/title/text()'
    assert_xpath_equal xml, 'An example block', '//example/p/text()'
  end

  def test_example_role
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    ====
    An example block
    ====
    EOF

    assert_xpath_equal xml, 'linux', '//example/@platform'
  end

  def test_example_block_id
    xml = <<~EOF.chomp.to_dita
    [#example-id]
    ====
    An example block
    ====
    EOF

    assert_xpath_equal xml, 'example-id', '//example/@id'
  end

  def test_example_block_no_id
    xml = <<~EOF.chomp.to_dita
    ====
    An example block
    ====
    EOF

    assert_xpath_count xml, 0, '//example/@id'
  end
end
