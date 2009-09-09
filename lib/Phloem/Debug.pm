=head1 NAME

Phloem::Debug

=head1 DESCRIPTION

Debugging utilities for Phloem.

=head1 SYNOPSIS

  use Phloem::Debug;
  Phloem::Debug->enabled(1);
  Phloem::Debug->message('Hello teh world!');

=head1 METHODS

=over 8

=cut

package Phloem::Debug;

use strict;
use warnings;
use diagnostics;

use Phloem::Logger;

use base qw(Xylem::Debug);

#------------------------------------------------------------------------------

=item message

Print the specified debugging message.

Returns the debugging message, in a standardised "debug output" format.

Returns false if debugging is disabled.

N.B. This is a class method.

=cut

sub message
{
  my $class = shift or die "No class name specified.";
  die "Expected an ordinary scalar." if ref($class);
  die "Incorrect class name." unless $class->isa(__PACKAGE__);

  # Call the base class version first.
  #
  # N.B. Just return if we don't get a message back: debugging is disabled.
  my $message = $class->SUPER::message(shift) or return;

  # Do our own special thing with the debugging message.
  Phloem::Logger->append($message);

  return $message;
}

1;

=back

=head1 SEE ALSO

L<Xylem::Debug>

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
