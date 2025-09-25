require 'minitest/autorun'
require_relative 'helper'

class OpenTest < Minitest::Test
  def test_simple_abstract
    xml = <<~EOF.chomp.to_dita
    = A document header

    [abstract]
    An abstract.

    A paragraph.
    EOF

    assert_xpath_equal xml, 'An abstract.', '//body/p[1]/text()'
    assert_xpath_equal xml, 'A paragraph.', '//body/p[2]/text()'
    assert_xpath_equal xml, 'abstract', '//body/p[1]/@outputclass'
    assert_xpath_count xml, 2, '//body/p'
  end

  def test_compound_abstract
    xml = <<~EOF.chomp.to_dita
    = A document header

    [abstract]
    --
    An abstract.

    An abstract continued.
    --

    A paragraph.
    EOF

    assert_xpath_equal xml, 'An abstract.', '//body/div/p[1]/text()'
    assert_xpath_equal xml, 'An abstract continued.', '//body/div/p[2]/text()'
    assert_xpath_equal xml, 'A paragraph.', '//body/p/text()'
    assert_xpath_equal xml, 'abstract', '//body/div/@outputclass'
    assert_xpath_count xml, 1, '//body/p'
  end

  def test_abstract_with_title
    xml = <<~EOF.chomp.to_dita
    = A document header

    [abstract]
    .An abstract title
    An abstract.

    A paragraph.
    EOF

    assert_xpath_equal xml, 'An abstract title', '//body/p[1]/b/text()'
    assert_xpath_equal xml, 'An abstract.', '//body/p[2]/text()'
    assert_xpath_equal xml, 'A paragraph.', '//body/p[3]/text()'
    assert_xpath_equal xml, 'title', '//body/p[1]/@outputclass'
    assert_xpath_equal xml, 'abstract', '//body/p[2]/@outputclass'
    assert_xpath_count xml, 3, '//body/p'
  end

  def test_part_introduction
    xml = <<~EOF.chomp.to_dita 'book'
    = A document header

    A paragraph.

    = A part header

    A part introduction.
    EOF

    assert_xpath_equal xml, 'A paragraph.', '//body/p/text()'
    assert_xpath_equal xml, 'A part header', '//body/section/title/text()'
    assert_xpath_equal xml, 'A part introduction.', '//body/section/p/text()'
    assert_xpath_count xml, 1, '//body/p'
    assert_xpath_count xml, 1, '//body/section/p'
  end

  def test_simple_abstract_role
    xml = <<~EOF.chomp.to_dita
    = A document header

    [abstract,role="platform:linux"]
    An abstract.
    EOF

    assert_xpath_equal xml, 'linux', '//body/p/@platform'
  end

  def test_compound_abstract_role
    xml = <<~EOF.chomp.to_dita
    = A document header

    [abstract,role="platform:linux"]
    --
    An abstract.

    An abstract continued.
    --
    EOF

    assert_xpath_equal xml, 'linux', '//body/div/@platform'
  end

  def test_part_introduction_role
    xml = <<~EOF.chomp.to_dita 'book'
    = A document header

    A paragraph.

    = A part header

    [role="platform:linux"]
    A part introduction.
    EOF

    assert_xpath_equal xml, 'linux', '//body/section/p/@platform'
  end
end
