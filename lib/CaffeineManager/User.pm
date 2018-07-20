package CaffeineManager::User;

use JSON;
use Dancer2 appname => 'CaffeineManager';
use Dancer2::Plugin::Pg;
use Dancer2::Plugin::Passphrase;
use DateTime;
use Readonly;
use Email::Valid;
use CaffeineManager::Response;
use English '-no_match_vars';

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
    my $request_data = eval { from_json( request->body ) };
    return $responder->error_response('Wrong JSON format') if ($EVAL_ERROR);

    # validate mandatory params
    for ( 'login', 'password', 'email' ) {
        return $responder->error_response("Missing mandatory param: $_")
          unless exists $request_data->{$_};
    }

    # validate length
    for ( 'login', 'email' ) {
        if ( length( $request_data->{$_} ) > $MAX_FIELD_LENGTH ) {
            return $responder->error_response(
                "The $_ is too long (max. length: $MAX_FIELD_LENGTH");
        }
    }

    # validate unique fields
    for ( 'login', 'email' ) {
        return $responder->error_response("The $_ already exists")
          if CaffeineManager::User->record_exists( $request_data->{$_}, $_ );
    }

    # validate e-mail
    if ( ! Email::Valid->address( $request_data->{'email'} ) ) {
        return $responder->error_response('The email is not valid');
    }

    # hash the password
    my $password_hash =
      passphrase( $request_data->{'password'} )->generate->rfc2307;

    # save user data in database
    my $pg = Pg;
    $pg->table('coffee_drinker');
    $pg->column( 'login',    $request_data->{'login'} );
    $pg->column( 'password', $password_hash );
    $pg->column( 'email',    $request_data->{'email'} );
    $pg->returning('id');
    my $result = eval { $pg->insert };
    return $responder->error_response("Database error: $EVAL_ERROR")
      if ($EVAL_ERROR);
    return $responder->success_response( { 'id' => $result->{id} } );
}

sub record_exists {
    my ( $self, $field_value, $field_name ) = @_;

    my $total = Pg->selectOne(
        'SELECT COUNT(*) FROM coffee_drinker WHERE ' . $field_name . ' = ?',
        $field_value );
    return $total;
}

1;
