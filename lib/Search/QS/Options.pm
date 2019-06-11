package Search::QS::Options;

use v5.14;
use strict;
use warnings;

use Moose;
use Set::Array;
use Search::QS::Options::Sort;
use Search::QS::Options::Limit;
use Search::QS::Options::Start;

# ABSTRACT: Options query search like limits, start and sort

=head1 SYNOPSIS

  use Search::QS::Options;

  my $opt = new Search::QS::Options;
  # parse query_string
  $opt->parse_qs($qs);
  # reconvert object to query_string
  print $opt->to_qs;


=head1 DESCRIPTION

This object incapsulate the options of a query.

=cut

has start => ( is => 'ro', isa => __PACKAGE__ . '::Start', builder => '_build_start');
has limit => ( is => 'ro', isa => __PACKAGE__ . '::Limit', builder => '_build_limit');
has sort  => ( is => 'ro', isa => 'Set::Array', builder => '_build_sort'
);

=method start()

A L<Search::QS::Options::Start> to set/get the first record to show

=method limit()

A L<Search::QS::Options::Limit> to set/get the max number of elements to show

=method sort()

An array (L<Set::Array>) of L<Search::QS::Options::Sort> with sort informations

=cut

=method parse($perl_struct)

$perl_struct is an HASHREF which represents a query string like
the one returned by L<URI::Encode/"url_params_mixed">.
It parses the struct and extract filter informations
=cut
sub parse() {
    my $s       = shift;
    my $struct  = shift;

    $s->reset();

    while (my ($k,$v) = each %$struct) {
        given($k) {
			when ('start')   { $s->start->value($v) }
			when ('limit')   { $s->limit->value($v) }
			when (/^sort\[(.*?)\]/)   { $s->_parse_sort($1, $v) }
		}
    }
}

sub _parse_sort() {
    my $s   = shift;
    my $key = shift;
    my $val = shift;

    $val = 'asc' if ($val eq 1);
    $val = 'desc' if ($val eq -1);

    return unless ($val =~ /^(asc|desc)$/);

    $s->sort->push(new Search::QS::Options::Sort(
        name        => $key,
        direction   => $val
    ));
}


=method to_qs()

Return a query string of the internal rappresentation of the object
=cut
sub to_qs() {
    my $s = shift;
    my $sort = join('&', map($_->to_qs, $s->sort->compact() ));

    my $ret = '';
    $ret.= $s->start->to_qs(1);
    $ret.= $s->limit->to_qs(1);
    $ret.= $sort . '&' if ($sort);

    chop($ret);

    return $ret;
}

=method reset()

Initialize the object with default values
=cut
sub reset() {
    my $s = shift;
    $s->sort->clear;
    $s->limit->reset;
    $s->start->reset;
}

sub _build_sort {
    return new Set::Array;
}

sub _build_start {
    return new Search::QS::Options::Start;
}

sub _build_limit {
    return new Search::QS::Options::Limit;
}

=head1 SEE ALSO

L<Seach::QS::Options::Sort>, L<Seach::QS::Options::Start>,
L<Seach::QS::Options::Limit>
=cut

no Moose;
__PACKAGE__->meta->make_immutable;

1;
