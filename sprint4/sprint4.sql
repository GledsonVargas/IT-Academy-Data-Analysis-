-- Crear la base de datos
CREATE SCHEMA IF NOT EXISTS global_transactions
DEFAULT CHARACTER SET utf8mb4 -- soporta todos los caracteres UNICODE, incluso acentos (á, é, ñ...)
COLLATE utf8mb4_general_ci; -- Define cómo se comparan y ordenan los textos (usar ese dataset utf8, general es la regla de comparación y ci es case sensitive)

-- usar la base de datos
USE global_transactions;

-- Creamos la tabla transactions
CREATE TABLE transactions (
    id CHAR(36) PRIMARY KEY, INDEX(id),
    card_id VARCHAR(20),
    business_id VARCHAR(20),
    timestamp VARCHAR(50),
    amount DECIMAL(10,2),
    declined BOOLEAN,
    product_ids VARCHAR(255),
    user_id INT,
    lat DECIMAL(10,8),
    longitude DECIMAL(11,8)
);

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';        -- servidor
SHOW VARIABLES LIKE 'loose_local_infile';  -- client	

-- subimos los datos a la tabla transactions
LOAD DATA LOCAL INFILE 'C:/Users/Lenovo/Dropbox/Gledson/Gledson/Data Science/bootcampba/especialitzacio/Sprint4/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' -- separador del CSV
ENCLOSED BY '"' -- que las cadenas están encerradas por comillas dobles 
LINES TERMINATED BY '\n' -- salto de línea
IGNORE 1 ROWS -- ignorar cabecera
(
    id, card_id, business_id,
    timestamp, amount, declined,
    product_ids, user_id, lat, longitude
);

-- Creamos la tabla products
CREATE TABLE products (
    id INT PRIMARY KEY, INDEX(id),
    product_name VARCHAR(100),
    price DECIMAL(10,2),
    colour VARCHAR(7),
    weight DECIMAL(5,2),
    warehouse_id VARCHAR(10)
); 

-- Subimos los datos a la tabla products
LOAD DATA LOCAL INFILE 'C:/Users/Lenovo/Dropbox/Gledson/Gledson/Data Science/bootcampba/especialitzacio/Sprint4/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id, product_name, @price_str,
    colour, weight, warehouse_id
)
SET price = REPLACE(@price_str, '$', '');

-- Creamos la tabla european_users
CREATE TABLE european_users (
    id INT PRIMARY KEY, INDEX(id),
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date VARCHAR(10),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    address VARCHAR(150)
);

-- subimos los datos a la tabla european_user
LOAD DATA LOCAL INFILE 'C:/Users/Lenovo/Dropbox/Gledson/Gledson/Data Science/bootcampba/especialitzacio/Sprint4/european_users.csv'
INTO TABLE european_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id, name, surname, phone,
    email, birth_date, country, 
    city, postal_code, address
);

-- Creamos la tabla american_users
CREATE TABLE american_users (
    id INT PRIMARY KEY, INDEX(id),
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    birth_date VARCHAR(10),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(10),
    address VARCHAR(150)
);

-- Subimos los datos a american_users
LOAD DATA LOCAL INFILE 'C:/Users/Lenovo/Dropbox/Gledson/Gledson/Data Science/bootcampba/especialitzacio/Sprint4/american_users.csv'
INTO TABLE american_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id, name, surname, phone,
    email, birth_date, country, 
    city, postal_code, address
);

-- UNIR TABLAS AS USERS
CREATE TABLE users AS
SELECT * FROM european_users
UNION ALL
SELECT * FROM american_users;

-- Creamos la tabla credit_cards
CREATE TABLE credit_cards (
    id VARCHAR(20) PRIMARY KEY, INDEX(id),
    user_id INT,
    iban VARCHAR(34),
    pan VARCHAR(20),
    pin INT,
    cvv INT,
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(10)
);

-- subimos los datos a credit_cards
LOAD DATA LOCAL INFILE 'C:/Users/Lenovo/Dropbox/Gledson/Gledson/Data Science/bootcampba/especialitzacio/Sprint4/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id, user_id, iban, pan,
    pin, cvv, track1, track2,
    expiring_date
);

-- Creamos, finalmente, la tabla companies
CREATE TABLE companies (
    id VARCHAR(10) PRIMARY KEY, INDEX(id),
    company_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(150)
);

-- subimos los datos a la tabla companies
LOAD DATA LOCAL INFILE 'C:/Users/Lenovo/Dropbox/Gledson/Gledson/Data Science/bootcampba/especialitzacio/Sprint4/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    id, company_name, phone,
    email, country, website
);

-- Un par de modificaciones para relacionar mejor las tablas
ALTER TABLE transactions
RENAME COLUMN business_id TO company_id;

ALTER TABLE transactions
RENAME COLUMN product_ids TO product_id;

ALTER TABLE users
ADD PRIMARY KEY (id);

-- Después de ver el reverse engineer, decidí quitar el nombre en plural de las tablas.
RENAME TABLE credit_cards TO credit_card;
RENAME TABLE products TO product;
RENAME TABLE transaction_products TO transaction_product;
RENAME TABLE transactions TO transaction;
RENAME TABLE users TO user;
RENAME TABLE companies TO company;

-- Creamos la tabla intermediaria entre transactions y cards
CREATE TABLE transaction_product (
    transaction_id CHAR(36)  NOT NULL,
    product_id     INT        NOT NULL,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transaction(id),
    FOREIGN KEY (product_id)     REFERENCES product(id)
);

DROP TABLE transaction_product;

ALTER TABLE transaction
DROP COLUMN product_id;

SELECT * FROM information_schema.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'global_transactions'
AND TABLE_NAME = 'transaction_product';

ALTER TABLE transaction_product
ADD CONSTRAINT fk_product
	FOREIGN KEY (product_id) REFERENCES product(id),
ADD CONSTRAINT fk_transaction
	FOREIGN KEY (transaction_id) REFERENCES transaction(id);

-- subimos los datos a esa tabla
LOAD DATA LOCAL INFILE 'C:/Users/Lenovo/Dropbox/Gledson/Gledson/Data Science/bootcampba/especialitzacio/Sprint4/transaction_products_id.csv'
INTO TABLE transaction_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    transaction_id, product_id
);

-- Ahora tenemos el dataset global_transactions hecho.
-- Con una vista del reverse engineer, podemos ver las conexiones.
-- Vamos a hacer los enlaces de keys. La tabla de hechos transactions 
ALTER TABLE transactions
ADD CONSTRAINT fk_card
	FOREIGN KEY (card_id) REFERENCES credit_cards(id),
ADD CONSTRAINT fk_users
	FOREIGN KEY (user_id) REFERENCES users(id),
ADD CONSTRAINT fk_companies
	FOREIGN KEY (company_id) REFERENCES companies(id);
    
-- Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb 
-- més de 80 transaccions utilitzant almenys 2 taules.
SELECT id AS Identificador, 
	   CONCAT(name, ' ', surname) AS Nombre,
       (SELECT COUNT(id) 
        FROM transaction
        WHERE user_id = user.id) AS Transacciones
FROM user	
WHERE id IN (SELECT transaction.user_id 
			 FROM transaction
             GROUP BY user_id
             HAVING COUNT(id) > 80
             )
ORDER BY Transacciones DESC
;

-- comprobamos con una query en transaction
SELECT user_id, COUNT(id)
FROM transaction
GROUP BY user_id
HAVING COUNT(id) > 80
ORDER BY COUNT(id) DESC;

-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, 
-- utilitza almenys 2 taules.
SELECT iban AS Número_iban, 
	   round(AVG(amount),2) AS Media_Importe,
       c.company_name AS Compania
FROM transaction t
JOIN credit_card cc
ON t.card_id = cc.id
JOIN company c
ON t.company_id = c.id
WHERE c.company_name = 'Donec Ltd'
AND t.declined = 0
GROUP BY cc.iban, cc.id
ORDER BY Media_importe DESC;

-- Nivell 2
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions 
-- han estat declinades aleshores és inactiu, si almenys una 
-- no és rebutjada aleshores és actiu. Partint d’aquesta taula respon:
CREATE TABLE situacion_tarjetas AS
SELECT card_id AS Tarjeta,
CASE 
	WHEN SUM(declined) = 3 THEN 'Inactiva'
    WHEN MIN(declined) = 0 THEN 'Activa'S
END AS Activa_Inactiva
FROM (SELECT card_id, 
	   declined, 
       timestamp,
	   ROW_NUMBER() 
       OVER(PARTITION BY card_id ORDER BY timestamp DESC) 
       AS últimos_registros
	   FROM transaction) AS más_recientes
WHERE últimos_registros <= 3
GROUP BY card_id;

-- Separamos la query antes
SELECT card_id, 
	   declined, 
       timestamp,
	   ROW_NUMBER() 
       OVER(PARTITION BY card_id ORDER BY timestamp DESC) 
       AS últimos_registros
	   FROM transaction;
       

-- Exercici 1
-- Quantes targetes estan actives?
SELECT COUNT(tarjeta) AS Tarjetas_activas
FROM situacion_tarjetas
WHERE Activa_Inactiva = 'Activa';

-- Nivell 3
-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
-- tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

-- JSON_TABLE no es una tabla real, es una función que genera filas on the go
-- El CROSS JOIN une cada fila de transaction con las filas que genere esa función. 
-- Por eso no puede ser LEFT or INNER, porque no hay un ON.
SELECT 
    t.id AS transaction_id,
    jt.product_id
FROM transaction t
CROSS JOIN JSON_TABLE(   
    CONCAT('[', REPLACE(t.product_id, ' ', ''), ']'),  -- REPLACE convierte "75, 73, 98" en "75,73,98" (elimina espacios)
    '$[*]' COLUMNS (								   -- CONCAT convierte "75,73,98" en "[75,73,98]" (JSON válido)
        product_id INT PATH '$'						   -- $ → representa el elemento raíz, en este caso el array entero [75,73,98]
    )												   -- [*] → significa "cada elemento del array"
) AS jt;

-- product_id → nombre de la columna nueva
-- INT → tipo de dato
-- PATH '$' → el valor de cada elemento ($ aquí representa cada número individualmente: 75, luego 73, luego 98)

CREATE TABLE transaction_product (
    transaction_id VARCHAR(36),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id)
);

INSERT INTO transaction_product (transaction_id, product_id)
SELECT 
    t.id,
    jt.product_id
FROM transaction t
CROSS JOIN JSON_TABLE(
    CONCAT('[', REPLACE(t.product_id, ' ', ''), ']'),
    '$[*]' COLUMNS (
        product_id INT PATH '$'
    )
) AS jt;

-- Exercici 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT product_id AS Id,
	   (SELECT product_name
        FROM product
        WHERE product.id = transaction_product.product_id) AS Producto,
	   COUNT(transaction_id) AS Venta
FROM transaction_product
WHERE transaction_id = (SELECT id
						FROM transaction
                        WHERE transaction.id = transaction_product.transaction_id
                        AND declined = 0)
GROUP BY product_id
ORDER BY Venta DESC;


