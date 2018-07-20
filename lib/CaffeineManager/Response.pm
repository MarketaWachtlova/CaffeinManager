package CaffeineManager::Response;

use Dancer2 appname => 'CaffeineManager';
use Readonly;

require Exporter;
use base qw(Exporter);

our $VERSION = '0.1';

Readonly my $STATUS_BAD_REQUEST => 400;
Readonly my $STATUS_OK          => 200;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub error_response {
    my ( $self, $error_text ) = @_;
    status $STATUS_BAD_REQUEST;
    return to_json(
        {
            'error_code' => $STATUS_BAD_REQUEST,
            'error_text' => $error_text
        }
    );
}

sub success_response {
    my ( $self, $response_data_href ) = @_;
    status $STATUS_OK;
    return to_json($response_data_href);
}

1;
