use strict;
use warnings;

use Test::More tests => 7;

use_ok('Parse::ACNS');

foreach my $v (qw(compat 0.6 0.7)) {
    my $p = Parse::ACNS->new( version => $v );
    ok($p, 'created a new parser instance');
    isa_ok($p, 'Parse::ACNS');
}

