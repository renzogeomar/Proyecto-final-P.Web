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
        print STDERR "Enviando datos correctos al XML\n";
        my $session_id = startSession(@respuesta);
        #my $cuerpoXML = renderCuerpo(@respuesta);
        print renderXML($respuesta, $session_id);
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

sub startSession {
    my @user_data = @_;
    my $session = CGI::Session->new("driver:File", undef, { Directory => '/tmp' })
        or die "No se pudo crear la sesión: $!";

    $session->param('user_data', \@user_data);
    return $session->id;
}

sub renderXML {
    my ($linea_ref, $session_id) = @_;
    my @linea = @{$linea_ref};
    my $cuerpoxml = <<"CUERPO";
    <user>
        <owner>$linea[0]</owner>
        <firstName>$linea[2]</firstName>
        <lastName>$linea[3]</lastName>
        <sessionId>$session_id</sessionId>
    </user>
CUERPO
    return $cuerpoxml;
}

#sub renderCuerpo {
#    my @linea = @_;
#   my $cuerpo = <<"CUERPO";
#    <owner>$linea[0]</owner>
#    <firstName>$linea[2]</firstName>
#    <lastName>$linea[3]</lastName>
#CUERPO
#    return $cuerpo;
#}

#sub renderXML {
#    my $cuerpoxml = $_[0];
#    my $xml = <<"XML";
#<?xml version='1.0' encoding='UTF-8'?>
#<user>
#    $cuerpoxml
#</user>
#XML
#    return $xml;
#}