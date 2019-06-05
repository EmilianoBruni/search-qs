package Search::QS::Options::Sort;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

# ABSTRACT: A sort element

=head1 DESCRIPTION

This object incapsulate a single sort item.

=cut

enum 'direction_types', [qw( asc desc )];

has name => ( is => 'rw', isa => 'Str');
has direction => ( is => 'rw', isa => 'direction_types', default => 'asc');

=method name()

The field to sort

=method direction()

The type of sort (asc|desc)

=method to_qs()

Return a query string of the internal rappresentation of the object
=cut
sub to_qs() {
    my $s   = shift;

    return 'sort[' . $s->name . ']=' . $s->direction;
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
