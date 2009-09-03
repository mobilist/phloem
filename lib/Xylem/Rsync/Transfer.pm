=head1 NAME

Xylem::Rsync::Transfer

=head1 DESCRIPTION

A utility module for transfering data using rsync.

=head1 SYNOPSIS

  C<use Xylem::Rsync::Transfer;>

=head1 METHODS

=over 8

=cut

package Xylem::Rsync::Transfer;

use strict;
use warnings;
use diagnostics;

use IPC::Cmd;
use FileHandle;
use Time::HiRes;

use lib qw(lib);
use Xylem::Rsync::Stats;

#------------------------------------------------------------------------------

=item go

Transfer data from a remote host.

Returns true on success, and false otherwise.

=cut

sub go
{
  # Get the inputs.
  my $remote_ip_address = shift or die "No remote IP address specified.";
  my $remote_user = shift or die "No remote user specified.";
  my $remote_path = shift or die "No remote path specified.";
  my $local_path = shift or die "No local path specified.";

  print "Starting data transfer.\n";
  my $full_remote_path =
    $remote_user . '@' . $remote_ip_address . ':' . $remote_path;
  $local_path =~ s/\/$//; # N.B. No trailing forward slash on local path.

  my $shell_opts =
    '--rsh=\'' .
    'ssh -i etc/.ssh/id_rsa -q ' .
    '-o "CheckHostIP=no" -o "StrictHostKeyChecking=no"\'';
  my $rsync_command =
    'rsync --archive --compress --update --verbose --delete --stats ' .
    '--timeout=10 --copy-unsafe-links --hard-links ' .
    '--exclude \'*~\' --partial --partial-dir=.rsync-tmp ' .
    "$shell_opts " .
    "$full_remote_path " .
    "$local_path";

  # Run the rsync command.
  return _run_rsync_command($rsync_command);
}

#------------------------------------------------------------------------------
sub _run_rsync_command
# Run the specified rsync command.
{
  my $rsync_command = shift or die "No rsync command specified.";

  # Check that we can run rsync and ssh.
  IPC::Cmd::can_run('rsync') or die "It appears that rsync is not installed.";
  IPC::Cmd::can_run('ssh')   or die "It appears that ssh is not installed.";

  my $start_time = Time::HiRes::time();

  # We want to catch the standard output from rsync, whilst also checking that
  # it runs without error.
  my @caught_output;
  eval {
    # N.B. Re-instate the default child process signal handler,
    #      because any non-default global handler will mess things up for us.
    local $SIG{'CHLD'} = 'DEFAULT';
    my $rsync_process_fh = FileHandle->new("$rsync_command 2>/dev/null |")
      or die "Failed to open pipe: $!";
    while (my $current_line = $rsync_process_fh->getline()) {
      chomp($current_line);
      push(@caught_output, $current_line);
    }
    $rsync_process_fh->close() or die "Failed to close pipe: $!";
  };
  if ($@) {
    print "Data transfer failed: $@\n";
    return;
  }

  # Work out how long the transfer took.
  my $transfer_duration = Time::HiRes::time() - $start_time;

  # Analyse the caught output to collect transfer statistics.
  my $rsync_stats = _get_rsync_stats(@caught_output);

  print "Finished data transfer in ${transfer_duration}s.\n";

  print
    "Transferred " . $rsync_stats->num_files_transferred() .
    " of " . $rsync_stats->num_files() .
    " files. Sent " .
    $rsync_stats->total_bytes_sent() .
    " bytes, received " .
    $rsync_stats->total_bytes_received() .
    " bytes. Transfer rate: " . $rsync_stats->transfer_rate() .
    " bytes/sec.\n";

  return 1;
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
