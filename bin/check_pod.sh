#!/bin/sh -
#
#D Check pod.

find . \( -iname '*.pm' -o -iname '*.pl' \) -exec podchecker {} \;
