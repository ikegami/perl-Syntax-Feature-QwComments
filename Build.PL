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
      #'Pod::Coverage'       => 0.18,      # Optional.
      'Test::More'           => 0,
      #'Test::Pod'           => 1.22,      # Optional.

      # For developer tests only
      # ------------------------
      #'Test::Pod::Coverage' => 1.08,      # Optional.
   },
   requires => {
      'perl'     => 5.014000,
      'XSLoader' => 0,
      'version'  => 0,
   },
   add_to_cleanup => [ 'feature-qw_comments-*', 'vc100.pdb' ],
   meta_merge => {
      resources => {
         homepage   => 'http://search.cpan.org/dist/feature-qw_comments/',
         bugtracker => 'http://rt.cpan.org/Public/Dist/Display.html?Name=feature-qw_comments',
         repository => "http://github.com/ikegami/perl-feature-qw_comments",  # type => "git"
      },
   },
);

$build->create_build_script();
