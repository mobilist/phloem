#!/usr/bin/perl -w
#
#D Server test script.

use strict;
use warnings;
use diagnostics;

use lib qw(lib);

use Phloem::Debug;
use Phloem::Logger;
use Phloem::RegistryServer;
use Phloem::Root;

{
  Phloem::Debug->enabled(1);
  Phloem::Logger->initialise();
  Phloem::Logger->clear();
  Phloem::Logger->append('Starting up.');
  my $root = Phloem::Root->new('host' => '10.127.10.4', 'port' => 9999);
  Phloem::RegistryServer->run($root);
}
