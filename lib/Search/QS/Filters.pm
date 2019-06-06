package Search::QS::Filters;

use v5.14;
use Moose;
use Search::QS::Filter;

use feature 'switch';

extends 'Set::Array';

# ABSTRACT: A collection of L<Search::QS::Filter>

=head1 SYNOPSIS

  use Search::QS::Filters;

  my $flts = new Search::QS::Filters;
  # parse query_string
  $flts->parse_qs($qs);
  # reconvert object to query_string
  print $flts->to_qs;


=head1 DESCRIPTION

This object incapsulate multiple filter elements as a collection of
L<Search::QS::Filter>
=cut

=method parse($perl_struct)

$perl_struct is an HASHREF which represents a query string like
the one returned by L<URI::Encode/"url_params_mixed">.
It parses the struct and extract filter informations
=cut
sub parse() {
    my $s       = shift;
    my $struct  = shift;


    while (my ($k,$v) = each $struct) {
        given($k) {
			when (/^flt\[(.*?)\]/)   { $s->_parse_filter($1, $v) }
		}
    }
}

sub _parse_filter {
    my $s   = shift;
    my $kt  = shift;
    my $val = shift;

    my ($key, $tag) = split(/:/,$kt);

    my $fltObj = new Search::QS::Filter(name => $key, tag => $tag);
    $fltObj->parse($val);
    $s->push($fltObj);
}

=method to_qs()

Return a query string of the internal rappresentation of the object
=cut
sub to_qs() {
    my $s = shift;
    return join('&', map($_->to_qs, $s->compact() ));
}

=method to_sql

Return this object as a SQL search
=cut
sub to_sql() {
    my $s = shift;
    my $groups = $s->as_groups;

    my $and = '';
    while (my ($k, $v) = each $groups->{and}) {
        $and .= ' ( ' . join (' AND ', map($_->to_sql, @$v)) . ' ) ';
        $and .= ' OR ';
    }
    # strip last OR
    $and = substr($and, 0, length($and)-4) if (length($and) >0);

    my $or = '';
    while (my ($k, $v) = each $groups->{or}) {
        $or .= ' ( ' . join (' OR ', map($_->to_sql, @$v)) . ' ) ';
        $or .= ' AND ';
    }
    # strip last AND
    $or = substr($or, 0, length($or)-5) if (length($or) >0);

    my $ret = join(' AND ', map($_->to_sql, @{$groups->{nogroup}}));

    $ret .= (length($ret) > 0 ? ' AND ' : '') . $and  if ($and);
    $ret .= (length($ret) > 0 ? ' AND ' : '') . $or if ($or);

    return $ret;
}
=method as_groups()

Return an HASHREF with 3 keys:

=over

=item and

An HASHREF with keys the andGroup keys and elements the filters with the
same andGroup key

=item or

An HASHREF with keys the orGroup keys and elements the filters with the
same orGroup key

=item nogroup

An ARRAYREF with all filters non in a and/or-Group.

=back
=cut
sub as_groups() {
    my $s = shift;
    my (%and, %or, @nogroup);
    $s->foreach(sub {
        given($_) {
            when (defined $_->andGroup) {push @{$and{$_->andGroup}}, $_}
            when (defined $_->orGroup) {push @{$or{$_->orGroup}}, $_}
            default {push @nogroup, $_}
        }
    });
    return { and => \%and, or => \%or, nogroup => \@nogroup};
}


no Moose;
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
