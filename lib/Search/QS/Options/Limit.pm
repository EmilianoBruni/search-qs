package Search::QS::Options::Limit;

use Moose;
# ABSTRACT: The Limit option object

=head1 DESCRIPTION

A subclass of L<Seach::QS::Options::Int> incapsulate limit value
=cut

extends 'Search::QS::Options::Int';

has '+name'    => ( default => 'limit' );

=head1 SEE ALSO

L<Seach::QS::Options::Int>
=cut

no Moose;
__PACKAGE__->meta->make_immutable;

1;
