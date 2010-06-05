package NicoNicoBot;

use strict;
use warnings;
use utf8;
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
        friends_ids => undef,
        followers_ids => undef,
        friends_hash => undef,
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

sub _check_deduped {
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

sub _is_undef_or_empty {
    my $self = shift;
    my $value = shift;
    unless($value){
        return 1;
    }
    return 0;
}

sub _make_post_str {
    my $self = shift;
    my $title = shift;
    my $link = shift;

    return 0 if($self->_is_undef_or_empty($link));

    my $post_str = $title.' '.$link;
    return $post_str;
}

sub exec_niconicobot {
    my $self = shift;
    my $old_data = shift;
    my $new_data = shift;
    my $check_deduped_flag = shift;

    if($check_deduped_flag && $self->_check_deduped($old_data,$new_data)){
        return 0;
    }

    eval{
        foreach my $data(@$new_data){
            my $post_str = $self->_make_post_str($data->{title},$data->{link});
            my $result = $self->{twitter}->update({ status => "$post_str" });
            unless($result){
                return 0;
            }
            sleep(5);
        }
    };
    return 0 if($@);
    return 1;
}

sub _get_friends_ids {
    my $self = shift;
    eval{
        $self->{friends_ids} = $self->{twitter}->friends_ids();
    };
    return 0 if($@);
    return 0 unless($self->{friends_ids});
    return 1;
}

sub _get_followers_ids {
    my $self = shift;
    eval{
        $self->{followers_ids} = $self->{twitter}->followers_ids();
    };
    return 0 if($@);
    return 0 unless($self->{followers_ids});
    return 1;
}

sub _make_friends_hash {
    my $self = shift;
    eval{
        my %friends_hash = map{($_ => 1)}@{$self->{friends_ids}};
        $self->{friends_hash} = \%friends_hash;
    };
    return 0 if($@);
    return 1;
}

sub _do_create_friendship {
    my $self = shift;
    foreach my $followers_id(@{$self->{followers_ids}}){
        my $result = delete $self->{friends_hash}->{$followers_id};
        unless (defined $result){
            eval{
                my $create_result = $self->{twitter}->create_friend({ user_id => "$followers_id" });
            };
            if($@ =~ m/フォローのリクエストを送ってあります/ || $@ =~ m/suspend/){
                next;
            }
            elsif($@){
                return 0;
            }
        }
    }
    return 1;
}

sub _do_destroy_friendship {
    my $self = shift;
    eval{
        foreach my $friends_id(keys %{$self->{friends_hash}}){
            my $result = $self->{twitter}->destroy_friend({ user_id => "$friends_id" });
            return 0 unless($result);
        }
    };
    return 0 if($@);
    return 1;
}

sub friends_eq_followers {
    my $self = shift;

    return 0 unless($self->_get_friends_ids());
    return 0 unless($self->_get_followers_ids());
    return 0 unless($self->_make_friends_hash());
    return 0 unless($self->_do_create_friendship());
    return 0 unless($self->_do_destroy_friendship());
    return 1;
}

1;

