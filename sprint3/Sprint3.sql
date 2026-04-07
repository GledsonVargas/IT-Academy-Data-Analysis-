use transactions;

    -- Creamos la tabla credit card
    CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(15) PRIMARY KEY, INDEX(id),
        iban VARCHAR(34),
        pan VARCHAR(19),
        pin VARCHAR(12),
        cvv VARCHAR(4),
        expiring_date VARCHAR(8)
    );

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id)
;

-- NIVELL 1 --

-- Exercici 2

-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta de crèdit 
-- amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. 
-- Recorda mostrar que el canvi es va realitzar.

UPDATE credit_card
SET iban = "TR323456312213576817699999"
WHERE id = "CcU-2938"
;

SELECT *
FROM credit_card
WHERE id = "CcU-2938"
;

-- Exercici 3
-- En la taula "transaction" ingressa una nova transacció amb la següent informació:
-- Id 	108B1D1D-5B23-A76C-55EF-C568E49A99DD
-- credit_card_id 	CcU-9999
-- company_id 	b-9999
-- user_id 	9999
-- lat 	829.999
-- longitude 	-117.999
-- amount 	111.11
-- declined 	0
INSERT INTO company (id) VALUES ('b-9999');
INSERT INTO credit_card (id) VALUES ('CcU-9999');

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');

SELECT *
FROM transaction 
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD'
;

-- Exercici 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.
ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card
;

-- NIVEL 2
-- Exercici 1
-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.
DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- Exercici 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
-- Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, 
-- ordenant les dades de major a menor mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT c.company_name AS Empresa, 
	   c.phone AS Telefono,
       c.country AS Pais,
       AVG(t.amount) AS Media_Compra
FROM transaction t
JOIN company c
ON t.company_id = c.id
GROUP BY c.id
;

SELECT *
FROM vistamarketing
ORDER BY Media_Compra DESC;

-- Exercici 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
SELECT *
FROM vistamarketing
WHERE Pais = "Germany"
;

-- NIVELL 3
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
-- Un company del teu equip va realitzar modificacions en la base de dades, però no recorda com les va realitzar. 
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:

CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY, INDEX(id),
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

ALTER TABLE user
MODIFY COLUMN id INT;

-- Verificar el user NULL
SELECT t.user_id
FROM transaction t
LEFT JOIN user u ON t.user_id = u.id
WHERE u.id IS NULL;
-- El usuario NULL es el añadido en el ejercicio anterior (9999)

-- Adicionamos el user 9999 en user.id para poder gestionar la relación (transaction - user)
INSERT INTO user (id) VALUES ('9999');

ALTER TABLE transaction
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id)
REFERENCES user(id)
;

-- RELACIÓN CREADA, MOSTRAR REVERSE ENGINEER
-- Para dejar nuestra tabla tal cual la imagen

-- Modificar el nombre de la tabla user para data_user
RENAME TABLE user TO data_user;

-- ELiminar la columna website de company
ALTER TABLE company
DROP COLUMN website;

-- Cambiar el nombre de la columna "email" para "personal_email" en la tabla data_user:
ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

-- Cambiar el tipo de dato de la columa "cvv" de la tabla credit_card a INT
ALTER TABLE credit_card
MODIFY COLUMN cvv INT;

-- Agregar la columna "fecha_actual" a la tabla credit_card
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

-- Exercici 2
-- L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:
-- ID de la transacció
-- Nom de l'usuari/ària
-- Cognom de l'usuari/ària
-- IBAN de la targeta de crèdit usada.
-- Nom de la companyia de la transacció realitzada.

-- Assegureu-vos d'incloure informació rellevant de les taules que coneixereu i utilitzeu àlies per 
-- canviar de nom columnes segons calgui.

-- Mostra els resultats de la vista, ordena els resultats de forma descendent en funció de la variable ID de transacció.

CREATE OR REPLACE VIEW InformeTecnico AS
SELECT t.id AS ID_Transaccion, 
	   CONCAT(d.name, ' ', d.surname) AS Nombre,
       cc.iban AS Iban_Tarjeta,
       c.company_name AS Nombre_Compania
FROM transaction t
JOIN company c
ON t.company_id = c.id
JOIN data_user d
ON d.id = t.user_id
JOIN credit_card cc
ON cc.id = t.credit_card_id
WHERE t.declined = 0
;

SELECT *
FROM informetecnico
ORDER BY ID_Transaccion DESC;

