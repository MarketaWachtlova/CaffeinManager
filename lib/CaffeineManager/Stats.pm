package CaffeineManager::Stats;

use Dancer2 appname => 'CaffeineManager';
use Dancer2::Plugin::Pg;
use DateTime;
use DateTime::Duration;
use Readonly;
use Scalar::Util qw(looks_like_number);
use CaffeineManager::Response;

require Exporter;
use base qw(Exporter);

our $VERSION = '0.1';

my $pg = Pg;

Readonly my $LEVEL_TRESH_VALUE     => 0.0001;
Readonly my $LEVEL_VALUE_PRECISION => '%.4f';
Readonly my $HOUR_IN_SECONDS       => 3600;
Readonly my $HALF_LIFE_IN_SECONDS  => $HOUR_IN_SECONDS * 5;
Readonly my $STATS_PERIOD_IN_HOURS => 24;

my $responder = CaffeineManager::Response->new();

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub get_stats {

    my ( $field, $id ) = @_;

    my $query =
        'SELECT coffee_drinker_id, login, coffee_machine_id, name, time '
      . 'FROM coffee_sale '
      . 'JOIN coffee_drinker ON coffee_sale.coffee_drinker_id = coffee_drinker.id '
      . 'JOIN coffee_machine ON coffee_sale.coffee_machine_id = coffee_machine.id ';

    my $rows_aref;
    if ( defined $field && defined $id ) {

        # check that user_id and machine_id are numbers
        if ( ! looks_like_number $id ) {
            return $responder->error_response('Id must be a number');
        }

        $query .= " WHERE $field.id = ? ";
        $rows_aref = Pg->selectAll( $query, $id );
    }
    else {
        $rows_aref = Pg->selectAll($query);
    }

    my @transactions;
    for ( @{$rows_aref} ) {
        my %tmp;
        $tmp{'user'}{'id'}      = $_->{'coffee_drinker_id'};
        $tmp{'user'}{'login'}   = $_->{'login'};
        $tmp{'machine'}{'id'}   = $_->{'coffee_machine_id'};
        $tmp{'machine'}{'name'} = $_->{'name'};
        $tmp{'timestamp'}       = $_->{'time'};

        push @transactions, \%tmp;
    }

    return to_json( \@transactions );
}

sub get_machine_stats {
    return get_stats( 'coffee_machine', params->{'id'} );
}

sub get_user_stats {
    return get_stats( 'coffee_drinker', params->{'id'} );
}

sub get_level_stats {

    # get request data
    my $user_id = params->{'id'};

    # ask database
    my $all_coffees = Pg->selectAll(
        'SELECT caffeine, extract(epoch from coffee_sale.time) as intake_epoch '
          . 'FROM coffee_sale '
          . 'JOIN coffee_drinker ON coffee_sale.coffee_drinker_id = coffee_drinker.id '
          . 'JOIN coffee_machine ON coffee_sale.coffee_machine_id = coffee_machine.id '
          . 'WHERE coffee_drinker.id = ? ',
        $user_id
    );

    my $tested_timestamp = DateTime->now( time_zone => 'Europe/Prague' );

    my %caffeine_level;
    my $hour_duration = DateTime::Duration->new( hours => 1, );

    for ( 0 .. $STATS_PERIOD_IN_HOURS ) {

        # compute caffeine level for tested time
        $caffeine_level{$tested_timestamp} = 0;
        for my $coffee ( @{$all_coffees} ) {
            $caffeine_level{$tested_timestamp} += _get_caffeine_level(
                {
                    'tested_epoch' => $tested_timestamp->hires_epoch,
                    'intake_epoch' => $coffee->{'intake_epoch'},
                    'caffeine'     => $coffee->{'caffeine'},
                }
            );
        }

        # set precision
        $caffeine_level{$tested_timestamp} =
          ( $caffeine_level{$tested_timestamp} < $LEVEL_TRESH_VALUE )
          ? 0
          : sprintf $LEVEL_VALUE_PRECISION, $caffeine_level{$tested_timestamp};

        # change tested time
        $tested_timestamp->subtract_duration($hour_duration);
    }

    return to_json( \%caffeine_level );
}

sub _get_caffeine_level {
    my ($args) = @_;

    # coffees tha will be drunk in the future
    if ( $args->{'intake_epoch'} > $args->{'tested_epoch'} ) {
        return 0;
    }

    # get time from drinking coffee to the testing time (in seconds)
    my $time_from_drinking = $args->{'tested_epoch'} - $args->{'intake_epoch'};

    # compute caffeine from coffees drunk in last hour
    if ( $time_from_drinking <= $HOUR_IN_SECONDS ) {
        return $args->{'caffeine'} * $time_from_drinking / $HOUR_IN_SECONDS;
    }

    # compute caffeine from other coffees
    else {
        my $exponent =
          ( $time_from_drinking - $HOUR_IN_SECONDS ) / $HALF_LIFE_IN_SECONDS;
        return $args->{'caffeine'} * ( ( 1 / 2 )**$exponent );
    }
}

1;
