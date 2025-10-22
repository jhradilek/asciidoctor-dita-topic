require 'minitest/autorun'
require_relative 'helper'

class TableTest < Minitest::Test
  def test_table_header
    xml = <<~EOF.chomp.to_dita
    [cols="1, 1"]
    |===
    |Column 1 header|Column 2 header

    |Column 1
    |Column 2
    |===
    EOF

    assert_xpath_equal xml, 'Column 1 header', '//table/tgroup/thead/row/entry[1]/text()'
    assert_xpath_equal xml, 'Column 2 header', '//table/tgroup/thead/row/entry[2]/text()'
  end

  def test_table_body
    xml = <<~EOF.chomp.to_dita
    [cols="1, 1"]
    |===
    |Column 1
    |Column 2
    |===
    EOF

    assert_xpath_equal xml, 'Column 1', '//table/tgroup/tbody/row/entry[1]/p/text()'
    assert_xpath_equal xml, 'Column 2', '//table/tgroup/tbody/row/entry[2]/p/text()'
  end

  def test_table_title
    xml = <<~EOF.chomp.to_dita
    .Table title
    [cols="1, 1"]
    |===
    |Column 1
    |Column 2
    |===
    EOF

    assert_xpath_equal xml, 'Table title', '//table/title/text()'
  end

  def test_integer_column_width
    xml = <<~EOF.chomp.to_dita
    [cols="3, 1"]
    |===
    |Column 1 with the proportional width of 3
    |Column 2 with the proportional width of 1
    |===
    EOF

    assert_xpath_equal xml, '75*', '//table/tgroup/colspec[1]/@colwidth'
    assert_xpath_equal xml, '25*', '//table/tgroup/colspec[2]/@colwidth'
  end

  def test_percentage_column_width
    xml = <<~EOF.chomp.to_dita
    [cols="75%, 25%"]
    |===
    |Column 1 with the proportional width of 75%
    |Column 2 with the proportional width of 25%
    |===
    EOF

    assert_xpath_equal xml, '75*', '//table/tgroup/colspec[1]/@colwidth'
    assert_xpath_equal xml, '25*', '//table/tgroup/colspec[2]/@colwidth'
  end

  def test_column_formatting
    xml = <<~EOF.chomp.to_dita
    [cols="e, s, m, l"]
    |===
    |Emphasis
    |Strong
    |Monospace
    |Literal
    |===
    EOF

    assert_xpath_equal xml, 'i', 'name(//table/tgroup/tbody/row/entry[1]/p/*)'
    assert_xpath_equal xml, 'b', 'name(//table/tgroup/tbody/row/entry[2]/p/*)'
    assert_xpath_equal xml, 'codeph', 'name(//table/tgroup/tbody/row/entry[3]/p/*)'
    assert_xpath_equal xml, 'pre', 'name(//table/tgroup/tbody/row/entry[4]/*)'
  end

  def test_cell_formatting
    xml = <<~EOF.chomp.to_dita
    [cols="1, 1, 1, 1"]
    |===
    e|Italics
    s|Bold
    m|Monospace
    l|Literal
    |===
    EOF

    assert_xpath_equal xml, 'i', 'name(//table/tgroup/tbody/row/entry[1]/p/*)'
    assert_xpath_equal xml, 'b', 'name(//table/tgroup/tbody/row/entry[2]/p/*)'
    assert_xpath_equal xml, 'codeph', 'name(//table/tgroup/tbody/row/entry[3]/p/*)'
    assert_xpath_equal xml, 'pre', 'name(//table/tgroup/tbody/row/entry[4]/*)'
  end

  def test_column_span
    xml = <<~EOF.chomp.to_dita
    [cols="1, 1, 1"]
    |===
    2+|Column 1 and 2
    |Column 3
    |===
    EOF

    assert_xpath_equal xml, 'col_1', '//table/tgroup/tbody/row/entry[1]/@namest'
    assert_xpath_equal xml, 'col_2', '//table/tgroup/tbody/row/entry[1]/@nameend'
    assert_xpath_equal xml, 'Column 1 and 2', '//table/tgroup/tbody/row/entry[1]/p/text()'
    assert_xpath_equal xml, 'Column 3', '//table/tgroup/tbody/row/entry[2]/p/text()'
  end

  def test_row_span
    xml = <<~EOF.chomp.to_dita
    [cols="1, 1"]
    |===
    .2+|Row 1 and 2, column 1
    |Row 1, column 2

    |Row 2, column 2
    |===
    EOF

    assert_xpath_equal xml, '1', '//table/tgroup/tbody/row[1]/entry[1]/@morerows'
    assert_xpath_equal xml, 'Row 1 and 2, column 1', '//table/tgroup/tbody/row[1]/entry[1]/p/text()'
    assert_xpath_equal xml, 'Row 1, column 2', '//table/tgroup/tbody/row[1]/entry[2]/p/text()'
    assert_xpath_equal xml, 'Row 2, column 2', '//table/tgroup/tbody/row[2]/entry[1]/p/text()'
  end

  def test_table_role
    xml = <<~EOF.chomp.to_dita
    [cols="1, 1",role="platform:linux"]
    |===
    |Column 1 header|Column 2 header

    |Column 1
    |Column 2
    |===
    EOF

    assert_xpath_equal xml, 'linux', '//table/@platform'
  end

  def test_table_row_role
    xml = <<~EOF.chomp.to_dita
    [cols="1, 1"]
    |===
    |[.platform:linux]#\{empty\}# Column 1 header|Column 2 header

    |[.platform:linux]#\{empty\}# Column 1
    |Column 2
    |===
    EOF

    assert_xpath_equal xml, 'linux', '//thead/row/@platform'
    assert_xpath_equal xml, 'linux', '//tbody/row/@platform'
    assert_xpath_count xml, 0, '//ph'
  end

  def test_table_id
    xml = <<~EOF.chomp.to_dita
    [cols="1, 1",id="table-id"]
    |===
    |Column 1 header|Column 2 header

    |Column 1
    |Column 2
    |===
    EOF

    assert_xpath_equal xml, 'table-id', '//table/@id'
  end

  def test_table_no_id
    xml = <<~EOF.chomp.to_dita
    [cols="1, 1"]
    |===
    |Column 1 header|Column 2 header

    |Column 1
    |Column 2
    |===
    EOF

    assert_xpath_count xml, 0, '//table/@id'
  end
end
