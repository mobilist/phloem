#!/usr/bin/perl -w

=head1 NAME

new_module.pl

=head1 DESCRIPTION

Create a new Xylem or Phloem module.

=head1 SYNOPSIS

new_module.pl [options] E<lt>module_nameE<gt>

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

=item B<-f, --force>

Force the overwriting of existing files.

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
use File::Basename qw(fileparse);
use File::Path qw(make_path);
use Getopt::Long;
use Pod::Usage;
use POSIX qw(strftime);

#==============================================================================
# Start of main program.
{
  my ($opt_h, $opt_m, $opt_l, $opt_f);
  pod2usage(-verbose => 0) unless GetOptions('h|help'    => \$opt_h,
                                             'm|man'     => \$opt_m,
                                             'l|license' => \$opt_l,
                                             'f|force'   => \$opt_f);
  pod2usage(-verbose => 1) if $opt_h;
  pod2usage(-verbose => 2) if $opt_m;
  pod2usage(-verbose  => 99,
            -sections => 'NAME|COPYRIGHT|LICENSE',
            -exitval  => 0) if $opt_l;

  print STDERR <<'xxx_END_GPL_HEADER';
    new_module.pl Copyright (C) 2009 Simon Dawson
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type new_module.pl --license for details.
xxx_END_GPL_HEADER

  # Get the module name, and fix it up. Also get a 'package name' for use in
  # copyright notices.
  my $module_name = shift or pod2usage(-verbose => 0);
  my $package_name = 'Phloem';
  $module_name =~ s/\.pm$//o;
  $module_name =~ s/^Phloem:://o;
  if ($module_name =~ /^Xylem::/o) {
    $package_name = 'Xylem';
  } else {
    $module_name = 'Phloem::' . $module_name;
  }

  print "Creating module $module_name...\n";

  # Get the module file path.
  my $module_file = $module_name;
  $module_file =~ s/::/\//og;
  $module_file = 'lib/' . $module_file . '.pm';

  die "$module_file already exists." if (-e $module_file && !$opt_f);

  # Get the destination directory for the module file.
  my (undef, $module_dest_dir, undef) = fileparse($module_file);

  # Get the path of the corresponding module test file.
  my $module_test_file = $module_file;
  $module_test_file =~ s/\.pm$/\.t/o;
  $module_test_file =~ s/^lib/t/o;

  die "$module_test_file already exists." if (-e $module_test_file && !$opt_f);

  # Get the destination directory for the module test file.
  my (undef, $module_test_dest_dir, undef) = fileparse($module_test_file);

  # Create destination directories.
  print "Creating directories...\n";
  make_path($module_dest_dir, $module_test_dest_dir)
    // die "Failed to create directory/directories: $!";

  my $year = strftime("%Y", localtime);

  # Write the module file.
  write_module_file($module_name, $package_name, $module_file, $year);

  # Write the module test file.
  write_module_test_file($module_name, $package_name, $module_test_file,
                         $year);

  print "Done.\n";
}
# End of main program; subroutines follow.

#------------------------------------------------------------------------------
sub write_module_file
# Write the module file.
{
  my $module_name = shift or die "No module name specified.";
  my $package_name = shift or die "No package name specified.";
  my $module_file = shift or die "No module file path specified.";
  my $year = shift or die "No year specified.";

  print "Writing module file $module_file...\n";
  my $module_fh = FileHandle->new("> $module_file")
    or die "Failed to open file for writing: $!";
  flock($module_fh, LOCK_EX)
    or die "Failed to acquire exclusive file lock: $!";

  print $module_fh <<"xxx_END_MODULE";
\=head1 NAME

$module_name

\=head1 DESCRIPTION

A module.

\=head1 SYNOPSIS

  C<use $module_name;>

\=head1 METHODS

\=over 8

\=cut

package $module_name;

use strict;
use warnings;
use diagnostics;

use lib qw(lib);

#------------------------------------------------------------------------------

\=item some_method

Some method or another.

\=cut

sub some_method
{
  die "NOT YET WRITTEN!";
}

1;

\=back

\=head1 COPYRIGHT

Copyright (C) $year Simon Dawson.

\=head1 AUTHOR

Simon Dawson E<lt>spdawson\@gmail.comE<gt>

\=head1 LICENSE

This file is part of $package_name.

   $package_name is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   $package_name is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with $package_name.  If not, see <http://www.gnu.org/licenses/>.

\=cut
xxx_END_MODULE

  flock($module_fh, LOCK_UN) or die "Failed to unlock file: $!";
  $module_fh->close() or die "Failed to close file: $!";
}

#------------------------------------------------------------------------------
sub write_module_test_file
# Write the module test file.
{
  my $module_name = shift or die "No module name specified.";
  my $package_name = shift or die "No package name specified.";
  my $module_test_file = shift or die "No module test file path specified.";
  my $year = shift or die "No year specified.";

  print "Writing module test file $module_test_file...\n";
  my $module_test_fh = FileHandle->new("> $module_test_file")
    or die "Failed to open file for writing: $!";
  flock($module_test_fh, LOCK_EX)
    or die "Failed to acquire exclusive file lock: $!";

  print $module_test_fh <<"xxx_END_TEST";
#!/usr/bin/perl -w
#
#D Unit test script.

# Copyright (C) $year Simon Dawson
#
# This file is part of $package_name.
#
#    $package_name is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    $package_name is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with $package_name.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use diagnostics;

use Test::More tests => 1; # qw(no_plan);

BEGIN { use_ok('$module_name'); }

diag("NOT YET WRITTEN!");
xxx_END_TEST

  flock($module_test_fh, LOCK_UN) or die "Failed to unlock file: $!";
  $module_test_fh->close() or die "Failed to close file: $!";
}
