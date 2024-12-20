#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session;

my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');
print STDERR "conexion";

# Recuperar el session_id de la sesión
my $session_id = $q->param('session_id');  # Enviamos el session_id al script

# Recuperar las variables de entorno para la conexión
my $db_host = $ENV{'DB_HOST'} || 'db';  # Si no está en el entorno, usar 'db' como host
my $db_name = $ENV{'DB_NAME'} || 'pweb1';
my $db_user = $ENV{'DB_USER'} || 'alumno';
my $db_password = $ENV{'DB_PASSWORD'} || 'pweb1';

# Comprobar si el session_id está presente
if (defined($session_id)) {
    # Llamar a la función que elimina el session_id en la base de datos
    removeSessionID($session_id);
    print renderXML('<message>Sesión cerrada correctamente</message>');
} else {
    print renderXML('<message>No se proporcionó session_id</message>');
}

sub removeSessionID {
    my ($session_id) = @_;

    # Usamos las variables de entorno para la conexión
    my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=3306";
    
    # Intentamos la conexión a la base de datos
    my $dbh = DBI->connect($dsn, $db_user, $db_password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar: $DBI::errstr\n");
    
    # Actualizamos el session_id en la base de datos para que sea NULL
    my $sql = "UPDATE usuarios SET session_id = NULL WHERE session_id = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($session_id);
    $sth->finish;
    $dbh->disconnect;
}

sub renderXML {
    my $cuerpoxml = $_[0];
    my $xml = <<"XML";
<?xml version='1.0' encoding='UTF-8'?>
<response>
    $cuerpoxml
</response>
XML
    return $xml;
}