require 'minitest/autorun'
require_relative 'helper'

class InlineAnchorTest < Minitest::Test
  def test_external_website
    xml = <<~EOF.chomp.to_dita
    Links can look like https://example.com, <https://example.com>, https://example.com[my site], or link:++https://example.com++[my site].
    EOF

    assert_xpath_count xml, 4, '//xref[@href="https://example.com" and @scope="external"]'
  end

  def test_external_email
    xml = <<~EOF.chomp.to_dita
    Email addresses can look like admin@example.com or mailto:admin@example.com[Contact us].
    EOF

    assert_xpath_count xml, 2, '//xref[@href="mailto:admin@example.com" and @scope="external"]'
  end

  def test_external_file
    xml = <<~EOF.chomp.to_dita
    Link to an link:test.html[HTML] or a link:/etc/passwd[plain text] file.
    EOF

    assert_xpath_equal xml, 'test.html', '//xref[text()="HTML"]/@href'
    assert_xpath_equal xml, '/etc/passwd', '//xref[text()="plain text"]/@href'
  end

  def test_inline_anchor
    xml = <<~EOF.chomp.to_dita
    = [[inline-anchor]]Test title
    EOF

    assert_xpath_equal xml, 'inline-anchor', '//title/i/@id'
  end

  def test_bibliographic_reference
    xml = <<~EOF.chomp.to_dita
    [bibliography]
    * [[[st]]] Sample text.
    EOF

    assert_xpath_equal xml, 'st', '//ul/li/i/@id'
  end

  def test_xrefs_to_anchors
    xml = <<~EOF.chomp.to_dita
    Cross references can look like <<this>>, or xref:this[].
    EOF

    assert_xpath_count xml, 2, '//xref[@href="#this"]'
  end

  def test_xrefs_to_files
    xml = <<~EOF.chomp.to_dita
    Cross references can look like xref:file.adoc[].
    EOF

    assert_xpath_equal xml, 'file.dita', '//xref/@href'
  end

  def test_explicit_xref_text
    xml = <<~EOF.chomp.to_dita
    Cross references can use <<simple-syntax,with custom text>> or xref:xref-macro[with custom text]. Text can also be added to xref:file.adoc[file references].
    EOF

    assert_xpath_equal xml, 'with custom text', '//xref[@href="#simple-syntax"]/text()'
    assert_xpath_equal xml, 'with custom text', '//xref[@href="#xref-macro"]/text()'
    assert_xpath_equal xml, 'file references', '//xref[@href="file.dita"]/text()'
  end
end
