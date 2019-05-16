package Search::QS::Filter;

use v5.14;
use Moose;

# ABSTRACT: Incapsulation of a single filter element

has 'name'      => (is => 'rw');
has 'operator'  => (is => 'rw', default => '=');
has 'value'     => (is => 'rw', isa => 'ArrayRef', default => sub { return [] } );
has 'tag'       => (is => 'rw');
has 'andGroup'  => (is => 'rw');
has 'orGroup'   => (is => 'rw');

sub parse() {
    my $s   = shift;
    my $val = shift;

    if (ref($val) ne 'ARRAY') {
        push @{$s->value}, $val;
        return $s;
    }

    foreach (@$val) {
        #print $_ . "\n";
        given($_) {
            when(/^\$op/)   { $s->operator($s->_extract_double_dots($_)) }
            when(/^\$and/)  { $s->andGroup($s->_extract_double_dots($_)) }
            when(/^\$or/)   { $s->orGroup($s->_extract_double_dots($_)) }
            default         { push @{$s->value}, $_ }
        }
    }
    return $s;
}

sub to_qs() {
    my $s = shift;


    my $ret = '';

    foreach (@{$s->value}) {
        $ret .= $s->to_qs_name . '=' . $_ . '&';
    }
    # remove last &
    $ret = substr($ret, 0, length($ret)-1) if (length($ret) > 0);
    $ret.= '&' . $s->to_qs_name . '=$op:' . $s->operator if ($s->operator ne '=');
    $ret.= '&' . $s->to_qs_name . '=$and:' . $s->andGroup if ($s->andGroup);
    $ret.= '&' . $s->to_qs_name . '=$or:' . $s->orGroup if ($s->orGroup);

    return $ret;
}

sub to_sql {
    my $s = shift;

    my $ret = '(';

    foreach (@{$s->value}) {
        $ret .= $s->name . ' ' . $s->operator . ' ' . $_ . ' OR ';
    }

    # strip last OR
    $ret = substr($ret,0, length($ret) - 4) if (length($ret) >0);
    $ret .=')';


    return $ret;
}

sub to_qs_name  {
    my $s = shift;

    my $ret = 'fld[' . $s->name;
    $ret.=':' . $s->tag if ($s->tag);
    $ret.=']';

    return $ret;

}

sub _extract_double_dots {
    my $s   = shift;
    my $val = shift;

    my @ret = split(/:/, $val);

    return $ret[1];
}



no Moose;
__PACKAGE__->meta->make_immutable;

1;
