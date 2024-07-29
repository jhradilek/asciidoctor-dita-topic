require 'minitest/autorun'
require_relative 'helper'

class ImageTest < Minitest::Test
  def test_image_href
    xml = <<~EOF.chomp.to_dita
    :experimental:
    image::sample.jpg[Sample Image, alt="Sample Alt Text"]
    EOF

    assert_xpath_equal xml, 'sample.jpg', '//image/@href'
  end
end
