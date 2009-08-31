=head1 NAME

Xylem::Utils::XML

=head1 DESCRIPTION

Utilities for working with XML in Xylem.

=head1 SYNOPSIS

  C<use Xylem::Utils::XML;>

=head1 METHODS

=over 8

=cut

package Xylem::Utils::XML;

use strict;
use warnings;
use diagnostics;

use XML::Simple qw(:strict);

#------------------------------------------------------------------------------

=item parse

Parse the specified XML file.

Returns a hash reference of parsed XML data.

=cut

sub parse
{
  my $xml_file = shift or die "No file specified.";

  # Parse the XML file.
  my %xml_options = ('ForceArray'     => 1,
                     'KeyAttr'        => [],
                     'NormaliseSpace' => 2);
  return XMLin($xml_file, %xml_options);
}

1;

=back

=head1 COPYRIGHT

Copyright (C) 2009 Simon Dawson.

=head1 AUTHOR

Simon Dawson E<lt>spdawson@gmail.comE<gt>

=head1 LICENSE

This file is part of Xylem.

   Xylem is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Xylem is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Xylem.  If not, see <http://www.gnu.org/licenses/>.

=cut
