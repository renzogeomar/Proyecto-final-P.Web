#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Session;

my $q = CGI->new;

# Recuperar la sesión
my $session = CGI::Session->load();

# Verificar si la sesión es válida
if ($session) {
    my $user_data = $session->param('user_data');
    if ($user_data) {
        print $q->header('text/xml;charset=UTF-8');
        print renderXML($user_data);
    } else {
        print $q->header('text/xml;charset=UTF-8');
        print renderXML('<message>No hay datos de usuario en la sesión</message>');
    }
} else {
    print $q->header('text/xml;charset=UTF-8');
    print renderXML('<message>No se ha iniciado sesión o la sesión ha expirado</message>');
}

sub renderXML {
    my $cuerpoxml = $_[0];
    my $xml = <<"XML";
<?xml version='1.0' encoding='UTF-8'?>
<session>
    $cuerpoxml
</session>
XML
    return $xml;
}