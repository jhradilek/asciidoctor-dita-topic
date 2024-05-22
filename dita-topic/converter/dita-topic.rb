# A custom AsciiDoc converter that generates individual DITA topics
# Copyright (C) 2024 Jaromir Hradilek

# MIT License
#
# Permission  is hereby granted,  free of charge,  to any person  obtaining
# a copy of  this software  and associated documentation files  (the "Soft-
# ware"),  to deal in the Software  without restriction,  including without
# limitation the rights to use,  copy, modify, merge,  publish, distribute,
# sublicense, and/or sell copies of the Software,  and to permit persons to
# whom the Software is furnished to do so,  subject to the following condi-
# tions:
#
# The above copyright notice  and this permission notice  shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY KIND,  EXPRESS
# OR IMPLIED,  INCLUDING BUT NOT LIMITED TO  THE WARRANTIES OF MERCHANTABI-
# LITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT
# SHALL THE AUTHORS OR COPYRIGHT HOLDERS  BE LIABLE FOR ANY CLAIM,  DAMAGES
# OR OTHER LIABILITY,  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM,  OUT OF OR IN CONNECTION WITH  THE SOFTWARE  OR  THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# frozen_string_literal: true

module Asciidoctor
class DitaConverter < Asciidoctor::Converter::Base
  NAME = 'dita-topic'
  register_for NAME

  def initialize *args
    super
    outfilesuffix '.dita'
  end

  def convert_document node
    # Check if the modular documentation content type is specified:
    content_type = (node.attr? '_mod-docs-content-type') ? %( outputclass="#{(node.attr '_mod-docs-content-type').downcase}") : ''

    # Return the XML output:
    <<~EOF.chomp
    <?xml version='1.0' encoding='utf-8' ?>
    <!DOCTYPE topic PUBLIC "-//OASIS//DTD DITA Topic//EN" "topic.dtd">
    <topic#{compose_id (node.id or node.attributes['docname'])}#{content_type}>
    <title>#{node.doctitle}</title>
    <body>
    #{node.content}
    </body>
    </topic>
    EOF
  end

  def convert_admonition node
    # NOTE: Unlike admonitions in AsciiDoc, the <note> element in DITA
    # cannot have its own <title>. Admonition titles are therefore not
    # preserved.
    
    # Issue a warning if the admonition has a title:
    if node.title?
      logger.warn "#{NAME}: Admonition title not supported - #{node.title}"
    end

    # Return the XML output:
    <<~EOF.chomp
    <note type="#{node.attr 'name'}">
    #{node.content}
    </note>
    EOF
  end

  def convert_audio node
    # Issue a warning if audio content is present:
    logger.warn "#{NAME}: Audio macro not supported"
    return ''
  end

  # FIXME: Figure out how to handle this along with convert_inline_callout.
  # A definition list looks like a reasonable option.
  def convert_colist node
    # Issue a warning if a callout list is present:
    logger.warn "#{NAME}: Callout list support not implemented"
    return ''
  end

  # FIXME: Handle special cases: horizontal - table.
  # FIXME: Add support for a title.
  def convert_dlist node
    # Check if a different list style is set:
    return compose_horizontal_dlist node if node.style == 'horizontal'
    return compose_qanda_dlist node if node.style == 'qanda'

    # Open the definition list:
    result = ['<dl>']

    # Process individual list items:
    node.items.each do |terms, description|
      # Open the definition entry:
      result << %(<dlentry>)

      # Process individual terms:
      terms.each do |item|
        result << %(<dt>#{item.text}</dt>)
      end

      # Check if the term description is specified:
      if description
        # Check if the description contains multiple block elements:
        if description.blocks?
          result << %(<dd>)
          result << %(<p>#{description.text}</p>) if description.text?
          result << description.content
          result << %(</dd>)
        else
          result << %(<dd>#{description.text}</dd>)
        end
      end

      # Close the definition entry:
      result << %(</dlentry>)
    end

    # Close the definition list:
    result << '</dl>'

    # Return the XML output:
    result.join LF
  end

  def convert_example node
    <<~EOF.chomp
    <example#{compose_id node.id}>
    #{compose_title node.title}#{node.content}
    </example>
    EOF
  end

  def convert_floating_title node
    compose_floating_title node.title, node.level
  end

  # FIXME: Add support for additional attributes.
  def convert_image node
    # Check if the image has a title specified:
    if node.title?
      <<~EOF.chomp
      <fig>
      <title>#{node.title}</title>
      <image href="#{node.image_uri(node.attr 'target')}" placement="break">
      <alt>#{node.alt}</alt>
      </image>
      </fig>
      EOF
    else
      <<~EOF.chomp
      <image href="#{node.image_uri(node.attr 'target')}" placement="break">
      <alt>#{node.alt}</alt>
      </image>
      EOF
    end
  end

  # FIXME: Implement this with the topmost urgency.
  def convert_inline_anchor node
    # Issue a warning if an inline anchor is present:
    logger.warn "#{NAME}: Inline anchor support not implemented"
    return ''
  end

  def convert_inline_break node
    # NOTE: Unlike AsciiDoc, DITA does not support inline line breaks.
    
    # Issue a warning if an inline line break is present:
    logger.warn "#{NAME}: Inline breaks not supported"

    # Return the XML output:
    %(#{node.text}<!-- break -->)
  end

  def convert_inline_button node
    %(<uicontrol outputclass="button">#{node.text}</uicontrol>)
  end

  def convert_inline_callout node
    # Issue a warning if an inline callout is present:
    logger.warn "#{NAME}: Inline callout support not implemented"
    return ''
  end

  # FIXME: Add support for footnoteref equivalent.
  def convert_inline_footnote node
    %(<fn>#{node.text}</fn>)
  end

  # FIXME: Add support for additional attributes.
  def convert_inline_image node
    %(<image href="#{node.image_uri node.target}" placement="inline"><alt>#{node.alt}</alt></image>)
  end

  def convert_inline_indexterm node
    # Issue a warning if an inline index term is present:
    logger.warn "#{NAME}: Inline index terms not implemented"
    return ''
  end

  # FIXME: Investigate if there is an equivalent of <span> in DITA that
  # would group individual <uicontrol> elements together.
  def convert_inline_kbd node
    # Check if there is more than one key:
    if (keys = node.attr 'keys').size == 1
      %(<uicontrol outputclass="key">#{keys[0]}</uicontrol>)
    else
      %(<uicontrol outputclass="key">#{keys.join '</uicontrol>+<uicontrol outputclass="key">'}</uicontrol>)
    end
  end

  def convert_inline_menu node
    # Compose the markup for the menu:
    menu = %(<uicontrol>#{node.attr 'menu'}</uicontrol>)

    # Compose the markup for possible submenus:
    submenus = (not (node.attr 'submenus').empty?) ? %(<uicontrol>#{(node.attr 'submenus').join '</uicontrol><uicontrol>'}</uicontrol>) : ''

    # Compose the markup for the menu item:
    menuitem = (node.attr 'menuitem') ? %(<uicontrol>#{node.attr 'menuitem'}</uicontrol>) : ''

    # Return the XML output:
    %(<menucascade>#{menu}#{submenus}#{menuitem}</menucascade>)
  end

  def convert_inline_quoted node
    # Determine the inline markup type:
    case node.type
    when :emphasis
      %(<i>#{node.text}</i>)
    when :strong
      %(<b>#{node.text}</b>)
    when :monospaced
      %(<tt>#{node.text}</tt>)
    when :superscript
      %(<sup>#{node.text}</sup>)
    when :subscript
      %(<sub>#{node.text}</sub>)
    when :double
      %(&#8220;#{node.text}&#8221;)
    when :single
      %(&#8216;#{node.text}&#8217;)
    else
      node.text
    end
  end

  def convert_listing node
    # Check the listing style:
    if node.style == 'source'
      # Check whether the source language is defined:
      language = (node.attributes.key? 'language') ? %( outputclass="language-#{node.attributes['language']}") : ''

      # Return the XML output:
      <<~EOF.chomp
      <codeblock#{language}>
      #{node.content}
      </codeblock>
      EOF
    else
      # Return the XML output:
      <<~EOF.chomp
      <screen>
      #{node.content}
      </screen>
      EOF
    end
  end

  def convert_literal node
    <<~EOF.chomp
    <pre>
    #{node.content}
    </pre>
    EOF
  end

  # FIXME: Add support for titles.
  def convert_olist node
    # Open the ordered list:
    result = ['<ol>']

    # Process individual list items:
    node.items.each do |item|
      # Check if the list item contains multiple block elements:
      if item.blocks?
        result << %(<li>)
        result << %(<p>#{item.text}</p>)
        result << item.content
        result << %(</li>)
      else
        result << %(<li>#{item.text}</li>)
      end
    end

    # Close the ordered list:
    result << '</ol>'

    # Return the XML output:
    result.join LF
  end

  # FIXME: This is not the top priority.
  def convert_open node
    ''
  end

  def convert_page_break node
    # NOTE: Unlike AsciiDoc, DITA does not support page breaks.

    # Issue a warning if a page break is present:
    logger.warn "#{NAME}: Page breaks not supported"

    # Return the XML output:
    %(<p outputclass="page-break"></p>)
  end

  def convert_paragraph node
    # Check if the paragraph has a title assigned:
    if node.title?
      <<~EOF.chomp
      <div outputclass="paragraph">
      #{compose_floating_title node.title}<p>#{node.content}</p>
      </div>
      EOF
    else
      %(<p>#{node.content}</p>)
    end
  end

  def convert_preamble node
    node.content
  end

  def convert_quote node
    # Check if the author is defined:
    author = (node.attr? 'attribution') ? %(\n<p>&#8212; #{node.attr 'attribution'}</p>) : ''

    # Check if the citation source is defined:
    source = (node.attr? 'citetitle') ? %(\n<cite>#{node.attr 'citetitle'}</cite>) : ''

    # Check if the content contains multiple block elements:
    if node.content_model == :compound
      <<~EOF.chomp
      <lq>
      #{compose_floating_title node.title}#{node.content}#{author}#{source}
      </lq>
      EOF
    else
      <<~EOF.chomp
      <lq>
      #{compose_floating_title node.title}<p>#{node.content}</p>#{author}#{source}
      </lq>
      EOF
    end
  end

  def convert_section node
    # NOTE: Unlike sections in AsciiDoc, the <section> element in DITA
    # cannot be nested. Consequently, converting AsciiDoc files that do
    # contain nested subsections will result in invalid markup.
    #
    # I explored the possibility to use the <topic> element instead as it
    # can be nested, but that presents a problem with closing the <body>
    # element of the parent <topic>. As only a very small number of
    # AsciiDoc modules contain nested subsections, I chose the simple
    # markup.

    <<~EOF.chomp
    <section#{compose_id node.id}>
    <title>#{node.title}</title>
    #{node.content}
    </section>
    EOF
  end

  def convert_sidebar node
    # NOTE: Unlike AsciiDoc, DITA does not provide markup for a sidebar. As
    # a workaround, I decided to use a div with the outputclass attribute.

    # Check if the content contains multiple block elements:
    if node.content_model == :compound
      <<~EOF.chomp
      <div outputclass="sidebar">
      #{compose_floating_title node.title}#{node.content}
      </div>
      EOF
    else
      <<~EOF.chomp
      <div outputclass="sidebar">
      #{compose_floating_title node.title}<p>#{node.content}</p>
      </div>
      EOF
    end
  end

  def convert_stem node
    # Issue a warning if a STEM content is present:
    logger.warn "#{NAME}: STEM support not implemented"
    return ''
  end

  # FIXME: Add support for additional attributes.
  def convert_table node
    ''
  end

  def convert_thematic_break node
    # NOTE: Unlike AsciiDoc, DITA does not support thematic breaks.

    # Issue a warning if a thematic break is present:
    logger.warn "#{NAME}: Thematic breaks not supported"

    # Return the XML output:
    %(<p outputclass="thematic-break"></p>)
  end

  # FIXME: Add support for titles.
  def convert_ulist node
    # Open the unordered list:
    result = ['<ul>']

    # Process individual list items:
    node.items.each do |item|
      # Check if the list item is part of a checklist:
      unless item.attr? 'checkbox'
        check_box = ''
      else
        check_box = (item.attr? 'checked') ? '&#10003; ' : '&#10063; '
      end

      # Check if the list item contains multiple block elements:
      if item.blocks?
        result << %(<li>)
        result << %(<p>#{check_box}#{item.text}</p>)
        result << item.content
        result << %(</li>)
      else
        result << %(<li>#{check_box}#{item.text}</li>)
      end
    end

    # Close the unordered list:
    result << '</ul>'

    # Returned the XML output:
    result.join LF
  end

  def convert_verse node
    # Check if the author is defined:
    author = (node.attr? 'attribution') ? %(\n&#8212; #{node.attr 'attribution'}) : ''

    # Check if the citation source is defined:
    source = (node.attr? 'citetitle') ? %(\n<cite>#{node.attr 'citetitle'}</cite>) : ''

    # Return the XML output:
    <<~EOF.chomp
    <lines>
    #{node.content}#{author}#{source}
    </lines>
    EOF
  end

  def convert_video node
    # Issue a warning if video content is present:
    logger.warn "#{NAME}: Video macro not supported"
    return ''
  end

  def compose_qanda_dlist node
    # Open the ordered list:
    result = ['<ol>']

    # Process individual list items:
    node.items.each do |terms, description|
      # Open the list item:
      result << %(<li>)

      # Process individual terms:
      terms.each do |item|
        result << %(<p outputclass="question"><i>#{item.text}</i></p>)
      end

      # Check if the term description is specified:
      if description
        result << %(<p>#{description.text}</p>)
        result << description.content if description.blocks?
      end

      # Close the list item:
      result << %(</li>)
    end
    
    # Close the ordered list:
    result << '</ol>'

    # Return the XML output:
    result.join LF
  end

  def compose_horizontal_dlist node
    # Open the table:
    result = ['<table>']

    # Define the table properties and open the tgroup:
    result << %(<tgroup cols="2">)
    result << %(<colspec colwidth="#{node.attr 'labelwidth', 15}*" />)
    result << %(<colspec colwidth="#{node.attr 'itemwidth', 85}*" />)

    # Open the table body:
    result << %(<tbody>)

    # Process individual list items:
    node.items.each do |terms, description|
      # Open the table row:
      result << %(<row>)

      # Check the number of terms to process:
      if terms.count == 1
        result << %(<entry><b>#{terms[0].text}</b></entry>)
      else
        # Process individual terms:
        result << %(<entry>)
        terms.each do |item|
          result << %(<p><b>#{item.text}</b></p>)
        end
        result << %(</entry>)
      end

      # Check if the term description is specified:
      if description
        # Check if the description contains multiple block elements:
        if description.blocks?
          result << %(<entry>)
          result << %(<p>#{description.text}</p>) if description.text?
          result << description.content
          result << %(</entry>)
        else
          result << %(<entry>#{description.text}</entry>) if description.text?
        end
      end

      # Close the table row:
      result << %(</row>)
    end

    # Close the table:
    result << %(</tbody>)
    result << %(</tgroup>)
    result << %(</table>)
  end

  def compose_floating_title title, section_level=false
    # NOTE: Unlike AsciiDoc, DITA does not support floating titles or
    # titles assigned to certain block elements. As a workaround, I decided
    # to use a paragraph with the outputclass attribute.

    # Check whether the section level is defined:
    level = section_level ? %( sect#{section_level}) : ''

    # Return the XML output:
    title ? %(<p outputclass="title#{level}"><b>#{title}</b></p>\n) : ''
  end

  def compose_id id
    id ? %( id="#{id}") : ''
  end

  def compose_title title
    title ? %(<title>#{title}</title>\n) : ''
  end
end
end
