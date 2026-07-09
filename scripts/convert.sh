#!/bin/bash

# convert - convert an AsciiDoc file to a DITA topic or a DITA map
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
declare -a OPT_OPTS=()
declare -i OPT_RECURSIVE=0
declare -i OPT_WATCH=0
declare -i OPT_BUSY=0
declare -i OPT_INTERVAL=2

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
  echo "Usage: $NAME [-w|-W] [-a ATTRIBUTE] [-p FILE] FILE|DIRECTORY"
  echo "       $NAME -h"
  echo
  echo "  Convert an AsciiDoc FILE or all AsciiDoc files in the supplied DIRECTORY"
  echo "  to a DITA concept, task, reference, or map."
  echo
  echo "  -w             watch the file or directory and reconvert it whenever it"
  echo "                 changes; use this method on systems that support the"
  echo "                 inotify API for monitoring filesystem events"
  echo "  -W             watch the file or directory and reconvert it whenever it"
  echo "                 changes; this option uses busy waiting and is a fallback"
  echo "                 mechanism for systems that do not support the inotify API"
  echo "  -r             search for relevant files recursively if a DIRECTORY"
  echo "                 is specified"
  echo
  echo "  -a ATTRIBUTE   set a document attribute in the form of name, name!,"
  echo "                 or name=value pair; can be supplied multiple times"
  echo "  -p FILE        prepend a file to the input file, typically to bring"
  echo "                 in attribute definitions; can be supplied multiple"
  echo "                 times"
  echo
  echo "  -h      display this help and exit"
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
  local -r output_file=$(echo "$file_name" | sed -e 's/\.a\(doc\|sciidoc\|sc\|d\)$/.ditamap/')

  # Create a temporary to capture error log:
  local -r error_log=$(mktemp --tmpdir "$NAME".XXXXXXXXXX)

  # Convert the file to a DITA map:
  if [[ "$content_type" == 'assembly' ]]; then
    dita-map "${OPT_OPTS[@]}" -i "$file_name" -o "$output_file" 2> "$error_log"
  else
    dita-map "${OPT_OPTS[@]}" -z "$file_name" -o "$output_file" 2> "$error_log"
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
  local -r output_file=$(echo "$file_name" | sed -e 's/\.a\(doc\|sciidoc\|sc\|d\)$/.dita/')

  # Derive the actual target content type:
  local -r target_type="${content_type/#assembly/concept}"

  # Create a temporary to capture error log:
  local -r error_log=$(mktemp --tmpdir "$NAME".XXXXXXXXXX)

  # Convert the file to a DITA topic:
  if [[ "$content_type" == 'assembly' ]]; then
    (dita-topic "${OPT_OPTS[@]}" -Ao - "$file_name" | dita-convert -gt "$target_type" -o "$output_file") 2> "$error_log"
  else
    (dita-topic "${OPT_OPTS[@]}" -o - "$file_name" | dita-convert -gt "$target_type" -o "$output_file") 2> "$error_log"
  fi

  # Capture the exit status:
  local exit_code="$?"

  # Filter and report any warnings:
  sed -ne 's/^\(dita-convert: WARNING\|dita-convert: [^:]*: WARNING\|[^:]*: WARNING: dita-topic\): //ip' "$error_log" | while read line; do
    log warn "$line" output "$output_file" input "$file_name"
  done

  # Filter and report any errors:
  sed -ne 's/^\(dita-convert: ERROR\|dita-convert: [^:]*: ERROR\|[^:]*: ERROR: dita-topic\): //ip' "$error_log" | while read line; do
    log error "$line" output "$output_file" input "$file_name"
  done

  # Remove the temporary file:
  rm "$error_log"

  # Check if the conversion succeeded:
  if [[ "$exit_code" -ne 0 ]]; then
    log fatal "Unable to create a DITA $target_type" output "$output_file" input "$file_name"
    return 1
  fi

  # Report success:
  log info "Created a DITA $target_type" output "$output_file" input "$file_name"
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
    log fatal "Unsuppported content type" type "$content_type" input "$file_name"
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

# Discover AsciiDoc files in the supplied directory and convert them to the
# corresponding DITA topic or a map.
#
# Usage: convert_directory DIRECTORY_NAME
function convert_directory {
  local -r directory_name="$1"

  # Determine whether to traverse directories recursively:
  if [[ "$OPT_RECURSIVE" -eq 1 ]]; then
    # Convert all AsciiDoc files in the directory:
    find "$target" -type f -regex '.*\.a\(doc\|sciidoc\|sc\|d\)' | xargs -I %% bash -c 'convert_file %%'
  else
    # Convert all AsciiDoc files in the directory:
    find "$target" -maxdepth 1 -type f -regex '.*\.a\(doc\|sciidoc\|sc\|d\)' | xargs -I %% bash -c 'convert_file %%'
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

  # Determine whether to use busy waiting:
  if [[ "$OPT_BUSY" -eq 0 ]]; then
    # Monitor the file for changes:
    echo "$file_name" | entr -r bash -c "convert_file \"$file_name\""
  else
    # Get the time of the last modification from the file:
    local latest_change=$(stat -c %Z "$file_name")

    # Convert the file prior to watching it:
    convert_file "$file_name"

    # Start the busy waiting loop:
    while true; do
      # Get the information about the last change:
      changed_time=$(stat -c %Z "$file_name")

      # Check if the file changed:
      if [[ "$(echo "$changed_time > $latest_change" | bc)" -eq 1 ]]; then
        # Update the time of the last modification:
        latest_change="$changed_time"

        # Convert the changed file:
        convert_file "$file_name"
      fi

      # Wait the selected amount of time:
      sleep "$OPT_INTERVAL"
    done
  fi
}

# Watch AsciiDoc files in the supplied directory and re-convert them whenever
# their contents changes.
#
# Usage: watch_directory DIRECTORY_NAME
function watch_directory {
  local -r directory_name="$1"
  local opts=''

  # Print the banner:
  banner "Monitoring the supplied directory for changes." "To exit this mode, press ^C (Ctrl+C)."

  # Determine whether to use busy waiting:
  if [[ "$OPT_BUSY" -eq 0 ]]; then
    # Determine whether to traverse directories recursively:
    if [[ "$OPT_RECURSIVE" -eq 1 ]]; then
      opts='-r'
    fi

    # Watch the directory for updates and continuously convert it:
    inotifywait "$opts" -qme close_write --include '.*\.a(doc|sciidoc|sc|d)$' "$directory_name" | while read -r dir event file; do
      convert_file "$dir$file"
    done
  else
    # Determine whether to traverse directories recursively:
    if [[ "$OPT_RECURSIVE" -eq 0 ]]; then
      opts='-maxdepth 1'
    fi

    # Create a temporary to capture the time stamp; this is to prevent clock drift:
    local -r reference_file=$(mktemp --tmpdir ".$NAME".XXXXXXXXXX)

    # Get the time of the last modification from the file:
    local latest_change=$(stat -c %Z "$reference_file")

    # Remove the temporary file:
    rm "$reference_file"

    # Start the busy waiting loop:
    while true; do
      # Process the list of changed files:
      while read -r line; do
        # Extract the information about the file:
        changed_time=$(echo "$line" | cut -d : -f 1)
        changed_file=$(echo "$line" | cut -d : -f 2-)

        # Update the time of the last modification:
        if [[ "$(echo "$changed_time > $latest_change" | bc)" -eq 1 ]]; then
          latest_change="$changed_time"
        fi

        # Convert the changed file:
        convert_file "$changed_file"
      done < <(find . $opts -type f -regex '.*\.a\(doc\|sciidoc\|sc\|d\)' -newermt "@$latest_change" -printf "%T@:%p\n")

      # Wait the selected amount of time:
      sleep "$OPT_INTERVAL"
    done
  fi
}

# Export functions that must be available in subshells:
export -f log banner
export -f convert_file convert_to_map convert_to_topic

# Process command-line options:
while getopts ':ha:p:rwW' OPTION; do
  case "$OPTION" in
    a)
      # Append the attribute definition to the list of common options:
      OPT_OPTS+=('-a' "$OPTARG")
      ;;
    p)
      # Append the prepended file to the list of common options:
      OPT_OPTS+=('-p' "$OPTARG")
      ;;
    r)
      # Enable recursive traversal of the supplied directory:
      OPT_RECURSIVE=1
      ;;
    w)
      # Enable continuous processing of the supplied file or directory:
      OPT_WATCH=1
      ;;
    W)
      # Enable continuous processing of the supplied file or directory:
      OPT_WATCH=1

      # Select busy waiting as the monitoring method:
      OPT_BUSY=1
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
[[ -f "$target" || -d "$target" ]] || exit_with_error "$target: Not a file or directory" 22

# Check if the target is a file or a directory:
if [[ -f "$target" ]]; then
  # Verify that the file has the a valid AsciiDoc file extension:
  [[ "$target" =~ .*\.a(doc|sciidoc|sc|d)$ ]] || exit_with_error "$target: Not an AsciiDoc file" 22

  # Determine which mode to run in:
  if [[ "$OPT_WATCH" -eq 0 ]]; then
    # Convert the file one time:
    convert_file "$target" || exit 1
  else
    # Watch the file for updates and continuously convert it:
    watch_file "$target"
  fi
else
  # Determine which mode to run in:
  if [[ "$OPT_WATCH" -eq 0 ]]; then
    # Convert all AsciiDoc files in the directory one time:
    convert_directory "$target"
  else
    # Watch the directory for updates and continuously convert it:
    watch_directory "$target"
  fi
fi

# Terminate the script:
exit 0
