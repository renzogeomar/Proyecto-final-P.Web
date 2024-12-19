#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml; charset=UTF-8');

# Obtener el parámetro 'owner' del formulario
my $owner = $q->param('owner');
print STDERR "$owner\n";

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