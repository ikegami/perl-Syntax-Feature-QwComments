
package feature::qw_comments;

use strict;
use warnings;

use version; our $VERSION = qv('v1.3.0');

use XSLoader qw( );

XSLoader::load('feature::qw_comments', $VERSION);

1;


__END__

=head1 NAME

feature::qw_comments - Pragma to allow comments in qw()


=head1 VERSION

Version 1.3.0


=head1 SYNOPSIS

    use feature::qw_comments;
    
    @a = qw(
       foo  # Now with comments!
       bar
    );


=head1 DESCRIPTION

Allows comments inside of C<qw()>.


=head2 C<< use feature::qw_comments; >>

Allow comments inside of C<qw()> until the end of the current lexical scope.


=head2 C<< no feature::qw_comments; >>

The standard C<qw()> syntax is restored until the end of the current lexical scope.


=head1 WARNING: Uses Experimental Features

This module relies on the experimental keyword plugin and lexer interface features which "may change or be removed without notice".


=head1 WARNING: Re-implements parts of Perl

This feature is implemented by completely replacing the parser/compiler's handling of C<qw()> when the pragma is in effect.
There may be discrepencies in how certain edge cases are handled, and new discrepencies may surface as Perl changes over time.
Please contact me or file a bug report if you encounter any discrepencies.


=head1 BUGS

Please report any bugs or feature requests to C<bug-feature-qw_comments at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=feature-qw_comments>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc feature::qw_comments

You can also look for information at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/feature-qw_comments>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=feature-qw_comments>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/feature-qw_comments>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/feature-qw_comments>

=back


=head1 AUTHOR

Eric Brine, C<< <ikegami@adaelis.com> >>


=head1 COPYRIGHT & LICENSE

No rights reserved.

The author has dedicated the work to the Commons by waiving all of his
or her rights to the work worldwide under copyright law and all related or
neighboring legal rights he or she had in the work, to the extent allowable by
law.

Works under CC0 do not require attribution. When citing the work, you should
not imply endorsement by the author.


=cut
