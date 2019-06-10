package Search::QS::Filter;

use v5.14;
use Moose;

# ABSTRACT: Incapsulation of a single filter element

=head1 SYNOPSIS

  use Search::QS::Filter;

  my $flt = new Search::QS::Filter;
  # parse query_string
  $flt->parse_qs($qs);
  # reconvert object to query_string
  print $flt->to_qs;


=head1 DESCRIPTION

This object incapsulate a single filter element. Think of it about a single
search element in an SQL string. Like

  fullname = "Joe"

it has a fied L</"name()"> "fullname", an L</"operator()"> "=" and a
L</"value()"> "Joe".

=cut

has 'name'      => (is => 'rw');
has 'operator'  => (is => 'rw', default => '=');
has 'value'     => (is => 'rw', isa => 'ArrayRef', default => sub { return [] } );
has 'tag'       => (is => 'rw');
has 'andGroup'  => (is => 'rw');
has 'orGroup'   => (is => 'rw');

=method name()

The field name to search

=method operator()

The operator to use between field and value

=method value()

An ARRAYREF with values to search in field name. It should be expanded with OR
concatenation. As an example,

  fld[x]=1&fld[x]=2

after parsing produce

    name => 'x', values => [1,2]

and in SQL syntax must be written like

  x=1 or x=2

=method tag()

In field name it can be use ":" to separe field name by a tag. The idea is to
distinguish different operation with same field name.

As an example

  fld[a:1]=1&fld[a:1]=$op:>&fld[a:2]=5&fld[a:2]=$op:<

must be

  a>1 and a<5

=method andGroup()

If you set a field with $and:$groupvalue you set that this field in a AND group
with other fields with same $groupvalue

As an example to

  flt[d:1]=9&flt[d:1]=$and:1&flt[c:1]=2&flt[c:1]=$and:1&flt[d:2]=3&flt[d:2]=$and:2&flt[c:2]=1&flt[c:2]=$and:2

is traslated in

( d=9 AND c=2 ) OR ( d=3 and c=1 )


=method orGroup()

Like L</"andGroup()"> but for OR operator

=cut

=method parse($perl_struct)

$perl_struct is an HASHREF which represents a query string like
the one returned by L<URI::Encode/"url_params_mixed">.
It parses the struct and extract filter informations
=cut
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

=method to_qs()

Return a query string of the internal rappresentation of the object
=cut
sub to_qs() {
    my $s = shift;


    my $ret = '';

    foreach (@{$s->value}) {
        $ret .= $s->_to_qs_name . '=' . $_ . '&';
    }
    # remove last &
    chop($ret) if (length($ret) > 0);
    $ret.= '&' . $s->_to_qs_name . '=$op:' . $s->operator if ($s->operator ne '=');
    $ret.= '&' . $s->_to_qs_name . '=$and:' . $s->andGroup if ($s->andGroup);
    $ret.= '&' . $s->_to_qs_name . '=$or:' . $s->orGroup if ($s->orGroup);

    return $ret;
}

=method to_sql

Return this object as a SQL search
=cut
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

sub _to_qs_name  {
    my $s = shift;

    my $ret = 'flt[' . $s->name;
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
