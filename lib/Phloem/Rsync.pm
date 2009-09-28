=head1 NAME

Phloem::Rsync

=head1 DESCRIPTION

Rsync parameters and settings for Phloem.

=head1 SYNOPSIS

  use Phloem::Rsync;
  my $rsync = Phloem::Rsync->new('user'        => 'lemuelg',
                                 'ssh_id_file' => 'etc/.ssh/id_rsa',
                                 'ssh_port'    => 22)
    or die "Failed to create rsync object.";

=head1 METHODS

=over 8

=item new

Constructor.

=item user

Get/set the user.

=item ssh_id_file

Get/set the path to the SSH identity file.

=item ssh_port

Get/set the SSH port number.

=back

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

package Phloem::Rsync;

use strict;
use warnings;
use diagnostics;

use Carp;

use Xylem::Class ('class'  => 'Phloem::Rsync',
                  'fields' => {'user'        => '$',
                               'ssh_id_file' => '$',
                               'ssh_port'    => '$'});

1;
