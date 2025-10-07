require 'minitest/autorun'
require_relative 'helper'

class ColistTest < Minitest::Test
  def test_simple_colist
    xml = <<~EOF.chomp.to_dita
    [source,ruby]
    ----
    require 'asciidoctor'

    class String <1>
      def to_docbook <2>
        return Asciidoctor.convert self, backend: 'docbook5', standalone: true <3>
      end
    end
    ----
    <1> Extend the String class
    <2> Define a new method
    <3> Convert self to DocBook 5
    EOF

    assert_xpath_count xml, 3, '//dl/dlentry'
    assert_xpath_equal xml, '&#9312;', '//dl/dlentry[1]/dt/text()'
    assert_xpath_equal xml, 'Extend the String class', '//dl/dlentry[1]/dd/text()'
    assert_xpath_equal xml, '&#9313;', '//dl/dlentry[2]/dt/text()'
    assert_xpath_equal xml, 'Define a new method', '//dl/dlentry[2]/dd/text()'
    assert_xpath_equal xml, '&#9314;', '//dl/dlentry[3]/dt/text()'
    assert_xpath_equal xml, 'Convert self to DocBook 5', '//dl/dlentry[3]/dd/text()'
  end

  def test_colist_outputclass
    xml = <<~EOF.chomp.to_dita
    ----
    Code line <1>
    ----
    <1> Code description
    EOF

    assert_xpath_equal xml, 'callout-list', '//dl/@outputclass'
  end

  def test_colist_role
    xml = <<~EOF.chomp.to_dita
    ----
    Code line <1>
    ----
    [role="platform:linux"]
    <1> Code description
    EOF

    assert_xpath_equal xml, 'linux', '//dl/@platform'
  end

  def test_colist_id
    xml = <<~EOF.chomp.to_dita
    ----
    Code line <1>
    ----
    [#colist-id]
    <1> Code description
    EOF

    assert_xpath_equal xml, 'colist-id', '//dl/@id'
  end

  def test_colist_no_id
    xml = <<~EOF.chomp.to_dita
    ----
    Code line <1>
    ----
    <1> Code description
    EOF

    assert_xpath_count xml, 0, '//dl/@id'
  end
end
