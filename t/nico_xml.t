use strict;
use warnings;
use Test::More 'no_plan';
use Test::Deep;
use lib qw(../lib);

use constant NICO_XML => 'http://www.nicovideo.jp/ranking/view/hourly/all?rss=2.0&nomemo=1&nothumbnail=1&nodescription=1';
use constant POST_NUM => 3;
use Dumpvalue;

# NicoXml
BEGIN {
    use_ok('NicoXml');
}
can_ok('NicoXml','new');

my $nx = NicoXml->new(NICO_XML);
my $nx2 = NicoXml->new('http://dameninngenn.com/test.xml');
isa_ok($nx,'NicoXml');
isa_ok($nx2,'NicoXml');

is($nx->{xml_url},NICO_XML,'is defined xml_url');

# _get_nico_xml
can_ok($nx,'_get_nico_xml');
ok($nx->_get_nico_xml(),'_get_nico_xml[return 1]');
ok(!$nx2->_get_nico_xml(),'_get_nico_xml[return 0]');

# _extract_id_from_url
can_ok($nx,'_extract_id_from_url');
ok(!$nx->_extract_id_from_url(),'_extract_id_from_url[no argument test]');
ok(
    !$nx->_extract_id_from_url('http://www.nicovideo.jp/watch/sm'),
    '_extract_id_from_url[error argument test]'
);
is(
    $nx->_extract_id_from_url('http://www.nicovideo.jp/watch/sm10866580'),
    10866580,
    '_extract_id_from_url[return value test]'
);
is(
    $nx->_extract_id_from_url('http://www.nicovideo.jp/watch/sm10866'),
    10866,
    '_extract_id_from_url[return value test]'
);

# _extract_data
can_ok($nx,'_extract_data');
ok($nx->_extract_data(POST_NUM),'_extract_data[return 1]');
ok(!$nx2->_extract_data(POST_NUM),'_extract_data[return 0]');

# Uniting
my $nx3 = NicoXml->new(NICO_XML);
isa_ok($nx3,'NicoXml');

# get_nico_info
can_ok($nx3,'get_nico_info');
my $result_ref = $nx->get_nico_info(POST_NUM);

foreach my $item (@$result_ref) {
    cmp_deeply(
        $item,
        {
            id  => re('^(\d+)$'),
            link => re('^http.*sm(\d+)$'),
            title => ignore(),
        },
        'get_nico_info[data structure check]'
    );
}

