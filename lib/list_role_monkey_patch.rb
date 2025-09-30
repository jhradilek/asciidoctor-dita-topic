require 'asciidoctor'

# Monkey-patch to support [.role] between list items
#
# Example that now works:
#   . Item 1
#   [.special]
#   . Item 2  <-- gets role "special"
#
# Strategy: Patch read_lines_for_list_item to detect and extract orphaned
# [.role] lines, then apply them to the next list item.

module Asciidoctor
  class Parser
    class << self
      # Class variable to carry role forward from one list item to the next
      @role_carryover = nil

      # Save original methods
      alias_method :original_parse_list, :parse_list
      alias_method :original_parse_list_item, :parse_list_item
      alias_method :original_read_lines_for_list_item, :read_lines_for_list_item

      # Patch parse_list to reset carryover at start of list
      def parse_list(reader, list_type, parent, style)
        @role_carryover = nil  # Reset when starting a new list
        original_parse_list(reader, list_type, parent, style)
      end

      # Patch read_lines_for_list_item to detect orphaned [.role] at the end
      def read_lines_for_list_item(reader, list_type, sibling_trait = nil, has_text = true)
        # Call original to get the lines
        lines = original_read_lines_for_list_item(reader, list_type, sibling_trait, has_text)

        # Check if the last line (or last non-blank line) is a [.role]
        # Search backwards from the end to find last non-blank line
        last_line_index = nil
        (lines.length - 1).downto(0) do |i|
          unless lines[i].strip.empty?
            last_line_index = i
            break
          end
        end

        # If we found a non-blank line and it's a role attribute, remove it
        if last_line_index && is_role_attribute_line?(lines[last_line_index].rstrip)
          role = extract_role_from_line(lines[last_line_index].rstrip)
          @role_carryover = role
          # Remove it from the buffer
          lines.delete_at(last_line_index)
        end

        lines
      end

      # Patch parse_list_item to apply carried-over role
      def parse_list_item(reader, list_block, match, sibling_trait, style = nil)
        # Save the current carryover before calling original
        # (because original will call read_lines_for_list_item which may set a new carryover)
        role_to_apply = @role_carryover
        @role_carryover = nil  # Clear before processing this item

        # Call the original method to get the parsed node
        list_item_or_pair = original_parse_list_item(reader, list_block, match, sibling_trait, style)

        # Apply the role that was carried over FROM THE PREVIOUS item
        if role_to_apply
          # Get the actual list item (for dlist it's a pair [term, definition])
          target_item = if list_block.context == :dlist
            list_item_or_pair[1]  # Apply role to definition
          else
            list_item_or_pair
          end

          if target_item
            # Apply the role (note: .role and attributes['role'] are synchronized,
            # so we only need to set one)
            if target_item.role
              target_item.role = "#{target_item.role} #{role_to_apply}"
            else
              target_item.role = role_to_apply
            end
          end
        end

        list_item_or_pair
      end

      private

      # Check if a line is a role attribute like [.role]
      def is_role_attribute_line?(line)
        # Trim spaces on the right as they're just editor artifacts
        line = line.rstrip

        return false unless line.start_with?('[.') && line.end_with?(']')
        return false if line.include?(' ')  # Must be compact

        content = line[1..-2]  # Remove [ and ]
        content.start_with?('.')
      end

      # Extract role name from [.role] line
      def extract_role_from_line(line)
        line = line.rstrip
        content = line[1..-2]  # Remove [ and ]
        content[1..-1]  # Remove leading dot
      end
    end
  end
end

puts "List role monkey-patch loaded"
