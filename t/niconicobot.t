use strict;
use warnings;
use Test::More 'no_plan';
use lib qw(../lib);
use YAML::Tiny;
use Dumpvalue;

# yamlファイル名
use constant NICOYAML_FILENAME => '.niconicobot.yaml';
use constant CONFIG_FILENAME => 'config.yaml';
use constant CHECK_DEDUPED_FLAG => 1;

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
# check_deduped
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

# is_undef_or_empty
can_ok($nb,'is_undef_or_empty');
ok($nb->is_undef_or_empty(undef),'is_undef_or_empty[undef]');
ok($nb->is_undef_or_empty(''),'is_undef_or_empty[empty]');
ok(!$nb->is_undef_or_empty('test'),'is_undef_or_empty[not empty]');

# make_post_str
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

# exec_niconicobot
can_ok($nb,'exec_niconicobot');
ok(
    $nb->exec_niconicobot($before_nico_info,$xml_ref,CHECK_DEDUPED_FLAG),
    'exec_niconicobot[ok]'
);
ok(
    !$nb->exec_niconicobot($xml_ref,$xml_ref,CHECK_DEDUPED_FLAG),
    'exec_niconicobot[ng]'
);
ok(
    $nb->exec_niconicobot($before_nico_info,$xml_ref,0),
    'exec_niconicobot[ok]'
);
ok(
    $nb->exec_niconicobot($xml_ref,$xml_ref,0),
    'exec_niconicobot[ok]'
);

# get_friends_ids
can_ok($nb,'get_friends_ids');
ok(
    $nb->get_friends_ids(),
    'get_friends_ids[ok]'
);

# get_followers_ids
can_ok($nb,'get_followers_ids');
ok(
    $nb->get_followers_ids(),
    'get_followers_ids[ok]'
);

# make_friends_hash
can_ok($nb,'make_friends_hash');
ok(
    $nb->make_friends_hash(),
    'make_friends_hash[ok]'
);

# do_create_friendship
can_ok($nb,'do_create_friendship');
#ok(
#    $nb->do_create_friendship(),
#    'do_create_friendship[ok]'
#);

# do_destroy_friendship
can_ok($nb,'do_destroy_friendship');
#ok(
#    $nb->do_destroy_friendship(),
#    'do_destroy_friendship[ok]'
#);

# friends_eq_followers
can_ok($nb,'friends_eq_followers');
ok(
    $nb->friends_eq_followers(),
    'friends_eq_followers[ok]'
);
