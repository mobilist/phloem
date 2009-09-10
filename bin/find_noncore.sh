#!/bin/sh -
#
#D Find non-core Perl module dependencies.

./bin/find_dependencies.pl --filter --noncore 2>/dev/null
