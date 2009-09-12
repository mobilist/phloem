=head1 NAME

Xylem::Utils::Code

=head1 DESCRIPTION

Utilities for generating and working with Perl code.

=head1 SYNOPSIS

  use Xylem::Utils::Code;

  my ($opt_f, $opt_s);
  Xylem::Utils::Code::process_command_line('f|file=s'   => \$opt_f,
                                           's|simulate' => \$opt_s);

  die "Problems found when checking code."
    unless Xylem::Utils::Code::check_code_file('some/script.pl');

  my %deps = Xylem::Utils::Code::get_dependencies('some/script.pl');
  die "Should not depend on the Egg::Farmer."
    if exists($deps{'Egg::Farmer'});

  Xylem::Utils::Code::write_script_file('script_name'  => 'script.pl',
                                        'package_name' => 'Xylem',
                                        'script_file'  => 'some/script.pl',
                                        'author'       => 'Lemuel Gulliver',
                                        'author_email' => 'lemuelg@gmail.com');

  Xylem::Utils::Code::write_module_file('module_name'  => 'Xylem::Horse',
                                        'package_name' => 'Xylem',
                                        'module_file'  => 'lib/Xylem/Horse.pm'
                                        'author'       => 'Lemuel Gulliver',
                                        'author_email' => 'lemuelg@gmail.com');

  Xylem::Utils::Code::write_module_test_file(
    'module_name'      => 'Xylem::Horse',
    'package_name'     => 'Xylem',
    'module_test_file' => 't/Xylem/Horse.t'
    'author'           => 'Lemuel Gulliver',
    'author_email'     => 'lemuelg@gmail.com');

=head1 METHODS

=over 8

=cut

package Xylem::Utils::Code;

use strict;
use warnings;
use diagnostics;

use Carp;
use English;
use File::Basename qw(fileparse);
use File::Path qw(make_path);
use Getopt::Long;
use Pod::Checker;
use Pod::Usage;
use POSIX qw(strftime);

use Xylem::FileLocker;

use constant MAX_LINE_LENGTH => 80;

#------------------------------------------------------------------------------

=item process_command_line

Process the command line.

This should be called in the same way as GetOptions from the Getopt::Long
module. The only caveat is that the standard 'h|help', 'm|man' and
'l|license' options are "already taken" and should not be used by the calling
code.

(Having said that, the calling code should still provide pod to document
these standard options.)

As well as handling the above-mentioned standard options, this method will
also print a GPL copyright/license header to standard error.

=cut

sub process_command_line
{
  my %options_hash = @_;

  my ($script_name, undef, undef) = fileparse($PROGRAM_NAME);

  my ($opt_h, $opt_m, $opt_l);
  pod2usage(-verbose => 0) unless GetOptions('h|help'    => \$opt_h,
                                             'm|man'     => \$opt_m,
                                             'l|license' => \$opt_l,
                                             %options_hash);
  pod2usage(-verbose => 1) if $opt_h;
  pod2usage(-verbose => 2) if $opt_m;
  pod2usage(-verbose  => 99,
            -sections => 'NAME|COPYRIGHT|LICENSE',
            -exitval  => 0) if $opt_l;

  print STDERR <<"xxx_END_GPL_HEADER";
    $script_name Copyright (C) 2009 Simon Dawson
    This program comes with ABSOLUTELY NO WARRANTY.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type $script_name --license for details.
xxx_END_GPL_HEADER
}

#------------------------------------------------------------------------------

=item check_code_file

Check the code in the specified file for common problems.

Returns true if the file is okay; false otherwise.

=cut

sub check_code_file
{
  my $file = shift or croak "No file specified.";

  # Any further arguments are assumed to comprise a hash table of options.
  my %options = @_;

  # Are we treating warnings as errors?
  my $warnings_as_errors =
    exists($options{'WARNINGS_AS_ERRORS'}) && $options{'WARNINGS_AS_ERRORS'};

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
      $file_ok = 0 if $warnings_as_errors;
    }
  }

  # Is this a makefile?
  my $is_makefile = ($file =~ /(?:M|m)akefile$/o);

  # Acquire a shared lock on the file, while we examine it.
  my $locker = Xylem::FileLocker->new($file, 'r')
    or croak "Failed to lock file.";
  my $fh = $locker->filehandle() or croak "Failed to get filehandle.";

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

  return $file_ok;
}

#------------------------------------------------------------------------------

=item get_dependencies

Get the Perl module dependencies for the specified file.

The dependency information is returned in the form of a hash table, where the
keys are the module names.

=cut

sub get_dependencies
{
  my $file = shift or croak "No file specified.";

  my %deps;

  # Acquire a shared lock on the file, while we examine it.
  my $locker = Xylem::FileLocker->new($file, 'r')
    or croak "Failed to lock file.";
  my $fh = $locker->filehandle() or croak "Failed to get filehandle.";

  while (my $current_line = <$fh>) {
    $deps{$1} = 1 if ($current_line =~ /^\s*(?:use|require)\s+([\w:]+)/o);
  }

  return %deps;
}

#------------------------------------------------------------------------------

=item write_script_file

Write a new skeleton script file, using the specified parameters.

=cut

sub write_script_file
{
  my %args = @_;
  my $script_name = $args{'script_name'} or croak "No script name specified.";
  my $package_name = $args{'package_name'}
    or croak "No package name specified.";
  my $script_file = $args{'script_file'}
    or croak "No script file path specified.";
  my $author = $args{'author'} or croak "No author specified.";
  my $author_email = $args{'author_email'}
    or croak "No author e-mail address specified.";
  my $force_flag = $args{'force'}; # Optional argument.

  croak "$script_file already exists." if (-e $script_file && !$force_flag);

  print "Creating script $script_name...\n";

  # Get the destination directory.
  my (undef, $script_dest_dir, undef) = fileparse($script_file);

  # Create the destination directory.
  print "Creating directory $script_dest_dir...\n";
  make_path($script_dest_dir) // croak "Failed to create directory: $!";

  # More metadata.
  my $year = strftime("%Y", localtime);

  print "Writing script file $script_file...\n";

  # Acquire an exclusive lock on the file, while we write it.
  my $locker = Xylem::FileLocker->new($script_file, 'w')
    or croak "Failed to lock file.";
  my $script_fh = $locker->filehandle() or croak "Failed to get filehandle.";

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

Copyright (C) 2009 $author.

\=head1 AUTHOR

$author E<lt>${author_email}E<gt>

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

use lib qw(lib);
use Xylem::Utils::Code;

#==============================================================================
# Start of main program.
{
  my (\$opt_s);
  Xylem::Utils::Code::process_command_line('s|something' => \\\$opt_s);

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

  # Make the script executable.
  print "Making $script_file executable...\n";
  chmod(0755, $script_file)
    or croak "Failed to make $script_file executable: $!";

  print "Done.\n";
}

#------------------------------------------------------------------------------

=item write_module_file

Write a new skeleton module file, using the specified parameters.

=cut

sub write_module_file
{
  my %args = @_;
  my $module_name = $args{'module_name'} or croak "No module name specified.";
  my $package_name = $args{'package_name'}
    or croak "No package name specified.";
  my $module_file = $args{'module_file'}
    or croak "No module file path specified.";
  my $author = $args{'author'} or croak "No author specified.";
  my $author_email = $args{'author_email'}
    or croak "No author e-mail address specified.";
  my $force_flag = $args{'force'}; # Optional argument.

  croak "$module_file already exists." if (-e $module_file && !$force_flag);

  # Get the destination directory.
  my (undef, $module_dest_dir, undef) = fileparse($module_file);

  # Create the destination directory.
  print "Creating directory $module_dest_dir...\n";
  make_path($module_dest_dir) // croak "Failed to create directory: $!";

  # More metadata.
  my $year = strftime("%Y", localtime);

  print "Writing module file $module_file...\n";

  # Acquire an exclusive lock on the file, while we write it.
  my $locker = Xylem::FileLocker->new($module_file, 'w')
    or croak "Failed to lock file.";
  my $module_fh = $locker->filehandle() or croak "Failed to get filehandle.";

  print $module_fh <<"xxx_END_MODULE";
\=head1 NAME

$module_name

\=head1 DESCRIPTION

A module.

\=head1 SYNOPSIS

  use $module_name;

\=head1 METHODS

\=over 8

\=cut

package $module_name;

use strict;
use warnings;
use diagnostics;

use Carp;

# Uncomment the following line if you plan to use $package_name modules.
#use lib qw(lib);

#------------------------------------------------------------------------------

\=item some_method

Some method or another.

\=cut

sub some_method
{
  croak "NOT YET WRITTEN!";
}

1;

\=back

\=head1 COPYRIGHT

Copyright (C) $year $author.

\=head1 AUTHOR

$author E<lt>${author_email}E<gt>

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
}

#------------------------------------------------------------------------------

=item write_module_test_file

Write a new skeleton module test file, using the specified parameters.

=cut

sub write_module_test_file
{
  my %args = @_;
  my $module_name = $args{'module_name'} or croak "No module name specified.";
  my $package_name = $args{'package_name'}
    or croak "No package name specified.";
  my $module_test_file = $args{'module_test_file'}
    or croak "No module test file path specified.";
  my $author = $args{'author'} or croak "No author specified.";
  my $author_email = $args{'author_email'}
    or croak "No author e-mail address specified.";
  my $force_flag = $args{'force'}; # Optional argument.

  croak "$module_test_file already exists."
    if (-e $module_test_file && !$force_flag);

  # Get the destination directory.
  my (undef, $module_test_dest_dir, undef) = fileparse($module_test_file);

  # Create the destination directory.
  print "Creating directory $module_test_dest_dir...\n";
  make_path($module_test_dest_dir) // croak "Failed to create directory: $!";

  # More metadata.
  my $year = strftime("%Y", localtime);

  print "Writing module test file $module_test_file...\n";

  # Acquire an exclusive lock on the file, while we write it.
  my $locker = Xylem::FileLocker->new($module_test_file, 'w')
    or croak "Failed to lock file.";
  my $module_test_fh = $locker->filehandle()
    or croak "Failed to get filehandle.";

  print $module_test_fh <<"xxx_END_TEST";
#!/usr/bin/perl -w
#
# Unit test script for $module_name.

# Copyright (C) $year $author
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
