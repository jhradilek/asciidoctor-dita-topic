require 'minitest/autorun'
require_relative 'helper'

class VideoTest < Minitest::Test
  def test_audio_definition
    xml = <<~EOF.chomp.to_dita
    video::video.mp4[]
    EOF

    assert_xpath_equal xml, 'video.mp4', '//object/@data'
  end

  def test_audio_with_title
    xml = <<~EOF.chomp.to_dita
    .Video title
    audio::video.mp4[]
    EOF

    assert_xpath_equal xml, 'Video title', '//object/desc/text()'
    assert_xpath_equal xml, 'video.mp4', '//object/@data'
  end
end
