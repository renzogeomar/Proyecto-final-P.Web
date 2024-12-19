#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

# Inicializa el objeto CGI y prepara la cabecera de la respuesta
my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');

# Obtén los parámetros del formulario
my $userName = $q->param('userName');
my $password = $q->param('password');
my $firstName = $q->param('firstName');
my $lastName = $q->param('lastName');

# Se almacenan los parámetros en un array
my @parametros;
push(@parametros, $userName);
push(@parametros, $password);
push(@parametros, $firstName);
push(@parametros, $lastName);

# Validar si todos los parámetros fueron definidos
print STDERR length($userName);

my $len = scalar(@parametros);

# Realizar la validación y la inserción en la base de datos si es necesario
my @salida;
if (validarArray(@parametros) == 4) {
    insertaBD(@parametros);
    @salida = @parametros;
    my $cuerpoXML = renderCuerpo(@salida);
    print renderXML($cuerpoXML);
} else {
    print renderXML('<message>Faltan datos</message>');
}

# Función para insertar los datos en la base de datos
sub insertaBD {
    my @campos = @_;
    
    # Datos de conexión a la base de datos
    my $user = 'alumno';
    my $password = 'pweb1';
    
    # Cambiar el host a 'db' (nombre del contenedor de la base de datos) en vez de la IP
    my $dsn = 'DBI:mysql:database=pweb1;host=db;port=3306';  # Asegúrate de que 'db' sea el nombre correcto del servicio
    my $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 })
        or die("No se pudo conectar a la base de datos: $DBI::errstr\n");
    
    # Preparar la consulta SQL para insertar los datos
    my $sql = "INSERT INTO usuarios(userName, password, firstName, lastName) VALUES(?, ?, ?, ?)";
    
    # Ejecutar la consulta
    my $sth = $dbh->prepare($sql);
    $sth->execute($campos[0], $campos[1], $campos[2], $campos[3])
        or die("Error al insertar datos: $sth->errstr");
    
    # Finalizar la consulta y desconectar de la base de datos
    $sth->finish;
    $dbh->disconnect;
}

# Función para generar el cuerpo del XML con los datos del usuario
sub renderCuerpo {
    my @linea = @_;
    my $cuerpo = <<"CUERPO";
    <owner>$linea[0]</owner>
    <firstName>$linea[2]</firstName>
    <lastName>$linea[3]</lastName>
CUERPO
    return $cuerpo;
}

# Función para generar el XML completo
sub renderXML {
    my $cuerpoxml = $_[0];
    my $xml = <<"XML";
<?xml version='1.0' encoding='UTF-8'?>
<user>
    $cuerpoxml
</user>
XML
    return $xml;
}

# Función para validar que todos los parámetros estén definidos
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
