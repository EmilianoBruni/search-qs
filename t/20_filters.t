package main;

use Test::More;
use Tie::IxHash;

#use URL::Encode qw(:all);
use Data::Dumper;
use Search::QS::Filter;
use Search::QS::Filters;

my $num = 0;

$qs = 'flt[Name]=Foo'; # SQL: (Name = Foo)
is(convert_url_params_to_filter_and_return($qs), $qs);
$num++;

my $qs = 'flt[age]=5&flt[age]=9&flt[Name]=Foo';
is(convert_url_params_to_filter_and_return($qs), $qs);
$num++;

$qs = 'flt[FirstName]=Foo&flt[FirstName]=$or:1&flt[LastName]=Bar&flt[LastName]=$or:1';
is(convert_url_params_to_filter_and_return($qs), $qs);
$num++;

$qs ='flt[c:one]=1&flt[c:one]=$and:1&flt[d:one]=2&flt[d:one]=$and:1&'.
    'flt[c:two]=2&flt[c:two]=$and:2&flt[d:two]=3&flt[d:two]=$op:>&'.
    'flt[d:two]=$and:2&flt[d:three]=10';
is(convert_url_params_to_filter_and_return($qs), $qs);
$num++;

done_testing($num);

sub convert_url_params_to_filter_and_return {
    my $qs = shift;
    my $struct = url_params_mixed($qs);
    return &to_qs($struct);
}

sub to_qs {
    my $struct = shift;

    my $filters = new Search::QS::Filters;
    $filters->parse($struct);

    return $filters->to_qs;
}

# changed from URL::Encode to use Tie::IxHash instead of hash

my (%DecodeMap, %EncodeMap);
BEGIN {
    for my $ord (0..255) {
        my $chr = pack 'C', $ord;
        my $hex = sprintf '%.2X', $ord;
        $DecodeMap{lc $hex} = $chr;
        $DecodeMap{uc $hex} = $chr;
        $DecodeMap{sprintf '%X%x', $ord >> 4, $ord & 15} = $chr;
        $DecodeMap{sprintf '%x%X', $ord >> 4, $ord & 15} = $chr;
        $EncodeMap{$chr} = '%' . $hex;
    }
    $EncodeMap{"\x20"} = '+';
}

sub url_params_each {
    @_ == 2 || @_ == 3 || Carp::croak(q/Usage: url_params_each(octets, callback [, utf8])/);
    my ($s, $callback, $utf8) = @_;

    utf8::downgrade($s, 1)
      or Carp::croak(q/Wide character in octet string/);

    foreach my $pair (split /[&;]/, $s, -1) {
        my ($k, $v) = split '=', $pair, 2;
        $k = '' unless defined $k;
        for ($k, defined $v ? $v : ()) {
            y/+/\x20/;
            s/%([0-9a-fA-F]{2})/$DecodeMap{$1}/gs;
            if ($utf8) {
                utf8::decode($_)
                  or Carp::croak("Malformed UTF-8 in URL-decoded octets");
            }
        }
        $callback->($k, $v);
    }
}

sub url_params_mixed {
    @_ == 1 || @_ == 2 || Carp::croak(q/Usage: url_params_mixed(octets [, utf8])/);
    tie my %p, 'Tie::IxHash';
    my $callback = sub {
        my ($k, $v) = @_;
        if (exists $p{$k}) {
            for ($p{$k}) {
                $_ = [$_] unless ref $_ eq 'ARRAY';
                push @$_, $v;
            }
        }
        else {
            $p{$k} = $v;
        }
    };
    url_params_each($_[0], $callback, $_[1]);
    return \%p;
}
