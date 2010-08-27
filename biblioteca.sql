/* 

EJERCICIO DE PRACTICA PARA PROGRAMACION 3

PROFESOR SERGIO ALONSO - sergio@eim.esc.edu.ar


Esta base tiene como proposito armar un pequeño sistema en Java

Bibliografia: http://conclase.net/mysql/curso/?cap=007#007_creartabla

Instrucciones comprobadas en Ubuntu 10.4 "Lucid" / LinuxMint 9 "Isadora" y
MySQL 5.1.41

Compruebe su configuracion mediante cat /etc/lsb-release y mysql --version

Instrucciones: 
1) Utilizando un editor que soporte coloreado de SQL, transcriba 
   LINEA A LINEA las siguientes instrucciones en un archivo, por ejemplo, 
   "practica_biblioteca.sql"

2) Despues de cada línea terminadas en ; INYECTE (<) su archivo sql sobre el 
   motor MySQL, utilizando el cliente de MSDOS / Terminal Linux, con 
   alguna órden equivalente a

          mysql -c -vvv -u root -ppadawan < practica_biblioteca.sql | more

   Comentarios: 
   -ppadawan es la instruccion para enviar la contraseña padawan en la misma linea
   -c y -vvv son utiles solo en modo batch, en el que serializamos varias órdenes
     Por cierto, -c funciona sobre mysql 5.1.41 (mysql --version)
   | more sirve para pausar en pantalla la salida. En linux puede usar | less, que
     permite retroceder pantallas (PgUp) y Buscar (/)

   Si desea tomar el control del cliente usted mismo e ir inyectando las ordenes
   de esa manera, utilice simplemente el comando 

          mysql -u root -p

3) Observe errores, corrija el archivo practica_biblioteca, y repita.


IMPORTANTE
Este es un metodo primitivo pero recomendado por los buenos DBAs para 
recordar instrucciones. Recuerde que mas adelante tarde deberemos disparar 
estas instrucciones desde Java, que ya es bastante complicado.

Una vez que ENTIENDA estas lineas podrá usar los clientes mysql para 
usuarios medianamente avanzados. Se los enumero aquí, pero TRATE DE NO 
USARLOS TODAVIA.

Windows: 
a) MySQL WorkBench: con generador de diagramas ER, inestable
b) Heidy SQL
c) phpmyadmin, necesita XAMPP o similar

Linux
a) MySQL Query Browser: paquete mysql-query-browser (via apt-get)
b) Heidy SQL, se baja de la pagina web la version Windows y se corre con 
   wine, paquete wine (vía apt-get)
c) MySQL WorkBench: con generador de diagramas ER, muy inestable, paquete
   mysql-workbench (via apt-get)
d) phpmyadmin: paquetes lamp-server (vía sudo tasksel) y phpmyadmin (via 
   apt-get), e instrucciones de instalacion en el manual 
   www.bunker.org.ar/incubadora/redes.pdf (use Ctrl + F si se pierde)

========================================================================
        LAS SIGUIENTES LINEAS TRANSCRIBALAS "A MANO" A OTRO ARCHIVO, 
        SIN USAR COPIAR / PEGAR: NO SE AUTOLESIONE COMO PROGRAMADOR
        LE PROMETO QUE EN UNAS CLASES UTILIZAREMOS INCREIBLES Y
        EMOCIONANTES ATAJOS
========================================================================
*/

-- Veo que bases de datos se encuentra gestionando el motor
SHOW DATABASES;

-- Borro la base anterior <biblioteca>
DROP DATABASE IF EXISTS biblioteca;

-- La vuelvo a crear en limpio
CREATE DATABASE biblioteca;

-- Me meto adentro
USE biblioteca;


-- Fabrico una tabla para autores.
CREATE TABLE autores (
    -- No se permite ingresar registros sin apellido o nombre (nulos)
    nombre VARCHAR(25) NOT NULL,
    apellido VARCHAR(25) NOT NULL,

    -- edad no es tan importante en este contexto. 
    edad INT(2) NULL,

    -- Si el operador no ingresa email, situaremos un valor por defecto
    email VARCHAR(100) NULL DEFAULT 'no tiene',

    -- Creamos un indice llamado id, que logicamente no puede ser nulo
    id INT(4) NOT NULL 
       PRIMARY KEY

       -- Los indices no deberían estar repetidos. Deberían ser unicos.
       UNIQUE

       -- De paso, le activamos el autincremento, para programar mas cómodamente
       -- Este valor solo funciona en campos INT
       AUTO_INCREMENT

) ENGINE = InnoDB;



-- La fabriqué bien? veamos...
SHOW tables;

-- Reviso la estructura...
DESCRIBE autores;

-- Inserto algunos datos..
INSERT INTO `autores` (`id`,`nombre`,`apellido`,`edad`,`email`) VALUES (NULL,'Jose','Hernandez',33,'martin@fierro.org.ar');
INSERT INTO `autores` (`id`,`nombre`,`apellido`,`edad`,`email`) VALUES (NULL,'Ernesto','Sabato',78,NULL);

-- Reviso lo que inserté
SELECT * FROM autores;







-- =========== CLAVES AJENAS, Y EJEMPLO CON RELACION 1 a MUCHOS =============



-- Creamos una tabla telefonos, relacionada como 1 a m respecto de autores
-- Usando de ejemplo http://library.pantek.com/Applications/MySQL/doc/refman/5.0/es/innodb-foreign-key-constraints.html
CREATE TABLE telefonos (
        id INT(5) NOT NULL AUTO_INCREMENT PRIMARY KEY UNIQUE,
        telefono VARCHAR(25),

        -- Creamos un campo con la misma dimensión (4) del id de autores
        autor_id INT(4),

        -- Ahora creamos un indice llamado telefonos_autor_indice, que utiliza autor_id
        -- Es lo que se llama clave o campo ajeno. Para avisar que tambien es clave (KEY)
        -- pero no de esta tabla, le llamamos INDEX
        INDEX telefonos_autor_indice (autor_id),

        FOREIGN KEY (autor_id) 
        REFERENCES autores(id)

        -- Si se borra un autor... se borran sus telefonos. Mejor y mas 
        -- eficiente hacerlo aqui que mediante lenguaje de programación

        ON DELETE CASCADE
        ON UPDATE CASCADE

        -- Experimento interesante: cambiar CASCADE por RESTRICT
        -- Podrá comprobar que un autor no puede ser borrado hasta que todos 
        -- sus telefonos tambien sean borrados



) ENGINE=InnoDB;

-- Insertamos unos telefonos correspondientes a Sabato (id 2)
INSERT INTO telefonos (id,telefono,autor_id) VALUES (NULL,'02262 224222',2);
INSERT INTO telefonos (id,telefono,autor_id) VALUES (NULL,'011 155072289',2);

-- Cuantos telefonos tiene Sabato?
SELECT * FROM autores,telefonos WHERE apellido LIKE 'Sabato';

-- Probemos ahora si funciona el ON UPDATE CASCADE. Sabato tiene 2 en el id. Lo cambiamos por 9       
UPDATE `autores` SET `id`=9 WHERE `id`=2; 

-- Repetimos el ultimo select ...
SELECT * FROM autores,telefonos WHERE apellido LIKE 'Sabato';

-- Sorpresa! cambiaron los id relacionados!!

-- Ahora, para probar el ON DELETE CASCADE, borramos a Sabato
DELETE FROM autores WHERE apellido LIKE 'Sabato';

-- Sabato no existe mas
SELECT * FROM autores;

-- Y sus telefonos tampoco!!!!
SELECT * FROM telefonos;


-- ====================== MUCHO A MUCHOS ================================

CREATE TABLE libros (

  id INT(5) NOT NULL PRIMARY KEY UNIQUE AUTO_INCREMENT,
  titulo VARCHAR(100)

) ENGINE=INNODB;

INSERT INTO libros (id,titulo) VALUES (NULL,'Martin Fierro'),
                                      (NULL,'Los 33 Orientales'),
                                      (NULL,'Vida del Chacho')
                                      ;

SELECT * FROM libros;

-- Ahora la tabla relación


CREATE TABLE autores_escriben_libros (
  id INT(6) NOT NULL PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
  autor_id INT(4),
  libro_id INT(5) ,

  -- Creamos un indice basado en autor_id
  INDEX autor_escriben_libros_indice1 (autor_id),

     -- Anunciamos que este nuevo indice es ajeno, y que se corresponde con otra tabla
     FOREIGN KEY (autor_id) REFERENCES autores(id)

     -- No permitimos borrar autores que hayan escrito libros
     ON DELETE RESTRICT 

     -- Si cambia el id de un autor, cambia tambien el autor_id de esta tabla
     ON UPDATE CASCADE

     
) ENGINE = INNODB;


/* Veo las claves AJENAS que posee la tabla
MySQL lleva un registro de las claves, dentro de una base (escondida) llamada 
REFERENTIAL_CONSTRAINTS. Una inspección mas detallada arroja:
*/

SELECT TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    DELETE_RULE,
    UPDATE_RULE
    FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS;


-- Relacionamos a José Hernandez, cuyo id es 1, a los 3 libros existentes
INSERT INTO autores_escriben_libros (id, autor_id, libro_id) VALUES 
    (NULL,1,1), 
    (NULL,1,2), 
    (NULL,1,3);

-- Qué libros escribió José Hernandez?
SELECT libros.titulo 
   FROM libros,autores 
   WHERE autores.nombre LIKE 'Jose' AND 
         autores.apellido = 'Hernandez';

/* Ejercicios:

1) Borre a Jose Hernandez si es guapo: descomente la siguiente línea:

DELETE FROM autores WHERE id=1;

2) Introduzca los cambios necesarios para que no se puedan borrar libros que figuren escritos por alguien
*/
