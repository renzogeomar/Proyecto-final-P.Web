#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use Encode qw(decode);

my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');

# Obtener parámetros del formulario
my $title = decode('UTF-8', $q->param('title') || '');
my $text = decode('UTF-8', $q->param('text') || '');
my $owner = decode('UTF-8', $q->param('owner') || '');
my $session_id = decode('UTF-8', $q->param('session_id') || '');  # Obtener el session_id

# Imprime los valores recibidos para debug
print STDERR "Valores recibidos - Title: '$title', Text: '$text', Owner: '$owner', Session ID: '$session_id'\n";

# Verificar si el session_id es válido
if (!defined($session_id) || !is_valid_session($session_id)) {
    print STDERR "Sesión no válida.\n";
    print renderXML("<message>Sesión no válida</message>");
    exit;
}

# Almacenar los parámetros en un array para validarlos
my @parametros = ($title, $text, $owner);

# Array para almacenar la salida
my @salida;

# Verificar que todos los parámetros están definidos y no sean solo espacios
if (validarArray(@parametros) == 3) {
    # Intentar insertar en la base de datos
    insertaBD(@parametros);
    
    # Buscar los datos insertados en la base de datos
    if (my @consulta = buscarBD(@parametros)) {
        @salida = @consulta;
        my $cuerpoXML = renderCuerpo(@salida);
        print renderXML($cuerpoXML);
        print STDERR "Datos encontrados: @consulta\n";
    } else {
        print STDERR "No se insertaron los datos correctamente.\n";
        print renderXML("<message>No se encontraron artículos</message>");
    }
} else {
    print STDERR "Faltan campos\n";
    print renderXML("<message>Faltan datos en el formulario</message>");
}

# Función para validar si el session_id es válido
sub is_valid_session {
    my $session_id = $_[0];

    # Aquí deberías implementar la lógica para verificar si el session_id es válido
    # Por ejemplo, consultando si el session_id está asociado a un usuario válido en la base de datos
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

# Función para insertar los datos en la base de datos
sub insertaBD {
    my @campos = @_;
    my $user = 'alumno';
    my $password = 'pweb1';
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306';  # Cambiar host=192.168.1.5 por 'db' en Docker

    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar a la base de datos: $DBI::errstr\n");

    my $sql = "INSERT INTO Articles (title, owner, text) VALUES(?, ?, ?)";
    my $sth = $dbh->prepare($sql);
    $sth->execute($campos[0], $campos[2], $campos[1]);

    $sth->finish;
    $dbh->disconnect;
}

# Función para buscar los datos en la base de datos
sub buscarBD {
    my @campos = @_;
    my $user = 'alumno';
    my $password = 'pweb1';
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306'; 

    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar a la base de datos: $DBI::errstr\n");

    my $sql = "SELECT title, text FROM Articles WHERE title=? AND owner=? AND text=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($campos[0], $campos[2], $campos[1]);

    my @row = $sth->fetchrow_array;

    $sth->finish;
    $dbh->disconnect;
    return @row;
}

# Función para generar el XML de respuesta
sub renderXML {
    my $cuerpoxml = $_[0];
    my $xml = <<"XML";
<?xml version="1.0" encoding="utf-8"?>
    <article>
        $cuerpoxml
    </article>
XML
    return $xml;
}

# Función para generar el cuerpo del XML
sub renderCuerpo {
    my @linea = @_;
    my $cuerpo = <<"CUERPO";
    <title>$linea[0]</title>
    <text>$linea[1]</text>
CUERPO
    return $cuerpo;
}

# Función para validar que todos los campos están definidos y no sean solo espacios
sub validarArray {
    my @array = @_;
    my $contador = 0;
    foreach my $elemento (@array) {
        if (defined($elemento) && $elemento =~ /\S/) { # \S verifica que no sea solo espacios
            $contador++;
        }
    }
    return $contador;
}