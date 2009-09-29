#!/usr/bin/perl -w

=head1 NAME

check_spelling.pl

=head1 DESCRIPTION

Check the code documentation for spelling errors.

=head1 SYNOPSIS

check_spelling.pl [options]

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

use File::Spec;

use lib qw(lib);
use Xylem::Utils::Code;
use Xylem::Utils::File;

#==============================================================================
# Start of main program.
{
  Xylem::Utils::Code::process_command_line();

  my %exceptions = ('Accessor'   => 1,
                    'accessor'   => 1,
                    'API'        => 1,
                    'CDN'        => 1,
                    'CPAN'       => 1,
                    'cpan'       => 1,
                    'FileHandle' => 1,
                    'filehandle' => 1,
                    'Google'     => 1,
                    'GPL'        => 1,
                    'IP'         => 1,
                    'login'      => 1,
                    'logins'     => 1,
                    'metadata'   => 1,
                    'Perl'       => 1,
                    'PID'        => 1,
                    'practice'   => 1,
                    'RSA'        => 1,
                    'Rsync'      => 1,
                    'rsync'      => 1,
                    'STDOUT'     => 1,
                    'TCP'        => 1,
                    'TODO'       => 1);

  # Initialise a standard error code.
  my $err_code = 0;

  my $user_sub = sub {
    my $file = shift;

    # Check the file, and return immediately if it is okay.
    return if _check_spelling_file($file, \%exceptions);

    # Update the overall error code, if we haven't seen an error yet.
    $err_code ||= 1;
  };
  Xylem::Utils::File::find($user_sub);

  exit($err_code);
}
# End of main program; subroutines follow.

#------------------------------------------------------------------------------
sub _check_spelling_file
# Check the spelling in the specified file.
#
# Returns true if the file is okay; false otherwise.
{
  my $file = shift or die "No file specified.";
  my $exceptions = shift or die "No exceptions hash reference specified.";
  die "Expected a hash reference." unless (ref($exceptions) eq 'HASH');

  # We only care about Perl files.
  return 1 unless ($file =~ /\.(?:pm|pl|PL|t)$/o);

  # If there's no POD, then we're okay.
  my $devnull = File::Spec->devnull();
  `pod2text $file 2>$devnull` or return 1;

  # Do the spell checking on the POD.
  #
  # N.B. Yes, this is a bit crap --- running pod2text twice. An alternative
  #      would be to pump the POD into IPC::Open2, but it hardly seems worth
  #      the trouble.
  #
  # N.B. We also use a sneaky Perl filter to remove the SYNOPSIS section from
  #      the POD: the synopses are highly likely to contain code strings that
  #      would generate false positives in the spell check.
  my $command_str =
    "cat $file | " .
    "perl -n -e '\$syn ||= (\$_ =~ /^=head1 SYNOPSIS/); " .
    "\$syn &&= (\$_ !~ /^=/ || \$_ =~ /^=head1 SYNOPSIS/); " .
    "print \$_ unless \$syn;' | " .
    "pod2text | aspell --lang=en_GB.UTF-8 list | sort | uniq 2>$devnull";
  my @caught_output = `$command_str`;

  return 1 unless @caught_output;

  # Add the module base name to the list of exceptions.
  $exceptions->{$1} = 1 if ($file =~ /(\w+)\.pm$/o);

  my $any;
  foreach my $word (@caught_output) {
    $word =~ s/^\s*//o;
    $word =~ s/\s*$//o;
    next if exists($exceptions->{$word});

    # Print a header the first time we see a misspelled word in the file.
    print STDERR "Misspelled words in file $file:\n" unless $any;

    $any = 1;
    print STDERR "  $word\n";
  }

  return not $any;
}
