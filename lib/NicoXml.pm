package NicoXml;

use strict;
use warnings;
use XML::Simple;
use LWP::Simple;

sub new {
    my $class = shift;
    my $xml_url = shift;
    my $self = {
        xml_url => $xml_url,
        xml_data => undef,
        ranking_data => undef,
    };
    bless $self, $class;
    return $self;
}

sub get_nico_info {
    my $self = shift;
    my $target_num = shift;
    my $nico_info;
    return 0 unless($self->_get_nico_xml());
    return 0 unless($self->_extract_data($target_num));
    
    return \@{$self->{ranking_data}};
    
}

sub _extract_id_from_url {
    my $self = shift;
    my $nico_url = shift;
    return 0 unless(defined $nico_url);
    $nico_url =~ /(\d+)$/;
    return 0 unless(defined $&);
    return $&;
}

sub _extract_data {
    my $self = shift;
    my $target_num = shift;
    return 0 unless(defined $self->{xml_data});
    eval{
        foreach my $num (0..$target_num - 1){
            my $id = $self->_extract_id_from_url($self->{xml_data}->{channel}->{item}->[$num]->{link});
            return 0 unless($id);
            $self->{ranking_data}->[$num]->{id} = $id;
            $self->{ranking_data}->[$num]->{title} = $self->{xml_data}->{channel}->{item}->[$num]->{title};
            $self->{ranking_data}->[$num]->{link} = $self->{xml_data}->{channel}->{item}->[$num]->{link};
        }
    };
    return 0 if($@);
    return 1;
}

sub _get_nico_xml {
    my $self = shift;
    my $xml_result;
    my $xs;
    my $ref;
    eval{
        $xml_result = get($self->{xml_url});
        $xs = new XML::Simple();
        $ref = $xs->XMLin($xml_result);
    };
    return 0 if($@ or !defined($ref));
    $self->{xml_data} = $ref;
    return 1;
}


1;
