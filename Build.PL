#!/usr/bin/env perl

use strict;
use warnings;

use Module::Build qw( );

my $build = Module::Build->new(
   module_name => 'feature::qw_comments',
   dist_author => 'Eric Brine <ikegami@adaelis.com>',
   license     => 'CC0_1_0',
   configure_requires => {
      'Module::Build'              => 0.36_14,
      'Software::License::CC0_1_0' => 0,
   },
   build_requires => {
      # For testing only
      # ----------------
      'Encode'               => 0,
      'IO::Handle'           => 0,
      #'Pod::Coverage'       => 0.18,      # Optional.
      'Test::More'           => 0,
      #'Test::Pod'           => 1.22,      # Optional.

      # For developer tests only
      # ------------------------
      #'Test::Pod::Coverage' => 1.08,      # Optional.
   },
   requires => {
      'version' => 0,
      '~~~'     => 0,
   },
   add_to_cleanup => [ 'feature-qw_comments-*' ],
   resources => {
      homepage => 'http://search.cpan.org/dist/feature-qw_comments/',
      #license => [ ],  # Populated by Software::License::*
      bugtracker => {
         web     => 'http://rt.cpan.org/Public/Dist/Display.html?Name=feature-qw_comments',
         #mailto => 'bug-feature-qw_comments@rt.cpan.org',
      },
      repository => {
         type => 'git',
         url  => 'git://github.com/ikegami/perl-feature-qw_comments.git',
         web  => 'http://github.com/ikegami/perl-feature-qw_comments',
      }
   },
);

$build->create_build_script();
