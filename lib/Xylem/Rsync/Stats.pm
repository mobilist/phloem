=head1 NAME

Xylem::Rsync::Stats

=head1 DESCRIPTION

Statistics for an rsync data transfer.

=head1 SYNOPSIS

  use Xylem::Rsync::Stats;
  my $transfer_stats =
    Xylem::Rsync::Stats->new('num_files'             => 3,
                             'num_files_transferred' => 2,
                             'total_bytes_sent'      => 48);
  $transfer_stats->transfer_rate(1.234);
  print $transfer_stats->total_bytes_received(), "\n";

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

=head1 COPYRIGHT

Copyright (C) 2009-2010 Simon Dawson.

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

use Carp;

use Xylem::Class ('fields' => [qw(num_files
                                  num_files_transferred
                                  total_file_size
                                  total_transferred_file_size
                                  literal_data
                                  matched_data
                                  file_list_size
                                  file_list_generation_time
                                  file_list_transfer_time
                                  total_bytes_sent
                                  total_bytes_received
                                  transfer_rate)]);

1;
