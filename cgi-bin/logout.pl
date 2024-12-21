#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;
use DBI;
use CGI::Carp qw(fatalsToBrowser);

# Crear un objeto CGI para manejar los parámetros
my $q = CGI->new;

# Establecer el encabezado de la respuesta como texto XML
print $q->header('text/xml;charset=UTF-8');

# Obtener el session_id desde la solicitud POST
my $session_id = $q->param('session_id');

# Comprobar si session_id está presente
if (defined($session_id) && $session_id ne '') {
    # Llamar a la función que elimina el session_id en la base de datos
    eliminarSessionID($session_id);
    print renderXML('<message>Sesión cerrada correctamente</message>');
} else {
    print renderXML('<message>No se proporcionó session_id</message>');
}

# Función para eliminar el session_id de la base de datos
sub eliminarSessionID {
    my $session_id = $_[0];  # El session_id que se recibe como parámetro
    
    # Datos de conexión
    my $user = 'alumno';
    my $password = 'pweb1';
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306';  # Usar 'db' como host en Docker Compose
    
    # Conectar a la base de datos
    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar a la base de datos: $DBI::errstr\n");
    
    # Consulta SQL para actualizar session_id a NULL
    my $sql = "UPDATE usuarios SET session_id = NULL WHERE session_id = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($session_id);  # Ejecutamos la consulta con el session_id proporcionado
    
    # Finalizar la consulta y desconectar
    $sth->finish;
    $dbh->disconnect;
    
    print "Session_id eliminado correctamente de la base de datos\n";
}

# Función para generar la respuesta XML
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