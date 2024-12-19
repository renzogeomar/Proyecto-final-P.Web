#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use URI::Escape;  # Para poder usar uri_unescape

# Crear el objeto CGI
my $q = CGI->new;
# Modificar la cabecera para que la respuesta sea de tipo HTML
print $q->header('text/html; charset=UTF-8');

# Obtener los parámetros 'owner' y 'title'
my $owner = $q->param('owner');
my $title = $q->param('title');

# Decodificar los parámetros para manejar caracteres especiales
$owner = uri_unescape($owner);
$title = uri_unescape($title);

# Mostrar valores de los parámetros para depuración
print STDERR "Owner: $owner, Title: $title\n";

my @articlesTex;

# Verificar que ambos parámetros estén definidos
if (defined($owner) and defined($title)) {
    print STDERR "Se ingresaron todos los campos requeridos\n";
    # Buscar el artículo en la base de datos
    @articlesTex = buscarBD($owner, $title);
    print STDERR "@articlesTex\n";
    print STDERR "Tamaño de salida de BD: " . scalar(@articlesTex) . "\n";

    if (@articlesTex) {
        print STDERR "Se encontró su texto\n";
        print STDERR "Este es el texto a cambiar: @articlesTex\n";
        
        # Procesar el título (que también está en Markdown)
        my $title_html = interpretar_title($title);

        # Mostrar el título
        print "<h1>$title_html</h1>";

        # Dividir el texto obtenido en líneas
        my @lineasArticles = split(/\s*\n\s*/, $articlesTex[0]);
        print "  ";
        # Interpretar las líneas y generar el HTML
        print interpretar(@lineasArticles);
    } else {
        print STDERR "No se encontró su texto, revise sus datos\n";
        # Generar respuesta XML si no se encuentra el artículo
        print renderXML("<message>No se encontraron artículos</message>");
    }
} else {
    print STDERR "No se llenaron todos los campos\n";
    # Generar respuesta XML si faltan parámetros
    print renderXML("<message>Faltan datos en el formulario</message>");
}

# Función para interpretar el título (Markdown a HTML)
sub interpretar_title {
    my $title = $_[0];
    my $lineaHTML;

    # Convertir encabezado Markdown a HTML
    if ($title =~ /^(#{1,6})\s*(.*)/) {
        my $level = length($1);  # Número de # determina el nivel del encabezado
        my $titulo = $2;
        $lineaHTML = "<h$level>$titulo</h$level>";
    }
    return $lineaHTML;
}

# Función para interpretar las líneas de Markdown y convertirlas a HTML
sub interpretar {
    my @lineas = @_;
    my $len = @lineas;
    my @lineasHTML;

    for (my $i = 0; $i < $len; $i++) {
        my $linea = $lineas[$i];
        my $lineaHTML;

        # Convertir encabezados Markdown a HTML (los encabezados pueden tener de 1 a 6 #)
        if ($linea =~ /^(#{1,6})\s*(.*)/) {
            my $level = length($1);  # Número de # determina el nivel del encabezado
            my $titulo = $2;
            $lineaHTML = "<h$level>$titulo</h$level>";
            push(@lineasHTML, $lineaHTML);
        }

        # Convertir texto en negrita y cursiva (Markdown: **texto** o *texto*)
        elsif ($linea =~ /\*\*(.*?)\*\*/) {
            $lineaHTML = "<strong>$1</strong>";
            push(@lineasHTML, $lineaHTML);
        }
        elsif ($linea =~ /\*(.*?)\*/) {
            $lineaHTML = "<em>$1</em>";
            push(@lineasHTML, $lineaHTML);
        }

        # Convertir enlaces Markdown a HTML (Markdown: [texto](url))
        elsif ($linea =~ /\[([^\]]+)\]\(([^\)]+)\)/) {
            my $link_text = $1;
            my $link_url = $2;
            $lineaHTML = "<a href=\"$link_url\">$link_text</a>";
            push(@lineasHTML, $lineaHTML);
        }

        # Convertir listas no ordenadas Markdown (Markdown: - item)
        elsif ($linea =~ /^\-\s+(.*)/) {
            $lineaHTML = "<ul><li>$1</li></ul>";
            push(@lineasHTML, $lineaHTML);
        }

        # Convertir listas ordenadas Markdown (Markdown: 1. item)
        elsif ($linea =~ /^\d+\.\s+(.*)/) {
            $lineaHTML = "<ol><li>$1</li></ol>";
            push(@lineasHTML, $lineaHTML);
        }

        # Si no coincide con ningún patrón Markdown, se pone el texto tal cual
        else {
            $lineaHTML = "<p>$linea</p>";
            push(@lineasHTML, $lineaHTML);
        }
    }
    return join("\n", @lineasHTML);  # Convertir el array en una cadena de texto HTML
}

# Función para realizar la búsqueda en la base de datos
sub buscarBD {
    my $owner = $_[0];
    my $title = $_[1];
    my $user = 'alumno';
    my $password = 'pweb1';
    my $dsn = 'DBI:MariaDB:database=pweb1;host=db;port=3306';  # Ajusta la IP/host según tu configuración

    # Conectar a la base de datos
    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar: $DBI::errstr");

    # Realizar la consulta para obtener el texto del artículo
    my $sql = "SELECT text FROM Articles WHERE owner=? AND title=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($owner, $title);

    my @textArticles;
    while (my @row = $sth->fetchrow_array) {
        push(@textArticles, $row[0]);
    }

    $sth->finish;
    $dbh->disconnect;

    return @textArticles;
}

# Función para generar el XML de respuesta
sub renderXML {
    my $cuerpoxml = $_[0];
    my $xml = <<"XML";
<?xml version="1.0" encoding="utf-8"?>
    <response>
        $cuerpoxml
    </response>
XML
    return $xml;
}