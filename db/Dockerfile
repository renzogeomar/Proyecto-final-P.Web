FROM mariadb:latest

ENV MYSQL_ROOT_PASSWORD=pweb1
ENV MYSQL_DATABASE=pweb1
ENV MYSQL_USER=alumno
ENV MYSQL_PASSWORD=pweb1

RUN apt-get update && apt-get install -y mariadb-client


# Copiar archivo SQL de inicialización
COPY ./init.sql /docker-entrypoint-initdb.d/
RUN chmod 644 /docker-entrypoint-initdb.d/init.sql