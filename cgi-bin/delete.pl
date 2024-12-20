#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml; charset=UTF-8');

# Obtener los parámetros 'owner' y 'title' del formulario
my $owner = $q->param('owner');
my $title = $q->param('title');
my $session_id = $q->param('session_id');

print STDERR "$owner.$title.$session_id\n";  # Depuración: Imprimir los valores

# Verificar si el session_id es válido
if (!defined($session_id) || !is_valid_session($session_id)) {
    print renderXML("<message>Sesión no válida</message>");
    exit;
}

if (defined($owner) and defined($title)) {
    print STDERR "Campos llenos\n";
    
    # Buscar en la base de datos
    my @articles = buscarBD($owner, $title);
    
    # Si se encontraron artículos, proceder a eliminar
    if (@articles) {
        print STDERR "Se borra @articles\n";
        my $renderCuerpo = renderCuerpo($owner, $title);
        print renderXML($renderCuerpo);
        
        # Eliminar artículo de la base de datos
        eliminarBD($owner, $title);
    } else {
        print STDERR "No existe ese artículo\n";
        print renderXML("<message>No se encontró el artículo</message>");
    }
} else {
    print STDERR "Campos vacíos\n";
    print renderXML("<message>Faltan datos</message>");
}

# Función para verificar si el session_id es válido
sub is_valid_session {
    my $session_id = $_[0];

    # Lógica para verificar el session_id en la base de datos
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

# Función para buscar en la base de datos
sub buscarBD {
    my ($owner, $title) = @_;
    
    # Datos de conexión
    my $user = 'alumno';
    my $password = 'pweb1';
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306';  # Usar 'db' como host en Docker Compose
    
    # Conectar a la base de datos
    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar a la base de datos: $DBI::errstr\n");
    
    # Consulta SQL para buscar el artículo
    my $sql = "SELECT title FROM Articles WHERE owner=? AND title=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($owner, $title);
    
    # Almacenar los resultados de la consulta
    my @articles;
    while (my @row = $sth->fetchrow_array) {
        push(@articles, @row);
    }

    # Finalizar la consulta y desconectar
    $sth->finish;
    $dbh->disconnect;
    
    return @articles;
}

# Función para eliminar el artículo de la base de datos
sub eliminarBD {
    my ($owner, $title) = @_;
    
    # Datos de conexión
    my $user = 'alumno';
    my $password = 'pweb1';
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306';  # Usar 'db' como host en Docker Compose
    
    # Conectar a la base de datos
    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar a la base de datos: $DBI::errstr\n");
    
    # Consulta SQL para eliminar el artículo
    my $sql = "DELETE FROM Articles WHERE owner=? AND title=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($owner, $title);
    
    # Finalizar la consulta y desconectar
    $sth->finish;
    $dbh->disconnect;
}

# Función para renderizar el cuerpo del XML
sub renderCuerpo {
    my ($owner, $title) = @_;
    my $cuerpo = <<"CUERPO";
            <owner>$owner</owner>
            <title>$title</title>
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
