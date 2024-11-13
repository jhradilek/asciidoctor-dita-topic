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

    assert_xpath_equal xml, '2', '//table/tgroup/@cols'
    assert_xpath_equal xml, '&#9312;', '//table/tgroup/tbody/row[1]/entry[1]/text()'
    assert_xpath_equal xml, 'Extend the String class', '//table/tgroup/tbody/row[1]/entry[2]/p/text()'
    assert_xpath_equal xml, '&#9313;', '//table/tgroup/tbody/row[2]/entry[1]/text()'
    assert_xpath_equal xml, 'Define a new method', '//table/tgroup/tbody/row[2]/entry[2]/p/text()'
    assert_xpath_equal xml, '&#9314;', '//table/tgroup/tbody/row[3]/entry[1]/text()'
    assert_xpath_equal xml, 'Convert self to DocBook 5', '//table/tgroup/tbody/row[3]/entry[2]/p/text()'
  end

  def test_colist_outputclass
    xml = <<~EOF.chomp.to_dita
    ----
    Code line <1>
    ----
    <1> Code description
    EOF

    assert_xpath_equal xml, 'callout-list', '//table/@outputclass'
  end
end
