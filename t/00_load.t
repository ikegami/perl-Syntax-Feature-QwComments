#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN { require_ok( 'feature::qw_comments' ); }

diag( "Testing feature::qw_comments $feature::qw_comments::VERSION" );
diag( "Using Perl $]" );

1;
