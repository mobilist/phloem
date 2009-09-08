#!/bin/sh -
#
#D Check code.

# Look for tab characters: they are forbidden outside of makefiles.
find . -type f ! -iname Makefile \
  \( -exec perl -ne 'exit 1 if /\t/' {} \; \
  -o -exec echo {} contains tabs. \; \)

# Look for lines with trailing whitespace.
find . -type f \
  \( -exec perl -ne 'exit 1 if (/\S[ \t]+$/ || /^[ \t]+$/)' {} \; -o \
  -exec echo {} contains lines with trailing whitespace. \; \)
