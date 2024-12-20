#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

# Crear el objeto CGI y preparar la cabecera de la respuesta XML
my $q = CGI->new;
print $q->header('text/xml; charset= UTF-8');

# Obtener los parámetros del formulario (owner y title)
my $owner = $q->param('owner');
my $title = $q->param('title');
my $session_id = $q->param('session_id');  # Nuevo parámetro session_id

# Validar el session_id
if (defined($session_id) && !es_session_valida($session_id, $owner)) {
    print STDERR "Sesión inválida o expiró\n";
    print renderXML("<message>Sesión inválida o expiró</message>");
    exit;
}

# Depuración: Imprimir los valores recibidos
print STDERR "$owner.$title\n";

my @consulta;

# Verificar que los campos estén completos
if (defined($owner) and defined($title)) {
    print STDERR "Los datos están completos\n";
    
    # Buscar en la base de datos
    @consulta = buscarBD($owner, $title);
    print STDERR "@consulta\n";
    
    if (@consulta) {
        print STDERR "Se encontró el artículo\n";
        print STDERR "@consulta\n";
        
        # Agregar el título y el owner a la consulta
        push(@consulta, $title);
        push(@consulta, $owner);
        
        print STDERR "@consulta\n";
        
        # Generar el cuerpo del XML
        my $cuerpoXML = renderCuerpo(@consulta);
        print renderXML($cuerpoXML);
    } else {
        print STDERR "No se encontró el artículo\n";
        print renderXML("<message>No se encontró el artículo</message>");
    }

} else {
    print STDERR "No están completos los campos\n";
    print renderXML("<message>Faltan datos</message>");
}

sub es_session_valida {
    my ($session_id, $owner) = @_;
    
    my $user = 'alumno';
    my $password = 'pweb1';
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306';

    # Conectar a la base de datos
    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar: $DBI::errstr");

    # Verificar si existe el session_id para el owner
    my $sql = "SELECT session_id FROM usuarios WHERE session_id = ? AND userName = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($session_id, $owner);

    # Si se encuentra el session_id, es válido
    my $valid_session = $sth->fetchrow_array;
    
    $sth->finish;
    $dbh->disconnect;

    return defined($valid_session);  # Retorna verdadero si se encuentra el session_id
}

# Función para buscar en la base de datos
sub buscarBD {
    my ($owner, $title) = @_;
    
    # Datos de conexión
    my $user = 'alumno';
    my $password = 'pweb1';
    
    # Cambiar 'host=192.168.1.5' a 'host=db' (nombre del contenedor en Docker)
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306';  
    
    # Conectar a la base de datos
    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar: $DBI::errstr\n");
    
    # Preparar la consulta SQL
    my $sql = "SELECT text FROM Articles WHERE owner=? AND title=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($owner, $title);
    
    # Almacenar los resultados de la consulta
    my @textArticles;
    while (my @row = $sth->fetchrow_array) {
        push(@textArticles, @row);
    }

    # Finalizar la consulta y desconectar
    $sth->finish;
    $dbh->disconnect;
    
    return @textArticles;
}

# Función para renderizar el cuerpo del XML
sub renderCuerpo {
    my ($text, $title, $owner) = @_;  # Asegurarse de que el orden sea correcto
    my $cuerpo = <<"CUERPO";
    <owner>$owner</owner>
    <title>$title</title>
    <text>$text</text>
CUERPO
    return $cuerpo;
}

# Función para renderizar el XML completo
sub renderXML {
    my $cuerpoxml = $_[0];
    my $xml = <<"XML";
<?xml version='1.0' encoding='UTF-8'?>
<article>
    $cuerpoxml
</article>
XML
    return $xml;
}