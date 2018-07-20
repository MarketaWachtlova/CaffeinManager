use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;
use CaffeineManager;

use Test::More tests => 15;

# create an application
my $app = CaffeineManager->to_app;

# create a testing object
my $test = Plack::Test->create($app);

#-------------------------------------------------------------------

# insert user
my $user_data = {
    'login'    => time.'_user_001',
    'password' => 'password',
    'email'    => time.'_email_001@email.com',
};
my $user_response = $test->request(
    PUT '/user/request',
    Content_Type => 'application/json',
    Content => to_json($user_data)
);
my $user_id = from_json( $user_response->content )->{'id'};

#-------------------------------------------------------------------

# insert machine
my $machine_data = {
    'name'     => time.'_machine_001',
    'caffeine' => 100,
};
my $machine_response = $test->request(
    POST '/machine',
    Content_Type => 'application/json',
    Content => to_json($machine_data)
);
my $machine_id = from_json( $machine_response->content )->{'id'};

#-------------------------------------------------------------------

my @transactions_timestamps = (
    '2018-01-01T01:42:16',
    '2018-01-01T02:42:16',
    '2018-01-01T03:42:16',
);

for my $time ( @transactions_timestamps ){
    my $buy_response = $test->request(
        PUT "/coffee/buy/$user_id/$machine_id",
        Content_Type => 'application/json',
        Content => to_json({ timestamp => $time })
    );
}

#-------------------------------------------------------------------

# stats
my $stats_response = $test->request(
    GET "/stats/coffee/user/$user_id",
);

my $returned_data_aref = from_json( $stats_response->content );
for my $item ( @{ $returned_data_aref } ){
    is ( $item->{'user'}->{'login'},   $user_data->{'login'} );
    is ( $item->{'user'}->{'id'},      $user_id );
    is ( $item->{'machine'}->{'name'}, $machine_data->{'name'} );
    is ( $item->{'machine'}->{'id'},   $machine_id );
    is ( exists $item->{'timestamp'},  1 );
}

#-------------------------------------------------------------------

done_testing();
