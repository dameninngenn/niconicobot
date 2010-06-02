use strict;
use warnings;
use Test::More 'no_plan';
use lib qw(../lib);
use YAML::Tiny;
use Dumpvalue;

# yamlファイル名
use constant NICOYAML_FILENAME => '.niconicobot.yaml';
use constant CONFIG_FILENAME => 'config.yaml';

# OAuth configs
my $config = YAML::Tiny::LoadFile(CONFIG_FILENAME);
my $consumer_key = $config->{consumer_key};
my $consumer_key_secret = $config->{consumer_key_secret};
my $access_token = $config->{access_token};
my $access_token_secret = $config->{access_token_secret};

# NicoNicoBot
BEGIN {
    use_ok('NicoNicoBot');
}
can_ok('NicoNicoBot','new');

# new
my $nb = NicoNicoBot->new($consumer_key,$consumer_key_secret,$access_token,$access_token_secret);
isa_ok($nb,'NicoNicoBot');
ok($nb->{twitter},'new(initialize)');

# yamlから前回のpost情報読み込み
my $before_nico_info = YAML::Tiny::LoadFile(NICOYAML_FILENAME);

# xmlとyamlの比較
my $d = Dumpvalue->new();
my @xml_data = (
    {
        id => 20925985,
        link => 'http://www.nicovideo.jp/watch/sm10925979',
        title => '第1位：【速報】鳩山首相辞任、小沢幹事長辞任要求 (2010/06/02 関西テレビ)'
    },
    {
        id => 20897520,
        link => 'http://www.nicovideo.jp/watch/sm10897520',
        title => '第2位：真・三國夢精 【兄貴伝】'
    },
    {
        id => 20879384,
        link => 'http://www.nicovideo.jp/watch/sm10879384',
        title => '第3位：【けいおん!!】 『平沢憂のヤンデレ画像集』'
    },
);
my $xml_ref = \@xml_data;

can_ok($nb,'check_deduped');
ok(
    !$nb->check_deduped(
        $before_nico_info,
        $xml_ref
    ),
    'check_deduped[return 0]'
);

ok(
    $nb->check_deduped(
        $xml_ref,
        $xml_ref
    ),
    'check_deduped[return 1]'
);

can_ok($nb,'is_undef_or_empty');
ok($nb->is_undef_or_empty(undef),'is_undef_or_empty[undef]');
ok($nb->is_undef_or_empty(''),'is_undef_or_empty[empty]');
ok(!$nb->is_undef_or_empty('test'),'is_undef_or_empty[not empty]');

can_ok($nb,'make_post_str');
foreach my $post_data(@$xml_ref){
    is(
        $nb->make_post_str(
            $post_data->{title},
            $post_data->{link}
        ),
        $post_data->{title}.' '.$post_data->{link},
        'make_post_str[ok]'
    );
    ok(
        !$nb->make_post_str(
            $post_data->{title},
            undef
        ),
        'make_post_str[ng]'
    );
    ok(
        !$nb->make_post_str(
            $post_data->{title},
            ''
        ),
        'make_post_str[ng]'
    );
}
