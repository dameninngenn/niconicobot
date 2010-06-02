package NicoNicoBot;

use strict;
use warnings;
use Net::Twitter;

sub new {
    my $class = shift;
    my $consumer_key = shift;
    my $consumer_key_secret = shift;
    my $access_token = shift;
    my $access_token_secret = shift;
    my $self = {
        twitter => undef,
    };
    $self->{twitter} = Net::Twitter->new(
                          traits          => ['API::REST', 'OAuth'],
                          consumer_key    => $consumer_key,
                          consumer_secret => $consumer_key_secret,
                        );
    $self->{twitter}->access_token($access_token);
    $self->{twitter}->access_token_secret($access_token_secret);
    bless $self, $class;
    return $self;
}

1;

