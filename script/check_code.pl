#!/usr/bin/perl -w

=head1 NAME

check_code.pl

=head1 DESCRIPTION

Check the code for some common problems.

=head1 SYNOPSIS

check_code.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

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

use strict;
use warnings;
use diagnostics;

use Fcntl qw(:flock); # Import LOCK_* constants.
use FileHandle;
use File::Find;
use Getopt::Long;
use Pod::Checker;
use Pod::Usage;

use constant MAX_LINE_LENGTH => 80;

#==============================================================================
# Start of main program.
{
  my ($opt_h, $opt_m, $opt_l);
  pod2usage(-verbose => 0) unless GetOptions('h|help'    => \$opt_h,
                                             'm|man'     => \$opt_m,
                                             'l|license' => \$opt_l);
  pod2usage(-verbose => 1) if $opt_h;
  pod2usage(-verbose => 2) if $opt_m;
  pod2usage(-verbose  => 99,
            -sections => 'NAME|COPYRIGHT|LICENSE',
            -exitval  => 0) if $opt_l;

  print STDERR <<'xxx_END_GPL_HEADER';
    check_code.pl Copyright (C) 2009 Simon Dawson
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type check_code.pl --license for details.
xxx_END_GPL_HEADER

  # Initialise a standard error code.
  my $err_code = 0;

  my $wanted_sub = sub {
    return unless (-f $File::Find::name);

    return if ($File::Find::name =~ /\.svn\W/o); # Skip subversion stuff.

    return if ($File::Find::name =~ /~$/o); # Skip backup files.

    return if ($File::Find::name =~ /\.log$/o); # Skip log files.

    return unless (-T $File::Find::name); # Skip non-text files.

    # Check the file, and return immediately if it is okay.
    return if _check_file($File::Find::name);

    # Update the overall error code, if we haven't seen an error yet.
    $err_code ||= 1;
  };
  find({'wanted' => $wanted_sub, 'no_chdir' => 1}, '.');

  exit($err_code);
}
# End of main program; subroutines follow.

#------------------------------------------------------------------------------
sub _check_file
# Check the specified file.
#
# Returns true if the file is okay; false otherwise.
{
  my $file = shift or die "No file specified.";

  # Initialise the return value: the file is innocent until proven guilty.
  my $file_ok = 1;

  # Check pod, if this is a Perl file.
  if ($file =~ /\.p(m|l)$/io) {

    my $pod_checker = Pod::Checker->new('-warnings' => 2);
    $pod_checker->parse_from_file($file, \*STDERR);
    my $num_errors = $pod_checker->num_errors();
    my $num_warnings = $pod_checker->num_warnings();
    if ($num_errors == -1) {
      # Treat this as an error: Perl files should contain some documentation.
      print STDERR "${file}::no pod present.\n";
      $file_ok = 0;
    } elsif ($num_errors) {
      print STDERR "${file}::$num_errors pod syntax errors raised.\n";
      $file_ok = 0;
    }
    if ($num_warnings > 0) {
      print STDERR "${file}::$num_warnings pod syntax warnings raised.\n";
      $file_ok = 0;
    }
  }

  # Is this a makefile?
  my $is_makefile = ($file =~ /(?:M|m)akefile$/o);

  my $fh = FileHandle->new("< $file")
    or die "Failed to open file $file for reading: $!";
  flock($fh, LOCK_SH) or die "Failed to acquire shared file lock: $!";

  while (my $current_line = <$fh>) {

    # Get the current input line number from the filehandle.
    my $line_no = $fh->input_line_number();

    # Check code.
    {
      # Check for tab characters.
      if ($current_line =~ /\t/o) {
        if ($is_makefile) {
          # In a makefile, tab characters should only appear at the start of
          # nontrivial lines.
          unless ($current_line =~ /^\t\S/o) {
            print STDERR
              "$file:$line_no:tab not at start of nontrivial line.\n";
            $file_ok = 0;
          }
        } else {
          # Tab characters are expressly forbidden outside of makefiles.
          print STDERR "$file:$line_no:tab character(s) present.\n";
          $file_ok = 0;
        }
      }

      # Look for non-blank lines with trailing whitespace.
      if ($current_line =~ /\S[ \t]+$/o) {
        print STDERR
          "$file:$line_no:trailing whitespace character(s) present.\n";
        $file_ok = 0;
      }

      # Look for non-trivial whitespace-only lines.
      if ($current_line =~ /^[ \t]+$/o) {
        print STDERR
          "$file:$line_no:only whitespace character(s) are present.\n";
        $file_ok = 0;
      }

      # Look for lines that are longer than a fixed limit.
      if (length($current_line) > MAX_LINE_LENGTH) {
        print STDERR
          "$file:$line_no:line is longer than ",
          MAX_LINE_LENGTH,
          " characters.\n";
        $file_ok = 0;
      }
    }

  }

  flock($fh, LOCK_UN) or die "Failed to unlock file: $!";
  $fh->close() or die "Failed to close file: $!";

  return $file_ok;
}
