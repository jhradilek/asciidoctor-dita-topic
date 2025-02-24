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

  def test_single_author
    xml = <<~EOF.chomp.to_dita
    :dita-topic-authors: on

    = Topic title
    Full Name <name@example.com>

    Topic contents.
    EOF

    assert_xpath_equal xml, 'Full Name &lt;name@example.com&gt;', '/topic/prolog/author/text()'
    assert_xpath_count xml, 1, '/topic/prolog/author'
  end

  def test_multiple_authors
    xml = <<~EOF.chomp.to_dita
    :dita-topic-authors: on

    = Topic title
    First Name <first@example.com>; Second Name; Third Name <third@example.com>

    Topic contents.
    EOF

    assert_xpath_equal xml, 'First Name &lt;first@example.com&gt;', '/topic/prolog/author[1]/text()'
    assert_xpath_equal xml, 'Second Name', '/topic/prolog/author[2]/text()'
    assert_xpath_equal xml, 'Third Name &lt;third@example.com&gt;', '/topic/prolog/author[3]/text()'
    assert_xpath_count xml, 3, '/topic/prolog/author'
  end

  def test_single_author_off
    xml = <<~EOF.chomp.to_dita
    :dita-topic-authors: off

    = Topic title
    Full Name <name@example.com>

    Topic contents.
    EOF

    assert_xpath_equal xml, 'Full Name &lt;name@example.com&gt;', '/topic/body/p[1]/text()'
    assert_xpath_count xml, 2, '/topic/body/p'
  end

  def test_multiple_authors_off
    xml = <<~EOF.chomp.to_dita
    :dita-topic-authors: off

    = Topic title
    First Name <first@example.com>; Second Name; Third Name <third@example.com>

    Topic contents.
    EOF

    assert_xpath_equal xml, 'First Name &lt;first@example.com&gt;; Second Name; Third Name &lt;third@example.com&gt;', '/topic/body/p[1]/text()'
    assert_xpath_count xml, 2, '/topic/body/p'
  end

  def test_accidental_author_line
    xml = <<~EOF.chomp.to_dita
    :dita-topic-authors: off

    = Topic title
    First paragraph. Second sentence with a *bold* text.

    Second paragraph.
    EOF

    assert_xpath_equal xml, 'First paragraph. Second sentence with a *bold* text.', '/topic/body/p[1]/text()'
    assert_xpath_count xml, 2, '/topic/body/p'
  end
end
