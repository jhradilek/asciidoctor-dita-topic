require 'minitest/autorun'
require_relative '../lib/dita-topic.rb'

class ComposeMetadataTest < Minitest::Test
  def test_metadata_short
    dt     = Asciidoctor::DitaTopic.new nil
    result = dt.compose_metadata 'pl:linux pr:asciidoctor au:novice op:pdf'
    assert_equal ' platform="linux" product="asciidoctor" audience="novice" otherprops="pdf"', result
  end

  def test_metadata_long
    dt     = Asciidoctor::DitaTopic.new nil
    result = dt.compose_metadata 'platform:linux product:asciidoctor audience:novice otherprops:pdf'
    assert_equal ' platform="linux" product="asciidoctor" audience="novice" otherprops="pdf"', result
  end

  def test_metadata_mixed
    dt     = Asciidoctor::DitaTopic.new nil
    result = dt.compose_metadata 'pl:linux product:asciidoctor au:novice otherprops:pdf'
    assert_equal ' platform="linux" product="asciidoctor" audience="novice" otherprops="pdf"', result
  end

  def test_metadata_none
    dt     = Asciidoctor::DitaTopic.new nil
    result = dt.compose_metadata ''
    assert_equal '', result
  end

  def test_metadata_other
    dt     = Asciidoctor::DitaTopic.new nil
    result = dt.compose_metadata 'title floating'
    assert_equal '', result
  end
end
