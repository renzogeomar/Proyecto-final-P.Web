#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use HTML::Entities;  # Para manejar caracteres especiales

my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');

# Obtener parámetros del formulario
my $title = $q->param('title');
my $text = $q->param('text');
my $owner = $q->param('owner');

# Depuración: Ver los valores recibidos antes de cualquier modificación
print STDERR "Valores recibidos antes de modificación - Title: '$title', Text: '$text', Owner: '$owner'\n";

# Si alguno de los parámetros está vacío, mostrar el error y salir
if (!defined($title) || $title eq '' || !defined($text) || $text eq '' || !defined($owner) || $owner eq '') {
    print STDERR "Faltan campos\n";
    print renderXML("<message>Faltan datos en el formulario</message>");
    exit;
}

# No escapar los caracteres aquí antes de actualizar
# $title = encode_entities($title);  
# $text = encode_entities($text);  

# Depuración: Ver los valores después de escaparlos
print STDERR "Valores antes de la actualización - Title: '$title', Text: '$text', Owner: '$owner'\n";

# Almacenar los parámetros en un array para validarlos
my @parametros = ($title, $text, $owner);

# Array para almacenar la salida
my @salida;

# Verificar que todos los parámetros están definidos
if (validarArray(@parametros) == 3) {
    print STDERR "Los datos están completos\n";  # Agregado para depuración

    # Intentar actualizar en la base de datos
    if (actualizaBD(@parametros)) {
        # Buscar los datos actualizados en la base de datos
        if (my @consulta = buscarBD(@parametros)) {
            @salida = @consulta;
            my $cuerpoXML = renderCuerpo(@salida);
            print renderXML($cuerpoXML);
            print STDERR "Datos encontrados: @consulta\n";
        } else {
            print STDERR "No se encontraron los datos correctamente.\n";
            print renderXML("<message>No se encontraron artículos</message>");
        }
    } else {
        print STDERR "Error al actualizar los datos.\n";
        print renderXML("<message>Error en la actualización</message>");
    }
} else {
    print STDERR "Faltan campos\n";  # Mejorar la depuración aquí
    print renderXML("<message>Faltan datos en el formulario</message>");
}

# Función para actualizar los datos en la base de datos
sub actualizaBD {
    my @campos = @_;
    my $user = 'alumno';
    my $password = 'pweb1';
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306';  

    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or do {
            print STDERR "No se pudo conectar a la base de datos: $DBI::errstr\n";
            return 0;
        };

    # Cambiar INSERT a UPDATE
    my $sql = "UPDATE Articles SET text = ? WHERE title = ? AND owner = ?";
    my $sth = $dbh->prepare($sql);

    # Intentar ejecutar la actualización
    eval {
        $sth->execute($campos[1], $campos[0], $campos[2]);
    };

    if ($@) {
        print STDERR "Error al actualizar datos: $@\n";
        $sth->finish;
        $dbh->disconnect;
        return 0;
    }

    $sth->finish;
    $dbh->disconnect;
    return 1;  # Si todo salió bien, retorna 1
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

# Función para validar que todos los campos están definidos
sub validarArray {
    my @array = @_;
    my $contador = 0;
    foreach my $elemento (@array) {
        if (defined($elemento) && $elemento ne '') {
            $contador++;
        }
    }
    return $contador;
}