#!/bin/bash

# convert-file - convert an AsciiDoc file to a DITA topic or a DITA map
# Copyright (C) 2026 Jaromir Hradilek

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

# General information about the script:
declare -r NAME=${0##*/}

# Set the default options:
declare -i OPT_WATCH=0

# Print a message to standard error output and terminate the script with
# the selected exit status.
#
# Usage: exit_with_error ERROR_MESSAGE [EXIT_STATUS]
function exit_with_error {
  local -r error_message=${1:-'An unexpected error has occurred.'}
  local -r exit_status=${2:-1}

  echo -e "$NAME: $error_message" >&2
  exit $exit_status
}

# Print a formatted error message to standard error output.
#
# Usage: err MESSAGE
function err {
  local -r message="$1"

  gum log --structured --time TimeOnly --level error "$@"
}

# Print a formatted warning message to standard error output.
#
# Usage: warn MESSAGE
function warn {
  local -r message="$1"

  gum log --structured --time TimeOnly --level warn "$@"
}

# Print a formatted message to standard error output.
#
# Usage: log MESSAGE...
function log {
  gum log --structured --time TimeOnly --level info "$@"
}

# Print a banner with a formatted message to standard outptut.
#
# Usage: banner MESSAGE...
function banner {
  gum style --width 70 --border thick --border-foreground 4 --align center --margin "1 2" --padding "2 4" "$@"
}

# Convert a file marked as an assembly or a map to a DITA map.
#
# Usage: convert_to_map FILE_NAME CONTENT_TYPE
function convert_to_map {
  local -r file_name="$1"
  local -r content_type="$2"

  # Derive the output file name:
  local -r output_file=${file_name%.adoc}.ditamap

  # Convert the file to a DITA map:
  if [[ "$content_type" == 'assembly' ]]; then
    local -r error_log=$(dita-map --include-self "$file_name" 2>&1)
  else
    local -r error_log=$(dita-map --zero-offset "$file_name" 2>&1)
  fi

  # Capture the exit status:
  local -r exit_code="$?"

  # Filter and report any warnings:
  echo "$error_log" | sed -ne 's|^dita-map: warning: ||p' | while read line; do
    warn "$line" output "$output_file" input "$file_name"
  done

  # Filter and report any errors:
  echo "$error_log" | sed -ne 's|^dita-map: error: ||p' | while read line; do
    err "$line" output "$output_file" input "$file_name"
  done

  # Check if the conversion succeeded:
  if [[ "$exit_code" -ne 0 ]]; then
    err "Unable to create a DITA map" output "$output_file" input "$file_name"
    return
  fi

  # Report success:
  log "Created a DITA map" output "$output_file" input "$file_name" 
}

# Determine the content type of the supplied AsciiDoc file and convert
# it to the corresponding DITA topic or a map.
#
# Usage: convert_file FILE_NAME
function convert_file {
  local -r file_name="$1"

  # Determine the content type:
  local -r content_type=$(dita-type "$file_name")

  # Report an unsupported content type:
  if [[ ! "$content_type" =~ ^(assembly|concept|reference|task|map)$ ]]; then
    warn "Unsuppported content type" type "$content_type" input "$file_name"
    return
  fi

  # Convert the file to a DITA map:
  if [[ "$content_type" =~ ^(assembly|map)$ ]]; then
    convert_to_map "$file_name" "$content_type"
  fi
}

# Watch the supplied AsciiDoc file and re-convert it whenever its contents
# changes.
#
# Usage: watch_file FILE_NAME
function watch_file {
  local -r file_name="$1"

  # Print the banner:
  banner "Monitoring the supplied file for changes." "To exit this mode, press ^C (Ctrl+C)."

  # Monitor the file for changes:
  echo "$file_name" | entr -r bash -c "convert_file \"$file_name\""
}

# Export functions that must be available in subshells:
export -f err warn log banner
export -f convert_file convert_to_map

# Process command-line options:
while getopts ':hw' OPTION; do
  case "$OPTION" in
    w)
      # Enable continuous processing of the supplied file:
      OPT_WATCH=1
      ;;
    h)
      # Print usage information to standard output:
      echo "Usage: $NAME FILE"
      echo -e "       $NAME -h\n"
      echo "  -w      watch the file and reconvert it whenever it changes"
      echo "  -h      display this help and exit"

      # Terminate the script:
      exit 0
      ;;
    *)
      # Report an invalid option and terminate the script:
      exit_with_error "Invalid option -- '$OPTARG'" 22
      ;;
  esac
done

# Shift positional parameters:
shift $(($OPTIND - 1))

# Verify the number of command line arguments:
[[ "$#" -eq 1 ]] || exit_with_error 'Invalid number of arguments' 22

# Get the name of the file to convert:
declare -r file="$1"

# Verify that the file exists:
[[ -e "$file" ]] || exit_with_error "$file: No such file or directory" 2
[[ -r "$file" ]] || exit_with_error "$file: Permission denied" 13
[[ -f "$file" ]] || exit_with_error "$file: Not a file" 21

# Verify that the file has the a valid AsciiDoc file extension:
[[ "$file" =~ .*\.a(doc|sciidoc|sc|d)$ ]] || exit_with_error "$file: Not an AsciiDoc file" 22

# Determine which mode to run in:
if [[ "$OPT_WATCH" -eq 0 ]]; then
  # Convert the file one time:
  convert_file "$file"
else
  # Watch the file for updates and continuously convert it:
  watch_file "$file"
fi

# Terminate the script:
exit 0
