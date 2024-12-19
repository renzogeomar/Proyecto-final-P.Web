#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Session;

# Crear el objeto CGI
my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');

my $session_id = $q->param('session_id');
my $action = $q->param('action');

if ($session_id) {
    my $session = CGI::Session->load($session_id, { Directory => '/tmp' });
    
    if ($session) {
        if ($action eq 'verifySession') {
            # Verificación de sesión
            print renderXML('<message>Sesión válida</message>');
        } else {
            # Manejo de otras acciones como cerrar sesión, actualizar datos, etc.
        }
    } else {
        print renderXML('<message>Sesión no válida o caducada</message>');
    }
} else {
    print renderXML('<message>Falta el session_id</message>');
}

sub renderXML {
    my $message = $_[0];
    my $xml = <<"XML";
<?xml version='1.0' encoding='UTF-8'?>
<response>
    $message
</response>
XML
    return $xml;
}