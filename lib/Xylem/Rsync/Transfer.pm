=head1 NAME

Xylem::Rsync::Transfer

=head1 DESCRIPTION

A utility module for transferring data using rsync.

=head1 SYNOPSIS

  use Xylem::Rsync::Transfer;
  Xylem::Rsync::Transfer::go('remote_host' => '10.20.30.40',
                             'remote_user' => 'lemuelg',
                             'remote_path' => '/home/lemuelg/',
                             'local_path'  => '/',
                             'ssh_id_file' => '~/.ssh/id_rsa',
                             'ssh_port'    => 22);

=head1 METHODS

=over 8

=cut

package Xylem::Rsync::Transfer;

use strict;
use warnings;
use diagnostics;

use Carp;
use File::Rsync;
use File::Spec;
use IPC::Cmd;
use Time::HiRes;

use Xylem::Rsync::Stats;

#------------------------------------------------------------------------------

=item go

Transfer data from a remote host.

Returns transfer statistics on success; an error string otherwise.

In array context, a second return value is given: a high-resolution transfer
duration, in seconds.

=cut

sub go
{
  # Get the inputs.
  my %args = @_;
  my $remote_host = $args{'remote_host'} or croak "No remote host specified.";
  my $remote_user = $args{'remote_user'} or croak "No remote user specified.";
  my $remote_path = $args{'remote_path'} or croak "No remote path specified.";
  my $local_path = $args{'local_path'} or croak "No local path specified.";
  my $ssh_id_file = $args{'ssh_id_file'}
    or croak "No SSH identity file specified.";
  my $ssh_port = $args{'ssh_port'} or croak "No SSH port number specified.";

  # N.B. Make sure that there is a trailing forward slash on the source
  #      (remote) path.
  #
  #      This causes rsync to copy the *contents* of the directory, rather than
  #      the directory itself, to the destination. Subtle, but important.
  $remote_path =~ s/\/$//o; # Remove any existing trailing slash.
  $remote_path .= '/'; # Add trailing slash.

  my $full_remote_path =
    $remote_user . '@' . $remote_host . ':' . $remote_path;

  my $shell_opts =
    "ssh -i $ssh_id_file -q -p $ssh_port " .
    '-o "CheckHostIP=no" -o "StrictHostKeyChecking=no"';

  my %rsync_options = ('archive'           => 1,
                       'compress'          => 1,
                       'update'            => 1,
                       'verbose'           => 1,
                       'delete'            => 1,
                       'stats'             => 1,
                       'timeout'           => 10,
                       'copy-unsafe-links' => 1,
                       'hard-links'        => 1,
                       'exclude'           => ['*~'],
                       'partial'           => 1,
                       'partial-dir'       => '.rsync-tmp',
                       'rsh'               => $shell_opts,
                       'src'               => $full_remote_path,
                       'dest'              => $local_path);
  my $rsync = File::Rsync->new(\%rsync_options)
    or croak "Failed to create rsync wrapper object: $!";

  # Run the rsync command.
  return _run_rsync($rsync);
}

#------------------------------------------------------------------------------
sub _run_rsync
# Run the rsync transfer, using the specified File::Rsync object.
#
# Returns transfer statistics on success; an error string otherwise.
#
# In array context, a second return value is given: a high-resolution transfer
# duration, in seconds.
{
  my $rsync = shift or croak "No rsync object specified.";
  croak "Expected a File::Rsync object" unless $rsync->isa('File::Rsync');

  # Check that we can run rsync and ssh.
  IPC::Cmd::can_run('rsync')
    or croak "It appears that rsync is not installed.";
  IPC::Cmd::can_run('ssh') or croak "It appears that ssh is not installed.";

  my $start_time = Time::HiRes::time();

  # We want to catch the standard output from rsync, whilst also checking that
  # it runs without error.
  #
  # Return error details, if necessary.
  $rsync->exec()
    or return ('Data transfer failed: ' . join('', $rsync->err()), undef);

  # Work out how long the transfer took.
  my $transfer_duration = Time::HiRes::time() - $start_time;

  # Analyse the caught output to collect transfer statistics.
  my $rsync_stats = _get_rsync_stats($rsync->out());

  return ($rsync_stats, $transfer_duration);
}

#------------------------------------------------------------------------------
sub _get_rsync_stats
# Analyse the specified rsync output, returning transfer statistics.
{
  my $rsync_stats = Xylem::Rsync::Stats->new();

  foreach my $current_line (@_) {
    $current_line =~ /^Number of files: (\d+)$/o and
      $rsync_stats->num_files($1), next;
    $current_line =~ /^Number of files transferred: (\d+)$/o and
      $rsync_stats->num_files_transferred($1), next;
    $current_line =~ /^Total file size: (\d+) bytes$/o and
      $rsync_stats->total_file_size($1), next;
    $current_line =~ /^Total transferred file size: (\d+) bytes$/o and
      $rsync_stats->total_transferred_file_size($1), next;
    $current_line =~ /^Literal data: (\d+) bytes$/o and
      $rsync_stats->literal_data($1), next;
    $current_line =~ /^Matched data: (\d+) bytes$/o and
      $rsync_stats->matched_data($1), next;
    $current_line =~ /^File list size: (\d+)$/o and
      $rsync_stats->file_list_size($1), next;
    $current_line =~ /^File list generation time: (\d+\.\d+) seconds$/o and
      $rsync_stats->file_list_generation_time($1), next;
    $current_line =~ /^File list transfer time: (\d+\.\d+) seconds$/o and
      $rsync_stats->file_list_transfer_time($1), next;
    $current_line =~ /^Total bytes sent: (\d+)$/o and
      $rsync_stats->total_bytes_sent($1), next;
    $current_line =~ /^Total bytes received: (\d+)$/o and
      $rsync_stats->total_bytes_received($1), next;
    $current_line =~ /\b(\d+\.\d+) bytes\/sec$/o and
      $rsync_stats->transfer_rate($1), next;
  }

  return $rsync_stats;
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
