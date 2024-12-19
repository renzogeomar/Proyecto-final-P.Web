-- Crear la base de datos pweb1 si no existe
CREATE DATABASE IF NOT EXISTS pweb1;

-- Usar la base de datos pweb1
USE pweb1;

-- Crear la tabla usuarios si no existe
CREATE TABLE IF NOT EXISTS usuarios (
    userName VARCHAR(50) NOT NULL PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    firstName VARCHAR(50),
    lastName VARCHAR(50)
);

-- Insertar datos de ejemplo en la tabla usuarios
INSERT INTO usuarios (userName, password, firstName, lastName)
VALUES
('testuser', '12345', 'Test', 'User'),
('admin', 'adminpass', 'Admin', 'User');

-- Crear la tabla articles
CREATE TABLE IF NOT EXISTS Articles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    owner VARCHAR(50) NOT NULL,
    text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar datos de ejemplo en la tabla Articles
INSERT INTO Articles (title, owner, text)
VALUES
('First Article', 'testuser', 'This is the first article text.'),
('Second Article', 'admin', 'This is the second article text.');

-- Otorgar permisos al usuario 'alumno'
GRANT SELECT, INSERT, UPDATE, DELETE ON pweb1.* TO 'alumno'@'%' IDENTIFIED BY 'pweb1';

-- Otorgar todos los privilegios al usuario 'alumno' para la base de datos pweb1
GRANT ALL PRIVILEGES ON pweb1.* TO 'alumno'@'%' IDENTIFIED BY 'pweb1';

-- Aplicar los cambios de permisos
FLUSH PRIVILEGES;