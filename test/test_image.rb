require 'minitest/autorun'
require_relative 'helper'

class ImageTest < Minitest::Test
  def test_image_definition
    xml = <<~EOF.chomp.to_dita
    image::image.png[]
    EOF

    assert_xpath_equal xml, 'image.png', '//image/@href'
  end

  def test_image_placement
    xml = <<~EOF.chomp.to_dita
    image::image.png[]
    EOF

    assert_xpath_equal xml, 'break', '//image/@placement'
  end

  def test_image_with_alt_text
    xml = <<~EOF.chomp.to_dita
    image::image-1.png[First image]
    image::image-2.png[alt="Second image"]
    EOF

    assert_xpath_equal xml, 'First image', '//image[@href="image-1.png"]/alt/text()'
    assert_xpath_equal xml, 'Second image', '//image[@href="image-2.png"]/alt/text()'
  end

  def test_image_without_alt_text
    xml = <<~EOF.chomp.to_dita
    image::image.png[]
    EOF

    assert_xpath_equal xml, 'image', '//image/alt/text()'
  end

  def test_image_sizing
    xml = <<~EOF.chomp.to_dita
    image::image-1.png[First image,320,240]
    image::image-2.png[alt="Second image", width=640, height=480]
    image::image-3.png[Third image,50%,50%]
    EOF

    assert_xpath_equal xml, '320', '//image[@href="image-1.png"]/@width'
    assert_xpath_equal xml, '240', '//image[@href="image-1.png"]/@height'
    assert_xpath_equal xml, '640', '//image[@href="image-2.png"]/@width'
    assert_xpath_equal xml, '480', '//image[@href="image-2.png"]/@height'
    assert_xpath_count xml, 0, '//image[@href="image-3.png"]/@width'
    assert_xpath_count xml, 0, '//image[@href="image-3.png"]/@height'
  end

  def test_image_scaling
    xml = <<~EOF.chomp.to_dita
    image::image.png[Example image,320,240,scale=50%]
    EOF

    assert_xpath_equal xml, '50', '//image/@scale'
  end

  def test_image_with_title
    xml = <<~EOF.chomp.to_dita
    .Image title
    image::image.png[]
    EOF

    assert_xpath_equal xml, 'Image title', '//fig/title/text()'
    assert_xpath_equal xml, 'image.png', '//fig/image/@href'
  end

  def test_image_role
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    image::image.png[]
    EOF

    assert_xpath_equal xml, 'linux', '//image/@platform'
  end

  def test_image_role_with_title
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    .Image title
    image::image.png[]
    EOF

    assert_xpath_equal xml, 'linux', '//fig/@platform'
  end

  def test_image_id
    xml = <<~EOF.chomp.to_dita
    [#image-id]
    image::image.png[]
    EOF

    assert_xpath_equal xml, 'image-id', '//image/@id'
  end

  def test_image_id_with_title
    xml = <<~EOF.chomp.to_dita
    [#image-id]
    .Image title
    image::image.png[]
    EOF

    assert_xpath_equal xml, 'image-id', '//fig/@id'
  end

  def test_image_no_id
    xml = <<~EOF.chomp.to_dita
    image::image.png[]
    EOF

    assert_xpath_count xml, 0, '//image/@id'
  end

  def test_image_no_id_with_title
    xml = <<~EOF.chomp.to_dita
    .Image title
    image::image.png[]
    EOF

    assert_xpath_count xml, 0, '//fig/@id'
  end
end
