use Test::More;
use Search::QS;
use Tie::IxHash;

my $num = 0;

my $sqs = new Search::QS;

isa_ok($sqs->options, 'Search::QS::Options');
$num++;

is($sqs->options->to_qs , '', "Empty options");
$num++;


my $qs = 'start=5';
&test_qs($qs,"Check start options....");
#my $struct = url_params_mixed($qs);
#$sqs->options->parse($struct);
#is($sqs->options->to_qs, $qs, "Check start options");
#$num++;
$qs = 'start=5&limit=8';
&test_qs($qs,"add limit....");
$qs = 'start=5&limit=8&sort[name]=asc';
&test_qs($qs,"add one sort....");
$qs = 'start=5&limit=8&sort[name]=asc&sort[type]=desc';
&test_qs($qs,"another sort....");


done_testing($num);

sub test_qs() {
    my $qs = shift;
    my $descr = shift;
    my $struct = url_params_mixed($qs);
    $sqs->options->parse($struct);
    is($sqs->options->to_qs, $qs, $descr);
    $num++;
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
