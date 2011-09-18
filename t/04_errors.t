#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 7;

use feature::qw_comments;

my @warnings;
BEGIN {
   $SIG{__WARN__} = sub {
      push @warnings, $_[0];
   };
}

my @a;
my @ewarnings;
my @ea;

{
   no feature::qw_comments;
   eval '@a = qw( a, b ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   @ewarnings = @warnings;
   @ea = @a;
   @warnings = ();
} {   
   use feature::qw_comments;
   eval '@a = qw( a, b ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   is_deeply(\@warnings, \@ewarnings, "One comma warnings");
   is_deeply(\@a, \@ea, "One comma result");
   @warnings = ();
}

{
   no feature::qw_comments;
   eval '@a = qw( a, b, ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   @ewarnings = @warnings;
   @ea = @a;
   @warnings = ();
} {   
   use feature::qw_comments;
   eval '@a = qw( a, b, ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   is_deeply(\@warnings, \@ewarnings, "Two commas warnings");
   is_deeply(\@a, \@ea, "Two commas result");
   @warnings = ();
}

{
   no feature::qw_comments;
   eval 'qw( ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   @ewarnings = @warnings;
   @warnings = ();
} {   
   use feature::qw_comments;
   eval 'qw( ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   is_deeply(\@warnings, \@ewarnings, "Zero elements in void context");
   @warnings = ();
}

{
   no feature::qw_comments;
   eval 'qw( a ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   @ewarnings = @warnings;
   @warnings = ();
} {   
   use feature::qw_comments;
   eval 'qw( a ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   is_deeply(\@warnings, \@ewarnings, "One element in void context");
   @warnings = ();
}

{
   no feature::qw_comments;
   eval 'qw( a b ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   @ewarnings = @warnings;
   @warnings = ();
} {   
   use feature::qw_comments;
   eval 'qw( a b ); 1' or die $@;
   s/ at (?:(?!\bat\b).)+ line \S+\.\n\z//s for @warnings;
   is_deeply(\@warnings, \@ewarnings, "Two elements in void context");
   @warnings = ();
}

1;
