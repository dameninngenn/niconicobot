package NicoNicoBot;

use strict;
use warnings;
use Net::Twitter;
use Dumpvalue;

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

sub check_deduped {
    my $self = shift;
    my $old_data = shift;
    my $new_data = shift;

    foreach my $num(0..scalar(@$old_data)-1) {
        unless ($old_data->[$num]->{id} == $new_data->[$num]->{id}){
            return 0;
        }
    }
    return 1;
}

sub is_undef_or_empty {
    my $self = shift;
    my $value = shift;
    unless($value){
        return 1;
    }
    return 0;
}

sub make_post_str {
    my $self = shift;
    my $title = shift;
    my $link = shift;

    return 0 if($self->is_undef_or_empty($link));

    my $post_str = $title.' '.$link;
    return $post_str;
}

1;

