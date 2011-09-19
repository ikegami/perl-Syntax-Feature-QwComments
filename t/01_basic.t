#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 21;

use feature::qw_comments;

my @warnings;
BEGIN {
   $SIG{__WARN__} = sub {
      push @warnings, $_[0];
      print(STDERR $_[0]);
   };
}

my @a;

@a = qw( a b c );
is(join('|', @a), "a|b|c", "Trivial");

@a = qw( );     is(join('|', @a), "",    "Empty");
@a = qw( a );   is(join('|', @a), "a",   "One element");
@a = qw( a b ); is(join('|', @a), "a|b", "Two elements");

@a = qw(
   a  # Foo
   b  # Bar
   c
);
is(join('|', @a), "a|b|c", "Comment");

@a = qw! a b c !;
is(join('|', @a), "a|b|c", "Non-nesting");

@a = qw( a(s) b c );
is(join('|', @a), "a(s)|b|c", "Nesting ()");

@a = qw[ a[s] b c ];
is(join('|', @a), "a[s]|b|c", "Nesting []");

@a = qw{ a{s} b c };
is(join('|', @a), "a{s}|b|c", "Nesting {}");

@a = qw!
   a  # Foo!
   b
   c
!;
is(join('|', @a), "a|b|c", "Non-nesting delimiter in comments");

@a = qw(
   a  # )
   b  # (
   c
);
is(join('|', @a), "a|b|c", "Nesting delimiter in comments");

@a = qw( a ) x 3;
is(join('|', @a), "a|a|a", "qw() still counts as parens for 'x'");

@a = qw( a\b );   is(join('|', @a), "a\\b",  "qw( a\\b )");
@a = qw( a\\b );  is(join('|', @a), "a\\b",  "qw( a\\\\b )");
@a = qw( a\(b );  is(join('|', @a), "a(b",   "qw( a\\(b )");
@a = qw( a\)b );  is(join('|', @a), "a)b",   "qw( a\\)b )");
@a = qw! a\!b !;  is(join('|', @a), "a!b",   "qw! a\\!b !");
@a = qw( a\#b );  is(join('|', @a), "a#b",   "qw( a\\#b )");
@a = qw( a\ b );  is(join('|', @a), "a\\|b", "qw( a\\ b )");

@a = qw ( a b c );
is(join('|', @a), "a|b|c", "Space before start delimiter");

ok(!@warnings, "no warnings");

1;
