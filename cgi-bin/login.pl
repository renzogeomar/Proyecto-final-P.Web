#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use CGI::Session;

my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');

my $user = $q->param('user');
my $password = $q->param('password');

print STDERR "User: $user\n";
print STDERR "Password: $password\n";

# Recuperar las variables de entorno para la conexión
my $db_host = $ENV{'DB_HOST'} || 'db';  # Si no está en el entorno, usar 'db' como host
my $db_name = $ENV{'DB_NAME'} || 'pweb1';
my $db_user = $ENV{'DB_USER'} || 'alumno';
my $db_password = $ENV{'DB_PASSWORD'} || 'pweb1';

my @respuesta;
if (defined($user) and defined($password)) {
    @respuesta = checkLogin($user, $password);
    print STDERR "Respuesta de checkLogin: @respuesta\n";  # Mostrar resultados de checkLogin
    
    if (@respuesta) {
        # Iniciar una nueva sesión
        my $session = CGI::Session->new(undef, $q, { Directory => '/tmp' });
        my $session_id = $session->id();  # Obtener el session_id generado automáticamente
        
        # Almacenar el session_id en la base de datos
        storeSessionID($user, $session_id);
        
        print STDERR "Nuevo session_id generado: $session_id\n";
        print STDERR "Enviando datos correctos al XML\n";
        my $cuerpoXML = renderCuerpo(@respuesta, $session_id);  # Pasar session_id a renderCuerpo
        print renderXML($cuerpoXML);
    } else {
        print STDERR "No hay coincidencias, enviando mensaje de error\n";
        print renderXML('<message>No se encontraron coincidencias</message>');
    }
} else {
    print STDERR "Datos no ingresados\n";
    print renderXML('<message>Faltan datos</message>');
}

sub checkLogin {
    my ($userQuery, $passwordQuery) = @_;
    
    # Usamos las variables de entorno para la conexión
    my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=3306";
    
    # Intentamos la conexión a la base de datos
    my $dbh = DBI->connect($dsn, $db_user, $db_password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar: $DBI::errstr\n");

    # Preparar y ejecutar la consulta
    my $sql = "SELECT * FROM usuarios WHERE userName=? AND password=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($userQuery, $passwordQuery);
    
    # Obtener el resultado
    my @row = $sth->fetchrow_array;
    $sth->finish;
    $dbh->disconnect;

    return @row;
}

sub storeSessionID {
    my ($user, $session_id) = @_;
    
    # Usamos las variables de entorno para la conexión
    my $dsn = "DBI:mysql:database=$db_name;host=$db_host;port=3306";
    
    # Intentamos la conexión a la base de datos
    my $dbh = DBI->connect($dsn, $db_user, $db_password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar: $DBI::errstr\n");
    
    # Actualizamos el session_id en la base de datos para el usuario
    my $sql = "UPDATE usuarios SET session_id = ? WHERE userName = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($session_id, $user);
    $sth->finish;
    $dbh->disconnect;
}

sub renderCuerpo {
    my @linea = @_;
    my $session_id = pop @linea;  # El último argumento es el session_id
    my $cuerpo = <<"CUERPO";
    <session_id>$session_id</session_id>
    <owner>$linea[0]</owner>
    <firstName>$linea[2]</firstName>
    <lastName>$linea[3]</lastName>
CUERPO
    return $cuerpo;
}

sub renderXML {
    my $cuerpoxml = $_[0];
    my $xml = <<"XML";
<?xml version='1.0' encoding='UTF-8'?>
<user>
    $cuerpoxml
</user>
XML
    return $xml;
}