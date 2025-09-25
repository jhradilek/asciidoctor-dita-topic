require 'minitest/autorun'
require_relative 'helper'

class AudioTest < Minitest::Test
  def test_audio_definition
    xml = <<~EOF.chomp.to_dita
    audio::audio.wav[]
    EOF

    assert_xpath_equal xml, 'audio.wav', '//object/@data'
  end

  def test_audio_with_title
    xml = <<~EOF.chomp.to_dita
    .Audio title
    audio::audio.wav[]
    EOF

    assert_xpath_equal xml, 'Audio title', '//object/desc/text()'
    assert_xpath_equal xml, 'audio.wav', '//object/@data'
  end

  def test_audio_role
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    audio::audio.wav[]
    EOF

    assert_xpath_equal xml, 'linux', '//object/@platform'
  end

  def test_audio_role_with_title
    xml = <<~EOF.chomp.to_dita
    [role="platform:linux"]
    .Audio title
    audio::audio.wav[]
    EOF

    assert_xpath_equal xml, 'linux', '//object/@platform'
  end
end
