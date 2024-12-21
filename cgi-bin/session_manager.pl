#!/usr/bin/perl -w
use strict;
use warnings;
use CGI;

my $q = CGI->new;

#print $q->header('text/plain');  # Encabezado adecuado para CGI

print $q->header('text/html; charset=UTF-8');
    print "<html lang=\"es\"><head><title>Error</title><link rel=\"stylesheet\" href=\"style.css\"></head><body>";
    print "<h1>Error: Título o contenido vacío.</h1>";
    print "<a href='/new.html'>Regresar</a>";
    print "</body></html>";

# Lógica de manejo de sesión
# Aquí deberías cerrar la sesión, eliminar el session_id de la base de datos, etc.

print "Sesion cerrada correctamente";  # Mensaje que será retornado al navegador