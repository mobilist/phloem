#!/usr/bin/perl -w

=head1 NAME

find_dependencies.pl

=head1 DESCRIPTION

Find module dependencies.

=head1 SYNOPSIS

find_dependencies.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

=item B<-f, --filter>

Filter out Xylem/Phloem module dependencies from the output.

=item B<-n, --noncore>

Filter out core Perl module dependencies from the output.

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

use English;
use Fcntl qw(:flock); # Import LOCK_* constants.
use FileHandle;
use File::Find;
use Getopt::Long;
use Module::CoreList;
use Pod::Usage;

#==============================================================================
# Start of main program.
{
  my ($opt_h, $opt_m, $opt_l, $opt_f, $opt_n);
  pod2usage(-verbose => 0) unless GetOptions('h|help'    => \$opt_h,
                                             'm|man'     => \$opt_m,
                                             'l|license' => \$opt_l,
                                             'f|filter'  => \$opt_f,
                                             'n|noncore' => \$opt_n);
  pod2usage(-verbose => 1) if $opt_h;
  pod2usage(-verbose => 2) if $opt_m;
  pod2usage(-verbose  => 99,
            -sections => 'NAME|COPYRIGHT|LICENSE',
            -exitval  => 0) if $opt_l;

  print STDERR <<'xxx_END_GPL_HEADER';
    find_dependencies.pl Copyright (C) 2009 Simon Dawson
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type find_dependencies.pl --license for details.
xxx_END_GPL_HEADER

  my %deps;

  my $wanted_sub = sub {
    return unless (-f $File::Find::name);

    return if ($File::Find::name =~ /\W\.svn\W/o); # Skip subversion stuff.

    return if ($File::Find::name =~ /~$/o); # Skip backup files.

    return if ($File::Find::name =~ /\.log$/o); # Skip log files.

    return unless (-T $File::Find::name); # Skip non-text files.

    my $fh = FileHandle->new("< $File::Find::name")
      or die "Failed to open file for reading: $!";
    flock($fh, LOCK_SH) or die "Failed to acquire shared file lock: $!";

    while (my $current_line = <$fh>) {
      $deps{$1} = 1 if ($current_line =~ /^\s*(?:use|require) ([\w:]+)/o);
    }

    flock($fh, LOCK_UN) or die "Failed to unlock file: $!";
    $fh->close() or die "Failed to close file: $!";
  };
  find({'wanted' => $wanted_sub, 'no_chdir' => 1}, '.');

  # Get a hash table of the core modules in the current Perl version.
  my $core_modules = $Module::CoreList::version{$PERL_VERSION->numify()}
    or die "Failed to get list of core Perl modules.";
  die "Expected a hash reference." unless (ref($core_modules) eq 'HASH');

  my $noncore_marker = '*';
  my $any_noncore;
  foreach my $key (sort(keys(%deps))) {
    if ($opt_f) {
      # Filter out Xylem/Phloem module dependencies from the output.
      next if ($key =~ /^(?:Xylem|Phloem)/o);
    }

    # Is this a core module?
    my $in_core = exists($core_modules->{$key});
    $any_noncore ||= !$in_core;

    if ($opt_n) {
      # Filter out core Perl module dependencies from the output.
      print "$key\n" unless $in_core;
    } else {
      # Append a marker to non-core module dependencies.
      print $key, ($in_core ? '' : $noncore_marker), "\n";
    }
  }

  print STDERR
    "N.B. Modules marked '$noncore_marker' are not in the version " .
    "$PERL_VERSION Perl core.\n"
    if ($any_noncore && !$opt_n);
}
# End of main program.
