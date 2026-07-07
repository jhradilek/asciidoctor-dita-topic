#!/bin/bash

# dita-help - look up DITA 1.3 elements in the documentation online
# Copyright (C) 2024, 2026 Jaromir Hradilek

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

# Use the script on the command line:
#
#   dita-help DITA_ELEMENT_NAME
#
# Configure Vim to look up keywords under the cursor with 'K':
#
#   au FileType dita* set keywordprg=ditahelp

# Set the URL to the DITA 1.3 element reference page:
declare -r docs='https://docs.oasis-open.org/dita/dita/v1.3/errata02/os/complete/part3-all-inclusive/langRef/quick-reference/all-elements-a-to-z.html'

# Determine the link to the supplied element definition:
declare -r link=$(curl -sv "$docs" 2>/dev/null | xmllint --html --xpath "string(//a[normalize-space()=\"$1\"]/@href)" - 2>/dev/null)

# Terminate the script if no element definition is found:
if [[ -z "$link" ]]; then
  echo "${0##*/}: No documentation for element '$1'" >&2
  exit
fi

# Open the element definition in a web browser:
elinks -dump "${docs%/*}/$link" | less -r
