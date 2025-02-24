require 'minitest/autorun'
require_relative 'helper'

class DocumentTest < Minitest::Test
  def test_document_structure
    xml = <<~EOF.chomp.to_dita
    [#topic-id]
    = Topic title

    Topic contents.
    EOF

    assert_xpath_equal xml, 'topic-id', '/topic/@id'
    assert_xpath_equal xml, 'Topic title', '/topic/title/text()'
    assert_xpath_equal xml, 'Topic contents.', '/topic/body/p/text()'
  end

  def test_content_type
    xml = <<~EOF.chomp.to_dita
    :_mod-docs-content-type: PROCEDURE

    = Topic title

    Topic contents.
    EOF

    assert_xpath_equal xml, 'procedure', '/topic/@outputclass'
  end

  def test_legacy_content_type
    xml = <<~EOF.chomp.to_dita
    :_content-type: PROCEDURE

    = Topic title

    Topic contents.
    EOF

    assert_xpath_equal xml, 'procedure', '/topic/@outputclass'
  end

  def test_no_content_type
    xml = <<~EOF.chomp.to_dita
    = Topic title

    Topic contents.
    EOF

    assert_xpath_count xml, 0, '/topic/@outputclass'
  end
end
