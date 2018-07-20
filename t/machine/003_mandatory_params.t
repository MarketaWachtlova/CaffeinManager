use strict;
use warnings;

use JSON;
use Plack::Test;
use HTTP::Request::Common;
use Storable qw(dclone);
use CaffeineManager;

use Test::More tests => 4;

# create an application
my $app = CaffeineManager->to_app;

# create a testing object
my $test = Plack::Test->create($app);

# machine data
my $machine_data = {
	'name'     => time.'_machine_003',
	'caffeine' => 100,
};

# request
for ( 'name', 'caffeine' ){
	my $tmp_machine = dclone $machine_data;
	delete $tmp_machine->{$_};

	my $response = $test->request(
		POST '/machine',
		Content_Type => 'application/json',
		Content => to_json($tmp_machine)
	);

	is( $response->code, 400 );
	like( $response->content, qr/Missing mandatory param: $_/ );
}

done_testing();
