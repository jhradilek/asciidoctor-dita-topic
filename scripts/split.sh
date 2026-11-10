#!/bin/bash

# split - convert an entire AsciiDoc document to individual DITA topics
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
declare -a OPT_ARGS=()
declare -i OPT_DEBUG=0
declare    OPT_OUTPUT=''

# Export the default options:
export OPT_ARGS
export OPT_DEBUG

# Set default colors:
export CLR_BOLD=$(tput bold)
export CLR_INFO=$(tput setaf 14)
export CLR_WARNING=$(tput setaf 11)
export CLR_ERROR=$(tput setaf 9)
export CLR_FATAL=$(tput setaf 13)
export CLR_KEYWORD=$(tput setaf 12)
export CLR_RESET=$(tput sgr0)

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

# Print usage information to standard output.
#
# Usage: print_usage
function print_usage {
  echo "Usage: $NAME [-adC] [-a ATTRIBUTE] [-p FILE] [-o DIRECTORY] FILE"
  echo
  echo "  Convert an AsciiDoc FILE to a generic DITA topic. If an output DIRECTORY is"
  echo "  supplied, split individual sections into separate DITA concepts, tasks, and"
  echo "  references and generate a corresponding DITA map."
  echo
  echo "  -o DIRECTORY   store the DITA concepts, tasks, references, and the"
  echo "                 corresponding map in the selected DIRECTORY."
  echo "  -C             do not add colors to log messages"
  echo
  echo "  -a ATTRIBUTE   set a document attribute in the form of name, name!,"
  echo "                 or name=value pair; can be supplied multiple times"
  echo "  -p FILE        prepend a file to the input file, typically to bring"
  echo "                 in attribute definitions; can be supplied multiple"
  echo "                 times"
  echo
  echo "  -d             print unfiltered error log to standard error output"
}

# Print a formatted message to standard error output.
#
# Usage: log LEVEL MESSAGE...
function log {
  local -r level="$1"
  local -r message="$2"
  shift 2

  # Compose the first part of the log message:
  case "$level" in
    fatal)
      local result="$CLR_BOLD$CLR_FATAL${level^^}$CLR_RESET $message"
      ;;
    error)
      local result="$CLR_BOLD$CLR_ERROR${level^^}$CLR_RESET $message"
      ;;
    info)
      local result="$CLR_BOLD$CLR_INFO${level^^}$CLR_RESET $message"
      ;;
    *)
      local result="$CLR_BOLD$CLR_WARNING${level^^}$CLR_RESET $message"
      ;;
  esac

  # Append the key and value pairs:
  while [[ "$#" -ge 2 ]]; do
    result+=" $CLR_KEYWORD$1=$CLR_RESET$2"
    shift 2
  done

  # Append any leftover values:
  [[ "$#" -eq 1 ]] && result+=" $1"

  # Print the message:
  echo "$(date +%T) $result"
}

# Convert the supplied file to a generic DITA topic.
#
# Usage: convert_to_topic INPUT_FILE OUTPUT_FILE
function convert_to_topic {
  local -r input_file="$1"
  local -r output_file="$2"

  # Restore the array variable declaration in a subshell:
  eval "$PACK_ARGS"

  # Create a temporary to capture error log:
  local -r error_log=$(mktemp --tmpdir "$NAME".XXXXXXXXXX)

  # Convert the file to a DITA topic:
  (dita-topic "${OPT_ARGS[@]}" -Bto "$output_file" "$input_file") 2> "$error_log"

  # Capture the exit status:
  local exit_code="$?"

  # Print the unfiltered error log in debug mode:
  if [[ "$OPT_DEBUG" -eq 1 ]]; then
    cat "$error_log" >&2
  fi

  # Filter and report any warnings:
  sed -ne 's/^[^:]*: WARNING: \(dita-topic\|<stdin>\): //ip' "$error_log" | while read line; do
    # Filter out warnings related to nesting sections as they are expected:
    [[ "$line" =~ "Nesting of sections not supported in DITA" ]] && continue

    # Report the warning:
    log warn "$line" output "$output_file" input "$input_file"
  done

  # Filter and report any errors:
  sed -ne 's/^[^:]*: ERROR: \(dita-topic\|<stdin>\): //ip' "$error_log" | while read line; do
    log error "$line" output "$output_file" input "$input_file"
  done

  # Remove the temporary file:
  rm "$error_log"

  # Check if the conversion succeeded:
  if [[ "$exit_code" -ne 0 ]]; then
    log fatal "Unable to create a generic DITA topic" output "$output_file" input "$file_name"
    return 1
  fi

  # Report success:
  log info "Created a generic DITA topic" output "$output_file" input "$input_file"
}

# Split the supplied DITA topic to individual DITA concepts, references, and
# tasks.
#
# Usage: split_topic INPUT_FILE OUTPUT_DIRECTORY
function split_topic {
  local -r input_file="$1"
  local -r output_directory="$2"

  # Create a temporary to capture error log:
  local -r error_log=$(mktemp --tmpdir "$NAME".XXXXXXXXXX)

  # Split the DITA topic:
  (dita-convert -gsd "$output_directory" "$input_file") 2> "$error_log"

  # Capture the exit status:
  local exit_code="$?"

  # Print the unfiltered error log in debug mode:
  if [[ "$OPT_DEBUG" -eq 1 ]]; then
    cat "$error_log" >&2
  fi

  # Filter and report any warnings:
  grep -ie '^\(dita-convert: WARNING\|dita-convert: [^:]*: WARNING\): ' "$error_log" | while read line; do
    # Parse the warning message:
    message=$(echo "$line" | sed -e 's/^\(dita-convert: WARNING\|dita-convert: [^:]*: WARNING\): //')
    section_id=$(echo "$line" | sed -e 's/^dita-convert: .*\.dita (id="\([^"]\+\)").*/\1/')

    # Format the warning message:
    if [[ -z "$section_id" ]]; then
      log warn "$message" output "$output_directory" input "$input_file"
    else
      log warn "$message" id "$section_id" output "$output_directory" input "$input_file"
    fi
  done

  # Filter and report any errors:
  sed -ne 's/^\(dita-convert: ERROR\|dita-convert: [^:]*: ERROR\): //ip' "$error_log" | while read line; do
    log error "$line" output "$output_directory" input "$input_file"
  done

  # Remove the temporary file:
  rm "$error_log"

  # Check if the conversion succeeded:
  if [[ "$exit_code" -ne 0 ]]; then
    log fatal "Unable to split the generic DITA topic" output "$output_directory" input "$input_file"
    return 1
  fi

  # Report success:
  log info "Split the generic DITA topic" output "$output_directory" input "$input_file"
}

# Determine the file type of the supplied file and convert it to separate
# DITA concepts, tasks, and references.
#
# Usage: convert_file INPUT_FILE
function convert_file {
  local -r input_file="$1"

  # Determine the input file type:
  if [[ "$input_file" =~ .*\.a(doc|sciidoc|sc|d)$ ]]; then
    # Derive the output file name:
    local -r output_file=$(echo "$input_file" | sed -e 's/\.a\(doc\|sciidoc\|sc\|d\)$/.dita/')

    # Convert the file to a generic DITA topic:
    convert_to_topic "$input_file" "$output_file"

    # Split the generic DITA topic:
    [[ ! -z "$OPT_OUTPUT" ]] && split_topic "$output_file" "$OPT_OUTPUT"
  elif [[ "$input_file" =~ .*\.dita$ ]]; then
    # Verify that an output directory was supplied:
    [[ -z "$OPT_OUTPUT" ]] && exit_with_error 'No output directory' 22

    # Split the generic DITA topic:
    split_topic "$input_file" "$OPT_OUTPUT"
  else
    # Report an unsupported file type:
    exit_with_error "$input_file: Not an AsciiDoc or a DITA file" 22
  fi
}

# Export functions that must be available in subshells:
export -f log
export -f convert_file convert_to_topic split_topic

# Process command-line options:
while getopts ':ha:o:p:Cd' OPTION; do
  case "$OPTION" in
    a)
      # Append the attribute definition to the list of common options:
      OPT_ARGS+=('-a' "$OPTARG")
      ;;
    d)
      # Enable debugging mode:
      OPT_DEBUG=1
      ;;
    o)
      # Verify the supplied argument is either directory or does not exist yet:
      [[ -d "$OPTARG" ]] || [[ ! -e "$OPTARG" ]] || exit_with_error "$OPTARG: Not a directory" 22

      # Set the output directory:
      OPT_OUTPUT="$OPTARG"
      ;;
    p)
      # Verify that the supplied file exists:
      [[ -e "$OPTARG" ]] || exit_with_error "$OPTARG: No such file or directory" 2
      [[ -r "$OPTARG" ]] || exit_with_error "$OPTARG: Permission denied" 13
      [[ -f "$OPTARG" ]] || exit_with_error "$OPTARG: Not a file" 22

      # Append the prepended file to the list of common options:
      OPT_ARGS+=('-p' "$OPTARG")
      ;;
    C)
      # Disable colors in log messages:
      export CLR_BOLD=''
      export CLR_INFO=''
      export CLR_WARNING=''
      export CLR_ERROR=''
      export CLR_FATAL=''
      export CLR_KEYWORD=''
      export CLR_RESET=''
      ;;
    h)
      # Print usage information to standard output:
      print_usage

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

# Print usage information when no arguments are supplied:
if [[ "$#" -eq 0 ]]; then
  print_usage >&2
  exit 0
fi

# Verify the number of command line arguments:
[[ "$#" -eq 1 ]] || exit_with_error 'Invalid number of arguments' 22

# Get the name of the file to convert:
declare -r target="$1"

# Verify that the file exists:
[[ -e "$target" ]] || exit_with_error "$target: No such file or directory" 2
[[ -r "$target" ]] || exit_with_error "$target: Permission denied" 13
[[ -f "$target" ]] || exit_with_error "$target: Not a file or directory" 22

# Save additional arguments to a string variable to make it available in subshells:
export PACK_ARGS=$(declare -p OPT_ARGS)

# Convert the supplied file to DITA concepts, references, and tasks:
convert_file "$target"

# Terminate the script:
exit 0
