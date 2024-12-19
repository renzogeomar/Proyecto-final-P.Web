# Usa una imagen base de Ubuntu
FROM ubuntu:22.04

# Actualizar e instalar dependencias necesarias
RUN apt-get update && apt-get upgrade -y && DEBIAN_FRONTEND="noninteractive" apt-get install -y \
    apache2 \
    perl \
    mariadb-client \
    libdbi-perl \
    libcgi-pm-perl \
    make \
    gcc \
    libmariadb-dev \
    cpanminus \
    libapache2-mod-perl2 \
    libapache2-mod-fcgid \
    libcgi-session-perl \
    curl \
    nano \
    apache2-utils \
    apparmor-utils \
    && rm -rf /var/lib/apt/lists/* \
    && cpanm --notest DBD::MariaDB \
    && cpanm --notest Text::Markdown \
    && a2enmod cgid
    
# Configuración de Apache con ajustes para CGI
RUN echo '<VirtualHost *:80>\n\
    ServerName localhost\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html\n\
    ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/\n\
    <Directory "/usr/lib/cgi-bin">\n\
        Options +ExecCGI\n\
        AddHandler cgi-script .pl\n\
        Require all granted\n\
    </Directory>\n\
    <Directory "/var/www/html">\n\
        AllowOverride All\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Agregar después de la configuración del VirtualHost
RUN echo '<FilesMatch "\.(js|css|html)$">\n\
    Header set Cache-Control "no-cache, no-store, must-revalidate"\n\
    Header set Pragma "no-cache"\n\
    Header set Expires 0\n\
</FilesMatch>' >> /etc/apache2/apache2.conf
RUN echo 'Header set Access-Control-Allow-Origin "*"' >> /etc/apache2/apache2.conf
# Habilitar el módulo headers
RUN a2enmod headers

# Copiar archivos del proyecto
COPY ./cgi-bin/ /usr/lib/cgi-bin/
COPY ./*.html /var/www/html/
COPY ./css /var/www/html/css
COPY ./js /var/www/html/js

# Asegurar permisos correctos para scripts CGI y directorios
RUN chmod -R 755 /usr/lib/cgi-bin && \
    chmod +x /usr/lib/cgi-bin/*.pl && \
    chown -R www-data:www-data /usr/lib/cgi-bin && \
    chown -R www-data:www-data /var/www/html

# Configurar AppArmor para permitir la ejecución de scripts CGI
RUN ln -s /bin/true /etc/apparmor.d/usr.sbin.apache2

# Comando adicional para listar permisos (solo para depuración)
RUN ls -l /usr/lib/cgi-bin && ls -l /var/www/html
RUN echo "AddType application/javascript .js" >> /etc/apache2/apache2.conf

# Exponer el puerto de Apache
EXPOSE 80

# Iniciar Apache en primer plano cuando el contenedor se ejecute
CMD ["apache2ctl", "-D", "FOREGROUND"]