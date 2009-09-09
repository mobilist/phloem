#!/bin/sh -
#
#D Find non-core Perl module dependencies.

./bin/find_dependencies.pl --filter 2>/dev/null | grep '*' | sed -e 's/\*$//'
