#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'qw';

use Test::More tests => 6;

BEGIN { require feature::qw_comments; }

my @warnings;
BEGIN {
   $SIG{__WARN__} = sub {
      push @warnings, $_[0];
      print(STDERR $_[0]);
   };
}

my @a;

@a = qw(
   a # b
);
is(join('|', @a), "a|#|b", "Inactive on load");

{
   use feature::qw_comments;
   
   @a = qw(
      a # b
   );
   is(join('|', @a), "a", "Active on 'use'");
   
   {
      no feature::qw_comments;
   
      @a = qw(
         a # b
      );
      is(join('|', @a), "a|#|b", "Inactive on 'no'");
   }
   
   @a = qw(
      a # b
   );
   is(join('|', @a), "a", "'no' lexically scopped");
}

@a = qw(
   a # b
);
is(join('|', @a), "a|#|b", "'use' lexically scopped");

ok(!@warnings, "no warnings");

1;
