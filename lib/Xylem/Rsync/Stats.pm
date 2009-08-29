=head1 NAME

Xylem::Rsync::Stats

=head1 SYNOPSIS

  C<use Xylem::Rsync::Stats;>

=head1 METHODS

=over 8

=item new

Constructor.

=item num_files

Accessor method.

=item num_files_transferred

Accessor method.

=item total_file_size

Accessor method.

=item total_transferred_file_size

Accessor method.

=item literal_data

Accessor method.

=item matched_data

Accessor method.

=item file_list_size

Accessor method.

=item file_list_generation_time

Accessor method.

=item file_list_transfer_time

Accessor method.

=item total_bytes_sent

Accessor method.

=item total_bytes_received

Accessor method.

=item transfer_rate

Accessor method.

=back

=head1 DESCRIPTION

Statistics for an rsync data transfer.

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

package Xylem::Rsync::Stats;

use strict;
use warnings;
use diagnostics;

use Class::Struct
  'Xylem::Rsync::Stats' => {'num_files'                   => '$',
                            'num_files_transferred'       => '$',
                            'total_file_size'             => '$',
                            'total_transferred_file_size' => '$',
                            'literal_data'                => '$',
                            'matched_data'                => '$',
                            'file_list_size'              => '$',
                            'file_list_generation_time'   => '$',
                            'file_list_transfer_time'     => '$',
                            'total_bytes_sent'            => '$',
                            'total_bytes_received'        => '$',
                            'transfer_rate'               => '$'};

1;
