#!/usr/bin/perl -w

=head1 NAME

new_script.pl

=head1 DESCRIPTION

Create a new Phloem script.

=head1 SYNOPSIS

new_script.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>

Print usage information, and then exit.

=item B<-m, --man>

Print this manual page, and then exit.

=item B<-l, --license>

Print the license terms, and then exit.

=item B<-f, --force>

Force the overwriting of an existing file.

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
use File::Spec;
use Getopt::Long;
use Pod::Usage;
use POSIX qw(strftime);

#==============================================================================
# Start of main program.
{
  my ($opt_h, $opt_m, $opt_l, $opt_d, $opt_f);
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
    new_script.pl Copyright (C) 2009 Simon Dawson
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type new_script.pl --license for details.
xxx_END_GPL_HEADER

  # Get the script name, and fix it up.
  my $script_name = shift or pod2usage(-verbose => 0);
  $script_name =~ s/\.pl$//io;
  $script_name .= '.pl';

  print "Creating script $script_name...\n";

  # Use a hard-coded package name for now. We can't infer this from anything.
  my $package_name = 'Phloem';

  # Get the script file path.
  my $script_dest_dir = 'bin';
  my $script_file = File::Spec->catfile($script_dest_dir, $script_name);

  die "$script_file already exists." if (-e $script_file && !$opt_f);

  # Create destination directory.
  print "Creating directory...\n";
  make_path($script_dest_dir) // die "Failed to create directory: $!";

  my $year = strftime("%Y", localtime);

  # Write the script file.
  _write_script_file($script_name, $package_name, $script_file, $year);

  # Make the script executable.
  print "Making $script_file executable...\n";
  chmod(0755, $script_file)
    or die "Failed to make $script_file executable: $!";

  print "Done.\n";
}
# End of main program; subroutines follow.

#------------------------------------------------------------------------------
sub _write_script_file
# Write the script file.
{
  my $script_name = shift or die "No script name specified.";
  my $package_name = shift or die "No package name specified.";
  my $script_file = shift or die "No script file path specified.";
  my $year = shift or die "No year specified.";

  print "Writing script file $script_file...\n";
  my $script_fh = FileHandle->new("> $script_file")
    or die "Failed to open file for writing: $!";
  flock($script_fh, LOCK_EX)
    or die "Failed to acquire exclusive file lock: $!";

  print $script_fh <<"xxx_END_SCRIPT";
#!/usr/bin/perl -w

\=head1 NAME

$script_name

\=head1 DESCRIPTION

NOT YET WRITTEN!

\=head1 SYNOPSIS

$script_name [options]

\=head1 OPTIONS

\=over 8

\=item B<-h, --help>

Print usage information, and then exit.

\=item B<-m, --man>

Print this manual page, and then exit.

\=item B<-l, --license>

Print the license terms, and then exit.

\=back

\=head1 COPYRIGHT

Copyright (C) 2009 Simon Dawson.

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

use strict;
use warnings;
use diagnostics;

use Getopt::Long;
use Pod::Usage;

# Uncomment the following line if you plan to use $package_name modules.
#use lib qw(lib);

#==============================================================================
# Start of main program.
{
  my (\$opt_h, \$opt_m, \$opt_l, \$opt_d);
  pod2usage(-verbose => 0) unless GetOptions('h|help'    => \\\$opt_h,
                                             'm|man'     => \\\$opt_m,
                                             'l|license' => \\\$opt_l);
  pod2usage(-verbose => 1) if \$opt_h;
  pod2usage(-verbose => 2) if \$opt_m;
  pod2usage(-verbose  => 99,
            -sections => 'NAME|COPYRIGHT|LICENSE',
            -exitval  => 0) if \$opt_l;

  print STDERR <<'xxx_END_GPL_HEADER';
    $script_name Copyright (C) 2009 Simon Dawson
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type $script_name --license for details.
xxx_END_GPL_HEADER

  die "NOT YET WRITTEN!";
}
# End of main program; subroutines follow.

#------------------------------------------------------------------------------
sub some_subroutine
# Some subroutine or another.
{
  die "NOT YET WRITTEN!";
}
xxx_END_SCRIPT

  flock($script_fh, LOCK_UN) or die "Failed to unlock file: $!";
  $script_fh->close() or die "Failed to close file: $!";
}
