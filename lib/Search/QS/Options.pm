package Search::QS::Options;

use v5.14;
use strict;
use warnings;

use Moose;
use Set::Array;
use Search::QS::Options::Sort;

has start => ( is => 'rw', isa => 'Int', default => 0);
has limit => ( is => 'rw', isa => 'Int|Undef');
has sort  => ( is => 'rw', isa => 'Set::Array', default => sub {
        return new Set::Array;
    }
);

sub parse() {
    my $s       = shift;
    my $struct  = shift;

    $s->reset();

    while (my ($k,$v) = each $struct) {
        given($k) {
			when ('start')   { $s->start($v) }
			when ('limit')   { $s->limit($v) }
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


sub to_qs() {
    my $s = shift;
    my $sort = join('&', map($_->to_qs, $s->sort->compact() ));

    my $ret = '';
    $ret.= 'start=' . $s->start . '&' unless ($s->start == 0);
    $ret.= 'limit=' . $s->limit . '&' if ($s->limit);
    $ret.= $sort . '&' if ($sort);

    $ret = substr($ret, 0,length($ret)-1);

    return $ret;
}

sub reset() {
    my $s = shift;
    $s->sort->clear;
    $s->limit(undef);
    $s->start(0);
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;
