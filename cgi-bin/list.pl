#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use CGI::Session;

my $q = CGI->new;
print $q->header('text/xml; charset=UTF-8');

# Obtener el parámetro 'owner' del formulario
my $owner = $q->param('owner');
my $session_id = $q->param('session_id');
print STDERR "$owner\n";

# Verificar si el session_id es válido
if (!defined($session_id) || !is_valid_session($session_id)) {
    print renderXML("<message>Sesión no válida</message>");
    exit;
}

if (defined($owner)) {
    # Buscar artículos en la base de datos
    my @articles = buscarBD($owner);
    
    if (@articles) {
        print STDERR "@articles\n";  # Imprimir los artículos encontrados para depuración
        
        # Generar el cuerpo XML con los artículos
        my $articlesXML = renderCuerpo($owner, @articles);
        
        print STDERR "$articlesXML\n";  # Imprimir el XML generado para depuración
        
        # Imprimir el XML final
        print renderXML($articlesXML);
    } else {
        print STDERR "No se encontró dicho dato\n";
        print renderXML("<message>No se encontraron artículos para este propietario.</message>");
    }
} else {
    print STDERR "No se ingresaron datos\n";
    print renderXML("<message>Faltan datos</message>");
}

sub is_valid_session {
    my $session_id = $_[0];

    # Aquí deberías implementar la lógica para verificar si el session_id existe en la base de datos
    # Por ejemplo, consultando si el session_id está asociado a un usuario válido

    my $dsn = 'DBI:mysql:database=pweb1;host=db;port=3306';
    my $dbh = DBI->connect($dsn, 'alumno', 'pweb1', { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar a la base de datos: $DBI::errstr\n");

    # Verificar si el session_id existe en la base de datos
    my $sql = "SELECT session_id FROM usuarios WHERE session_id = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($session_id);

    my $result = $sth->fetchrow_array();
    $sth->finish;
    $dbh->disconnect;

    return defined($result);  # Devuelve true si el session_id es válido, false en caso contrario
}


# Función para buscar artículos en la base de datos
sub buscarBD {
    my $owner = $_[0];
    
    # Datos de conexión
    my $user = 'alumno';
    my $password = 'pweb1';
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306';  # Usar 'db' como host en Docker Compose
    
    # Conectar a la base de datos
    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar a la base de datos: $DBI::errstr\n");
    
    # Consulta SQL para buscar los títulos de artículos
    my $sql = "SELECT title FROM Articles WHERE owner=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($owner);
    
    # Almacenar los títulos de artículos en un arreglo
    my @articles;
    while (my @row = $sth->fetchrow_array) {
        push(@articles, $row[0]);  # Solo almacenar el título
    }

    # Finalizar la consulta y desconectar
    $sth->finish;
    $dbh->disconnect;
    
    return @articles;
}

# Función para generar el cuerpo del XML
sub renderCuerpo {
    my $owner = shift;  # El primer parámetro es el propietario
    my @titulos = @_;   # Los artículos son los siguientes parámetros
    my $len = @titulos;
    my $lista = "";
    
    # Generar un bloque XML para cada artículo
    for (my $i = 0; $i < $len; $i++) {
        $lista .= <<"CUERPO";
<article>
    <owner>$owner</owner>
    <title>$titulos[$i]</title>
</article>
CUERPO
    }
    
    return $lista;
}

# Función para generar el XML completo
sub renderXML {
    my $cuerpoxml = $_[0];
    my $xml = <<"XML";
<?xml version='1.0' encoding='UTF-8'?>  
   <articles>
   $cuerpoxml
   </articles>
XML
    return $xml;
}