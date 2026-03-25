USE transactions;

-- NIVELL 1 -- 

-- EXERCICI 2 -- 

-- Llistat dels països que estan generant vendes.
SELECT distinct country AS Paises_con_ventas
FROM transaction t
JOIN company c
ON t.company_id = c.id
WHERE t.declined = 0
;

-- Des de quants països es generen les vendes.
SELECT COUNT(DISTINCT(country)) AS Paises_con_ventas
FROM transaction t
JOIN company c
ON t.company_id = c.id
WHERE t.declined = 0
;


-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT c.company_name AS Compania, 
	   ROUND(AVG(t.amount),2) AS Media_mas_alta
FROM transaction t
JOIN company c
ON t.company_id = c.id
GROUP BY c.company_name, t.amount
ORDER BY t.amount DESC
LIMIT 1
;

-- EXERCICI 3 -- 
-- Utilitzant només subconsultes (sense utilitzar JOIN):

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction
WHERE company_id IN (SELECT id
					FROM company 
					WHERE country = "Germany")
;

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT DISTINCT company_id AS Compania,
       (SELECT company_name 
        FROM company 
        WHERE company.id = transaction.company_id) AS Nombre,
        (SELECT ROUND(AVG(amount),2) FROM transaction) AS Media_General, 
        ROUND(AVG(amount),2) AS Media_venta_empresa
FROM transaction
WHERE amount > (SELECT AVG(amount) FROM transaction)
GROUP BY company_id
ORDER BY Media_venta_empresa DESC
;

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT id, company_name AS Compania
FROM company
WHERE id NOT IN (SELECT company_id FROM transaction)
;

SELECT DISTINCT company_id
FROM transaction;

-- NIVELL 2 --

-- EXERCICI 1 -- 
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT SUM(amount) AS Venta, DATE(timestamp) AS Fecha
FROM transaction
GROUP BY DATE(timestamp)
ORDER BY Venta DESC
LIMIT 5
;

-- EXERCICI 2 --
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT ROUND(AVG(amount),2) AS Media, c.country AS pais
FROM transaction t
JOIN company c
ON t.company_id = c.id
GROUP BY pais
ORDER BY Media DESC
;

-- EXERCICI 3 --
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per 
-- a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions 
-- realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- Mostra el llistat aplicant JOIN i subconsultes.
-- Mostra el llistat aplicant solament subconsultes.

-- AMB JOIN
SELECT *
FROM transaction t
JOIN company c
ON t.company_id = c.id
WHERE c.country = (SELECT country 
				   FROM company 
                   WHERE company_name IN ("Non Institute"))
;

-- SIN JOIN
SELECT *
FROM transaction
WHERE company_id IN (SELECT id
					 FROM company
                     WHERE country = (SELECT country
									  FROM company
                                      WHERE company_name = "Non Institute")
					)
;

-- NIVELL 3 --

-- Exercici 1 --
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions 
-- amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 29 d'abril del 2015, 
-- 20 de juliol del 2018 i 13 de març del 2024. Ordena els resultats de major a menor quantitat

SELECT c.company_name AS Compania, 
	   c.phone AS Teléfono, 
       DATE(t.timestamp) AS Fecha, 
       t.amount AS Importe
FROM transaction t
INNER JOIN company c
ON t.company_id = c.id
WHERE t.amount BETWEEN 350 AND 400 
AND DATE(timestamp) IN ("2015-04-29", "2018-07-20", "2024-03-13")
ORDER BY t.amount DESC
;

-- Exercici 2 --
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen
-- més de 400 transaccions o menys.

SELECT c.company_name AS Compania, 
	   CASE 
			WHEN count(t.id) > 400 THEN "Más de 400"
            WHEN count(t.id) < 400 THEN "Menos de 400"
	   END AS Numero_transacciones
FROM transaction t
INNER JOIN company c
ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.company_name
;

					