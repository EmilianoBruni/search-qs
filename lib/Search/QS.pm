package Search::QS;

use strict;
use warnings;

use Moose;

use Search::QS::Filters;
use Search::QS::Options;

# ABSTRACT: A converter between query string URI and search query

=head1 SYNOPSIS

  use Search::QS;

  my $qs = new Search::QS;
  # parse query_string
  $qs->parse($qs);
  # reconvert object to query_string
  print $qs->to_qs;


=head1 DESCRIPTION

This module converts a query string like This

  http://www.example.com?flt[Name]=Foo

into perl objects which rappresent a search.

In L<filters()> there are all flt (filter) elements.

In L<options()> there are query options like limit, start and sorting.

=cut

=method filters()
Return an instance of L<Search::QS::Filters>
=cut
has filters => ( is => 'ro', isa => 'Search::QS::Filters',
    default => sub {
        return new Search::QS::Filters;
    }
);


=method options()
Return an instance of L<Search::QS::Options>
=cut
has options => ( is => 'ro', isa => 'Search::QS::Options',
    default => sub {
        return new Search::QS::Options;
    }
);

=method parse($query_string)
Parse the $query_string and fills related objects in L<filters()> and L<options()>
=cut
sub parse {
    my $s = shift;
    my $v = shift;

    $s->filters->parse($v);
    $s->options->parse($v);
}

=method to_qs()
Return a query string which represents current state of L<filters()> and L<options()>
elements
=cut
sub to_qs {
    my $s = shift;

    my $qs_filters = $s->filters->to_qs;
    my $qs_options = $s->options->to_qs;

    my $ret = '';
    $ret .= $qs_filters . '&' unless ($qs_filters eq '');
    $ret .= $qs_options . '&' unless ($qs_options eq '');
    # strip last &
    chop($ret);

    return $ret;

}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
