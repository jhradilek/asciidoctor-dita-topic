require 'minitest/autorun'
require_relative 'helper'

class InlineImageTest < Minitest::Test
  def test_image_definition
    xml = <<~EOF.chomp.to_dita
    A paragraph with an image:image.png[].
    EOF

    assert_xpath_equal xml, 'image.png', '//p/image/@href'
  end

  def test_image_placement
    xml = <<~EOF.chomp.to_dita
    A paragraph with an image:image.png[].
    EOF

    assert_xpath_equal xml, 'inline', '//p/image/@placement'
  end

  def test_image_with_alt_text
    xml = <<~EOF.chomp.to_dita
    A paragraph with a image:image-1.png[first] and image:image-2.png[alt=second] image.
    EOF

    assert_xpath_equal xml, 'first', '//p/image[@href="image-1.png"]/alt/text()'
    assert_xpath_equal xml, 'second', '//p/image[@href="image-2.png"]/alt/text()'
  end

  def test_image_without_alt_text
    xml = <<~EOF.chomp.to_dita
    A paragraph with an image:image.png[].
    EOF

    assert_xpath_equal xml, 'image', '//p/image/alt/text()'
  end

  def test_image_sizing
    xml = <<~EOF.chomp.to_dita
    A paragraph with a image:image-1.png[first,48,32] and image:image-2.png[alt=second, width=24, height=16] image.
    EOF

    assert_xpath_equal xml, '48', '//p/image[@href="image-1.png"]/@width'
    assert_xpath_equal xml, '32', '//p/image[@href="image-1.png"]/@height'
    assert_xpath_equal xml, '24', '//p/image[@href="image-2.png"]/@width'
    assert_xpath_equal xml, '16', '//p/image[@href="image-2.png"]/@height'
  end
end
