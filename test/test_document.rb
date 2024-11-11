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
end
