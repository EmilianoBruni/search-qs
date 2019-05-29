package Search::QS::Filters;

use v5.14;
use Moose;

use feature 'switch';

extends 'Set::Array';

# ABSTRACT: A collection of Search::QS::Filter

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

sub to_qs() {
    my $s = shift;
    return join('&', map($_->to_qs, $s->compact() ));
}

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
