require 'minitest/autorun'
require_relative 'helper'

class VideoTest < Minitest::Test
  def test_video_definition
    xml = <<~EOF.chomp.to_dita
    video::video.mp4[]
    EOF

    assert_xpath_equal xml, 'video.mp4', '//object/@data'
  end

  def test_video_with_title
    xml = <<~EOF.chomp.to_dita
    .Video title
    video::video.mp4[]
    EOF

    assert_xpath_equal xml, 'Video title', '//object/desc/text()'
    assert_xpath_equal xml, 'video.mp4', '//object/@data'
  end

  def test_video_sizing
    xml = <<~EOF.chomp.to_dita
    video::video.mp4[width=640,height=480]
    EOF

    assert_xpath_equal xml, 'video.mp4', '//object/@data'
    assert_xpath_equal xml, '640', '//object/@width'
    assert_xpath_equal xml, '480', '//object/@height'
  end

  def test_vimeo_video
    xml = <<~EOF.chomp.to_dita
    video::67480300[vimeo]
    EOF

    assert_xpath_equal xml, 'https://player.vimeo.com/video/67480300', '//object/@data'
  end

  def test_youtube_video
    xml = <<~EOF.chomp.to_dita
    video::lJIrF4YjHfQ[youtube]
    EOF

    assert_xpath_equal xml, 'https://www.youtube.com/embed/lJIrF4YjHfQ', '//object/@data'
  end

  def test_youtube_with_playlist_target
    xml = <<~EOF.chomp.to_dita
    video::lJIrF4YjHfQ/PL9hW1uS6HUftRY4bk3ScHu4WvvMU0wMkD[youtube]
    EOF

    assert_xpath_equal xml, 'https://www.youtube.com/embed/lJIrF4YjHfQ?list=PL9hW1uS6HUftRY4bk3ScHu4WvvMU0wMkD', '//object/@data'
  end

  def test_youtube_with_playlist_attribute
    xml = <<~EOF.chomp.to_dita
    video::lJIrF4YjHfQ[youtube,list=PL9hW1uS6HUftRY4bk3ScHu4WvvMU0wMkD]
    EOF

    assert_xpath_equal xml, 'https://www.youtube.com/embed/lJIrF4YjHfQ?list=PL9hW1uS6HUftRY4bk3ScHu4WvvMU0wMkD', '//object/@data'
  end

  def test_video_role
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    video::video.mp4[]
    EOF

    assert_xpath_equal xml, 'linux', '//object/@platform'
  end

  def test_video_role_with_title
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    .Video title
    video::video.mp4[]
    EOF

    assert_xpath_equal xml, 'linux', '//object/@platform'
  end

  def test_video_id
    xml = <<~EOF.chomp.to_dita
    [#video-id]
    video::video.mp4[]
    EOF

    assert_xpath_equal xml, 'video-id', '//object/@id'
  end

  def test_video_id_with_title
    xml = <<~EOF.chomp.to_dita
    [#video-id]
    .Video title
    video::video.mp4[]
    EOF

    assert_xpath_equal xml, 'video-id', '//object/@id'
  end

  def test_video_no_id
    xml = <<~EOF.chomp.to_dita
    video::video.mp4[]
    EOF

    assert_xpath_count xml, 0, '//object/@id'
  end

  def test_video_no_id_with_title
    xml = <<~EOF.chomp.to_dita
    .Video title
    video::video.mp4[]
    EOF

    assert_xpath_count xml, 0, '//object/@id'
  end
end
