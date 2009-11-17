=head1 NAME

Phloem::Constants

=head1 DESCRIPTION

Constants for Phloem.

=head1 SYNOPSIS

  use Phloem::Constants;

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

package Phloem::Constants;

use base qw(Exporter);

our $LOG_FILE                              = 'phloem.log';
our $CONFIG_FILE                           = 'etc/node.xml';

our $REGISTRY_SERVER_TIMEOUT_S             = 30;

our $DEFAULT_SUBSCRIBER_UPDATE_FREQUENCY_S = 10;
our $DEFAULT_NODE_REGISTER_FREQUENCY_S     = 10;

our $DEFAULT_SSH_PORT                      = 22;

use constant ROOT2LEAF => 'root2leaf';
use constant LEAF2ROOT => 'leaf2root';

our @EXPORT_OK = qw(ROOT2LEAF LEAF2ROOT);
our %EXPORT_TAGS = ('routes' => [qw(ROOT2LEAF LEAF2ROOT)]);

1;
