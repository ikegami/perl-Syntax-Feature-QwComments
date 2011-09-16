
# perl Build.PL && ./Build && perl -Mblib a.pl

use strict;
use warnings;
use feature qw( say );

use feature::qw_comments;

say for qw! 
  foo   # foo
  bar
!, 'baz';
say "";
say for qw! foo bar !, 'baz';
say "";
say for qw! foo bar ! x 3;
