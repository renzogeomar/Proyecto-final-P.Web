#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;
use CGI::Carp qw(fatalsToBrowser);
#use CGI::Session;

my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');
print STDERR "conexion exitosa";

