package CaffeineManager::Machine;

use Dancer2 appname => 'CaffeineManager';
use Dancer2::Plugin::Pg;
use Readonly;
use English '-no_match_vars';
use CaffeineManager::Response;

require Exporter;
use base qw(Exporter);

our $VERSION = '0.1';

Readonly my $MAX_FIELD_LENGTH => 100;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub register {

    my $responder = CaffeineManager::Response->new();

    # get request data
    if ( ! request->body ) {
        return $responder->error_response('Wrong JSON format');
    }
    my $request_data = eval { from_json( request->body ) };
    return $responder->error_response('Wrong JSON format') if ($EVAL_ERROR);

    # validate mandatory params
    for ( 'name', 'caffeine' ) {
        return $responder->error_response("Missing mandatory param: $_")
          unless exists $request_data->{$_};
    }

    # validate length
    if ( length( $request_data->{'name'} ) > $MAX_FIELD_LENGTH ) {
        return $responder->error_response(
            "The name is too long (max. length: $MAX_FIELD_LENGTH");
    }

    # validate unique name
    return $responder->error_response('The name already exists')
      if CaffeineManager::Machine->record_exists( $request_data->{'name'}, 'name' );

    # save machine data in database
    my $pg = Pg;
    $pg->table('coffee_machine');
    $pg->column( 'name',     $request_data->{'name'} );
    $pg->column( 'caffeine', $request_data->{'caffeine'} );
    $pg->returning('id');
    my $result = eval { $pg->insert };
    return $responder->error_response("Database error: $EVAL_ERROR")
      if ($EVAL_ERROR);
    return $responder->success_response( { 'id' => $result->{id} } );
}

sub record_exists {
    my ( $self, $field_value, $field_name ) = @_;

    my $total = Pg->selectOne(
        'SELECT COUNT(*) FROM coffee_machine WHERE ' . $field_name . ' = ?',
        $field_value );
    return $total;
}

1;
