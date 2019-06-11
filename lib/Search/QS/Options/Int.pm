package Search::QS::Options::Int;

use Moose;

# ABSTRACT: An integer object with a few methods

=head1 DESCRIPTION

An abstract class to incapsulate Undef|Int value

=cut

has name    => ( is => 'ro', isa => 'Str');
has value   => ( is => 'rw', isa => 'Int|Undef', builder => '_build_value');
has default => ( is => 'ro', isa => 'Int|Undef', default => undef);

=method name()

Defined in subclass, is the name of the integer value

=method value()

The value of the integer

=method default()

Defined in subclass, the default value of the integer

=method to_qs($append_ampersand)

Return a query string of the internal rappresentation of the object. If L<value()>
is different by L<default()> and $append_ampersand is true, it appends
an ampersand (&) at the end of the returned string

=cut

sub to_qs() {
    my $s = shift;
    my $amp = shift || 0;
    return '' if ($s->value ~~ $s->default);
    return $s->name . '=' . $s->value . ($amp ? '&' : '');
}

=method reset()

Reset the object to the L<default()> value.
=cut
sub reset() {
    my $s = shift;
    $s->value($s->default);
}

sub _build_value() {
    return shift->default;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
