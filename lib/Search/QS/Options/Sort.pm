package Search::QS::Options::Sort;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

enum 'direction_types', [qw( asc desc )];

has name => ( is => 'rw', isa => 'Str');
has direction => ( is => 'rw', isa => 'direction_types', default => 'asc');

sub to_qs() {
    my $s   = shift;

    return 'sort[' . $s->name . ']=' . $s->direction;
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
