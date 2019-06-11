package Search::QS::Options::Start;

use Moose;
# ABSTRACT: The Start option object

=head1 DESCRIPTION

A subclass of L<Seach::QS::Options::Int> incapsulate start value
=cut

extends 'Search::QS::Options::Int';

has '+name'    => ( default => 'start' );
has '+value'   => ( isa => 'Int');
has '+default' => ( default  => 0);

=head1 SEE ALSO

L<Seach::QS::Options::Int>
=cut

no Moose;
__PACKAGE__->meta->make_immutable;

1;
