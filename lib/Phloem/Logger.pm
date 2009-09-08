=head1 NAME

Phloem::Logger

=head1 DESCRIPTION

Logging utilities for Phloem.

=head1 SYNOPSIS

  C<use Phloem::Logger;>
  C<Phloem::Logger->initialise();>
  C<Phloem::Logger->clear();>
  C<Phloem::Logger->append('Hello teh world!');>

=cut

package Phloem::Logger;

use strict;
use warnings;
use diagnostics;

use File::Spec;

use lib qw(lib);
use Phloem::Constants;

use base qw(Xylem::Logger);

#------------------------------------------------------------------------------
sub _do_initialise
# Initialise the logging subsystem --- "protected" method.
#
# Subclasses must provide an implementation for this pure virtual method.
#
# N.B. This is a class method.
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  # Set the log file path.
  #
  # N.B. We make sure to use an absolute file path here, in case the process
  #      doing the logging is ever daemonised.
  my $log_file_path = File::Spec->rel2abs($Phloem::Constants::LOG_FILE);
  Xylem::Logger::path($log_file_path);
}

1;

=head1 SEE ALSO

L<Xylem::Logger>

=head1 COPYRIGHT

Copyright (C) 2009 Simon Dawson.

=head1 AUTHOR

Simon Dawson E<lt>spdawson@gmail.comE<gt>

=head1 LICENSE

This file is part of Phloem.

   Phloem is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Phloem is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Phloem.  If not, see <http://www.gnu.org/licenses/>.

=cut
