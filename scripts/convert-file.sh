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
declare -a OPT_OPTS=()

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

# Print a formatted message to standard error output.
#
# Usage: log LEVEL MESSAGE...
function log {
  local -r level="$1"
  shift 1

  gum log --structured --time TimeOnly --level "$level" "$@"
}

# Print a banner with a formatted message to standard outptut.
#
# Usage: banner MESSAGE...
function banner {
  gum style --width 70 --border thick --border-foreground 4 --align center --margin "1 2" --padding "2 4" "$@"
}

# Convert the supplied file to a DITA map.
#
# Usage: convert_to_map FILE_NAME CONTENT_TYPE
function convert_to_map {
  local -r file_name="$1"
  local -r content_type="$2"

  # Derive the output file name:
  local -r output_file="${file_name%.adoc}.ditamap"

  # Create a temporary to capture error log:
  local -r error_log=$(mktemp --tmpdir "$NAME".XXXXXXXXXX)

  # Convert the file to a DITA map:
  if [[ "$content_type" == 'assembly' ]]; then
    dita-map "${OPT_OPTS[@]}" --include-self "$file_name" 2> "$error_log"
  else
    dita-map "${OPT_OPTS[@]}" --zero-offset "$file_name" 2> "$error_log"
  fi

  # Capture the exit status:
  local -r exit_code="$?"

  # Filter and report any warnings:
  sed -ne 's/^dita-map: warning: //ip' "$error_log" | while read line; do
    log warn "$line" output "$output_file" input "$file_name"
  done

  # Filter and report any errors:
  sed -ne 's/^dita-map: error: //ip' "$error_log" | while read line; do
    log error "$line" output "$output_file" input "$file_name"
  done

  # Remove the temporary file:
  rm "$error_log"

  # Check if the conversion succeeded:
  if [[ "$exit_code" -ne 0 ]]; then
    log fatal "Unable to create a DITA map" output "$output_file" input "$file_name"
    return 1
  fi

  # Report success:
  log info "Created a DITA map" output "$output_file" input "$file_name"
}

# Convert the supplied file to a DITA concept, reference, or task.
#
# Usage: convert_to_topic FILE_NAME CONTENT_TYPE
function convert_to_topic {
  local -r file_name="$1"
  local -r content_type="$2"

  # Derive the output file name:
  local -r output_file="${file_name%.adoc}.dita"

  # Create a temporary to capture error log:
  local -r error_log=$(mktemp --tmpdir "$NAME".XXXXXXXXXX)

  # Convert the file to a DITA topic:
  if [[ "$content_type" == 'assembly' ]]; then
    (dita-topic "${OPT_OPTS[@]}" --no-module --out-file - "$file_name" | dita-convert --generated --output "$output_file") 2> "$error_log"
  else
    (dita-topic "${OPT_OPTS[@]}" --out-file - "$file_name" | dita-convert --generated --output "$output_file") 2> "$error_log"
  fi

  # Capture the exit status:
  local exit_code="$?"

  # Filter and report any warnings:
  sed -ne 's/^\(dita-convert: WARNING\|[^:]*: WARNING: dita-topic\): //ip' "$error_log" | while read line; do
    log warn "$line" output "$output_file" input "$file_name"
  done

  # Filter and report any errors:
  sed -ne 's/^\(dita-convert: ERROR\|[^:]*: ERROR: dita-topic\): //ip' "$error_log" | while read line; do
    log error "$line" output "$output_file" input "$file_name"
  done

  # Remove the temporary file:
  rm "$error_log"

  # Check if the conversion succeeded:
  if [[ "$exit_code" -ne 0 ]]; then
    log fatal "Unable to create a DITA ${content_type/#assembly/concept}" output "$output_file" input "$file_name"
    return 1
  fi

  # Report success:
  log info "Created a DITA ${content_type/#assembly/concept}" output "$output_file" input "$file_name"
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
    log warn "Unsuppported content type" type "$content_type" input "$file_name"
    return
  fi

  # Convert the file to a DITA map:
  if [[ "$content_type" =~ ^(assembly|map)$ ]]; then
    convert_to_map "$file_name" "$content_type"
  fi

  # Convert the file to a DITA topic:
  if [[ "$content_type" =~ ^(assembly|concept|reference|task)$ ]]; then
    convert_to_topic "$file_name" "$content_type"
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
export -f log banner
export -f convert_file convert_to_map convert_to_topic

# Process command-line options:
while getopts ':ha:p:w' OPTION; do
  case "$OPTION" in
    a)
      # Append the attribute definition to the list of common options:
      OPT_OPTS+=('-a' "$OPTARG")
      ;;
    p)
      # Append the prepended file to the list of common options:
      OPT_OPTS+=('-p' "$OPTARG")
      ;;
    w)
      # Enable continuous processing of the supplied file:
      OPT_WATCH=1
      ;;
    h)
      # Print usage information to standard output:
      echo "Usage: $NAME [-w] [-a ATTRIBUTE] [-p FILE] FILE"
      echo "       $NAME -h"
      echo
      echo "  -w               watch the file and reconvert it whenever it changes"
      echo "  -a ATTRIBUTE     set a document attribute in the form of name, name!,"
      echo "                   or name=value pair; can be supplied multiple times"
      echo "  -p FILE          prepend a file to the input file, typically to bring"
      echo "                   in attribute definitions; can be supplied multiple"
      echo "                   times"
      echo
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
  convert_file "$file" || exit 1
else
  # Watch the file for updates and continuously convert it:
  watch_file "$file"
fi

# Terminate the script:
exit 0
