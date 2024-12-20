#!/usr/bin/perl
use strict;
use warnings;
use CGI;
my $q = CGI->new;
print $q->header('text/html');
print "Content-type: text/html\n\n";
print "<html><body><h1>Mi nuevo script Perl</h1></body></html>";