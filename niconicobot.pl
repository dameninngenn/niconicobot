#!/usr/bin/perl

use strict;
use warnings;
use lib qw(./lib);
use NicoXml;
use NicoNicoBot;
use YAML::Tiny;
use utf8;

use constant NICO_XML => 'http://www.nicovideo.jp/ranking/view/hourly/all?rss=2.0&nomemo=1&nothumbnail=1&nodescription=1';
use constant POST_NUM => 3;
use constant NICOYAML_FILENAME => '.niconicobot.yaml';
use constant CONFIG_FILENAME => 'config.yaml';
use constant CHECK_DEDUPED_FLAG => 1;

# OAuth configs
my $config = YAML::Tiny::LoadFile(CONFIG_FILENAME);
my $consumer_key = $config->{consumer_key};
my $consumer_key_secret = $config->{consumer_key_secret};
my $access_token = $config->{access_token};
my $access_token_secret = $config->{access_token_secret};

my $nicoxml = NicoXml->new(NICO_XML); 
my $nicoxml_ref = $nicoxml->get_nico_info(POST_NUM);

# yamlから前回のpost情報読み込み
my $before_nico_info = YAML::Tiny::LoadFile(NICOYAML_FILENAME);

# exec
my $niconicobot = NicoNicoBot->new($consumer_key,$consumer_key_secret,$access_token,$access_token_secret);
eval{
    $niconicobot->exec_niconicobot($before_nico_info,$nicoxml_ref,CHECK_DEDUPED_FLAG);
};
YAML::Tiny::DumpFile(NICOYAML_FILENAME,$nicoxml_ref);

# follow調整
$niconicobot->friends_eq_followers();


