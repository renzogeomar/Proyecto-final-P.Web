#!/usr/bin/perl
use CGI;

my $q = CGI->new;

print $q->header('text/plain');
print "Hola desde Perl CGI!";