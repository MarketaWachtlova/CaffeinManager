package CaffeineManager::Coffee;

use Dancer2 appname => 'CaffeineManager';
use Dancer2::Plugin::Pg;
use DateTime;
use DateTime::Format::ISO8601;
use English '-no_match_vars';
use Scalar::Util qw(looks_like_number);
use CaffeineManager::User;
use CaffeineManager::Machine;
use CaffeineManager::Response;

require Exporter;
use base qw(Exporter);

our $VERSION = '0.1';

my $responder = CaffeineManager::Response->new();

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub buy_now {
    return _buy( DateTime->now( time_zone => 'Europe/Prague' ) );
}

sub buy_at_time {

    # get request data
    if ( ! request->body ) {
        return $responder->error_response('Wrong JSON format');
    }
    my $request_data = eval { from_json( request->body ) };
    return $responder->error_response('Wrong JSON format') if ($EVAL_ERROR);

    # validate mandatory param
    return $responder->error_response('Missing mandatory param: timestamp')
      unless exists $request_data->{'timestamp'};

    # validate timestamp format (iso-8601)
    my $timestamp = $request_data->{'timestamp'};
    eval {
        my $iso8601 = DateTime::Format::ISO8601->new;
        $iso8601->parse_datetime($timestamp);
        1;
    } or do {
        return $responder->error_response(
            'Wrong time format (ISO 8601 is required)');
    };

    return _buy($timestamp);
}

sub _buy {

    my ($time) = @_;

    # check that ids are numbers
    for ( 'user-id', 'machine-id' ) {
        if ( ! looks_like_number params->{$_} ) {
            return $responder->error_response("$_ must be a number");
        }
    }

    # check that ids exist in the database
    my $user = CaffeineManager::User->new();
    if ( ! $user->record_exists( params->{'user-id'}, 'id' ) ) {
        return $responder->error_response('This user-id does not exists');
    }
    my $machine = CaffeineManager::Machine->new();
    if ( ! $machine->record_exists( params->{'machine-id'}, 'id' ) ) {
        return $responder->error_response('This machine-id does not exists');
    }

    # insert into db
    my $pg = Pg;
    $pg->table('coffee_sale');
    $pg->column( 'coffee_drinker_id', params->{'user-id'} );
    $pg->column( 'coffee_machine_id', params->{'machine-id'} );
    $pg->column( 'time',              $time );
    $pg->returning('id');
    my $result = eval { $pg->insert };
    return $responder->error_response("Database error: $EVAL_ERROR")
      if ($EVAL_ERROR);

    return;
}

1;
