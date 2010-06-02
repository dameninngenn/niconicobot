use strict;
use warnings;
use Test::More 'no_plan';
use lib qw(../lib);
use YAML::Tiny;
use Dumpvalue;
use NicoXml;

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
    { id => 100000, link => '', title => '' },
    { id => 200000, link => '', title => '' },
    { id => 300000, link => '', title => '' },
);
my $xml_ref = \@xml_data;
#$d->dumpValues($xml_ref->[0]->{id});
#$d->dumpValues($xml_ref);


