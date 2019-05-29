use Test::More;
use Search::QS;

my $num = 0;

my $qs = new Search::QS;

isa_ok($qs->filters, 'Search::QS::Filters');
$num++;

done_testing($num);
