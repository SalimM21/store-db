-- Challenge 1 : Création d’une Base de Données
-- Table customers
CREATE TABLE customers1 (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(200),
    city VARCHAR(50),
    -- state VARCHAR(50),
    -- postal_code VARCHAR(20),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table products
CREATE TABLE products1 (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table orders
CREATE TABLE orders1 (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(10, 2) NOT NULL,
    -- shipping_address VARCHAR(200) NOT NULL,
    -- payment_method VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Table order_items
CREATE TABLE order_items1 (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- Challenge 2 : Création de Tables

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20)
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    category VARCHAR(50)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Ajout des contraintes de clé étrangère
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id) 
REFERENCES customers(customer_id)
ON DELETE RESTRICT;

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id) 
REFERENCES orders(order_id)
ON DELETE CASCADE;

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id) 
REFERENCES products(product_id)
ON DELETE RESTRICT;

-- Vérification des contraintes
-- SELECT
--     tc.table_name, 
--     kcu.column_name, 
--     ccu.table_name AS foreign_table_name,
--     ccu.column_name AS foreign_column_name,
--     tc.constraint_name
-- FROM 
--     information_schema.table_constraints AS tc 
--     JOIN information_schema.key_column_usage AS kcu
--       ON tc.constraint_name = kcu.constraint_name
--     JOIN information_schema.constraint_column_usage AS ccu
--       ON ccu.constraint_name = tc.constraint_name
-- WHERE 
--     tc.constraint_type = 'FOREIGN KEY';

-- Challenge 3 : Insertion de Données

INSERT INTO customers (first_name, last_name, email, phone_number)
VALUES
    ('Jean', 'Dupont', 'jean.dupont@email.com', '0612345678'),
    ('Marie', 'Martin', 'marie.martin@email.com', '0623456789'),
    ('Pierre', 'Bernard', 'pierre.bernard@email.com', '0634567890'),
    ('Sophie', 'Petit', 'sophie.petit@email.com', '0645678901'),
    ('Thomas', 'Durand', 'thomas.durand@email.com', '0656789012');

INSERT INTO products (name, price, category)
VALUES
    ('Ordinateur portable', 899.99, 'Informatique'),
    ('Smartphone', 699.50, 'Téléphonie'),
    ('Casque audio', 129.99, 'Audio'),
    ('Souris sans fil', 29.95, 'Informatique'),
    ('Clavier mécanique', 89.99, 'Informatique');

-- Voir les tables déclarée 
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;

-- Insertion des commandes avec TOUTES les colonnes requises
-- Commande 1: Jean Dupont (2 produits)
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES (1, '2023-10-15 14:30:00', 1029.98)
RETURNING order_id;

-- Commande 2: Marie Martin (1 produit)
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES (2, '2023-10-16 09:15:00', 699.50)
RETURNING order_id;

-- Commande 3: Pierre Bernard (3 produits)
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES (3, '2023-10-17 16:45:00', 219.93)
RETURNING order_id;

-- Commande 4: Sophie Petit (1 produit)
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES (4, '2023-10-18 11:20:00', 89.99)
RETURNING order_id;

-- Commande 5: Thomas Durand (2 produits)
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES (5, '2023-10-19 13:10:00', 729.94)
RETURNING order_id;

-- Associez les commandes aux produits via la table order_items
-- Utilisation d'une CTE pour plus de clarté
WITH commande_articles AS (
    SELECT 
        o.order_id,
        p.product_id,
        CASE 
            WHEN (o.customer_id = 1 AND p.product_id IN (1, 3)) THEN 1
            WHEN (o.customer_id = 2 AND p.product_id = 2) THEN 1
            WHEN (o.customer_id = 3 AND p.product_id = 4) THEN 2  -- 2 souris
            WHEN (o.customer_id = 3 AND p.product_id IN (3, 5)) THEN 1
            WHEN (o.customer_id = 4 AND p.product_id = 5) THEN 1
            WHEN (o.customer_id = 5 AND p.product_id IN (2, 4)) THEN 1
        END AS quantity,
        p.price
    FROM orders o
    CROSS JOIN products p
    WHERE (o.customer_id = 1 AND p.product_id IN (1, 3))
       OR (o.customer_id = 2 AND p.product_id = 2)
       OR (o.customer_id = 3 AND p.product_id IN (3, 4, 5))
       OR (o.customer_id = 4 AND p.product_id = 5)
       OR (o.customer_id = 5 AND p.product_id IN (2, 4))
)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT order_id, product_id, quantity, price
FROM commande_articles
WHERE quantity IS NOT NULL;

-- Vérification des associations
SELECT 
    o.order_id,
    c.first_name || ' ' || c.last_name AS client,
    p.name AS produit,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS total_ligne
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, p.name;

-- Challenge 4 : Requêtes de Sélection Simples

-- Sélectionnez tous les clients
SELECT * FROM customers;

-- Sélectionnez les commandes passées après le 1er janvier 2024
SELECT *
FROM orders
WHERE order_date > '2024-01-01'
ORDER BY order_date DESC;

-- Sélectionnez le nom et l’e-mail des clients ayant passé une commande
SELECT DISTINCT 
    c.first_name || ' ' || c.last_name AS client_name,
    c.email
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- Challenge 5 : Clauses WHERE
-- Sélectionnez les clients dont le prénom est "Jean".
SELECT *
FROM customers
WHERE first_name = 'Jean';

-- Sélectionnez les commandes dont le montant est supérieur à 100 €
SELECT *
FROM orders
WHERE total_amount > 100
ORDER BY total_amount DESC;

-- Sélectionnez les clients dont le nom commence par "D"
SELECT *
FROM customers
WHERE last_name LIKE 'D%'
ORDER BY last_name, first_name;

-- +++++++++++++++++++++++++++++++++++++++++++++
-- INSERT INTO customers (first_name, last_name, email, phone_number)
-- VALUES
--     ('Jean', 'dupont', 'jean.dup22t@email.com', '0612345678'),
--     ('Marie', 'Madtin', 'marie.ma44lin@email.com', '0623456789'),
--     ('Pierre', 'Bdrnard', 'pierre.b55rnard@email.com', '0634567890'),
--     ('Sophie', 'Pedit', 'sophie.p55klt@email.com', '0645678901'),
--     ('Thomas', 'Durand', 'thomas.dl22nd@email.com', '0656789012');
--  SELECT * FROM customers;
-- +++++++++++++++++++++++++++++++++++++++++++++
-- Challenge 6 : Mise à Jour de Données
-- Mettez à jour le numéro de téléphone d’un client
UPDATE customers
SET phone_number = '+33123456789'
WHERE customer_id = 1;  -- Remplacez 1 par l'ID du client

-- Augmentez le total_amount de toutes les commandes de 10%
UPDATE orders
SET total_amount = total_amount * 1.10;

-- Corrigez une adresse e-mail incorrecte
UPDATE customers
SET email = 'nouvel.email@Hotmail.com'
WHERE customer_id = 2;

-- Challenge 7 : Suppression de Données
-- Supprimez les commandes antérieures à 2023
DELETE FROM orders
WHERE order_date < '2023-01-01'

-- Supprimez un client et toutes ses commandes associées (ON DELETE CASCADE)
-- Méthode sécurisée avec transaction
BEGIN;
    -- Suppression du client (cela supprimera automatiquement ses commandes)
    DELETE FROM customers
    WHERE customer_id = 3;  -- Remplacez par l'ID du client
    
    -- Vérification
    SELECT * FROM customers WHERE customer_id = 3;
    SELECT * FROM orders WHERE customer_id = 3;
COMMIT;

-- Supprimez toutes les commandes d’un client spécifique (exemple les comande de Jean )
-- Suppression directe si les contraintes CASCADE sont en place
DELETE FROM orders
WHERE customer_id IN (
    SELECT customer_id 
    FROM customers 
    WHERE first_name = 'Jean'
);

-- ===========================================================
-- challenge avancer
-- Challenge 1 : Jointures entre Tables
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.phone_number
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
ORDER BY 
    o.order_date DESC

-- Listez les clients n’ayant passé aucune commande (jointure externe)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.phone_number
FROM 
    customers c
LEFT JOIN 
    orders o ON c.customer_id = o.customer_id
WHERE 
    o.order_id IS NULL
ORDER BY 
    c.last_name, c.first_name;

-- Listez tous les clients avec le nombre de commandes qu’ils ont passées
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(o.order_id) AS nombre_commandes
FROM 
    customers c
LEFT JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email
ORDER BY 
    nombre_commandes DESC, c.last_name;

-- Challenge 2 : Agrégation de Données
-- Calculez le montant total des commandes (SUM())
SELECT SUM(total_amount) AS montant_total_commandes
FROM orders;

-- Comptez le nombre de clients (COUNT())
SELECT COUNT(*) AS nombre_total_clients
FROM customers;

-- Calculez le montant moyen des commandes (AVG())
SELECT AVG(total_amount) AS montant_moyen_commandes
FROM orders;

-- Challenge 3 : Groupement de Données
-- Montant total des commandes par client (GROUP BY customer_id)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS nom_client,
    COUNT(o.order_id) AS nombre_commandes,
    COALESCE(SUM(o.total_amount), 0) AS montant_total,
    ROUND(COALESCE(AVG(o.total_amount), 0), 2) AS moyenne_par_commande
FROM 
    customers c
LEFT JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
ORDER BY 
    montant_total DESC;

-- Nombre de commandes par mois
SELECT 
    EXTRACT(YEAR FROM order_date) AS annee,
    EXTRACT(MONTH FROM order_date) AS mois,
    TO_CHAR(order_date, 'YYYY-MM') AS annee_mois,
    COUNT(*) AS nombre_commandes,
    SUM(total_amount) AS chiffre_affaires
FROM 
    orders
GROUP BY 
    annee, mois, annee_mois
ORDER BY 
    annee, mois

-- Afficher les clients ayant un montant total de commandes supérieur à 1000 €
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS client,
    c.email,
    COUNT(o.order_id) AS nombre_commandes,
    SUM(o.total_amount) AS montant_total,
    ROUND(AVG(o.total_amount), 2) AS moyenne_par_commande
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id
HAVING 
    SUM(o.total_amount) > 1000
ORDER BY 
    montant_total DESC;
-- Challenge 4 : Sous-Requêtes
-- Clients ayant passé au moins une commande > 200 €
SELECT DISTINCT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS client,
    c.last_name,  
    c.first_name,
    c.email,
    c.phone_number
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
WHERE 
    o.total_amount > 200
ORDER BY 
    c.last_name, c.first_name;
	
-- Client avec le plus gros montant cumulé de commandes.
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS client,
    SUM(o.total_amount) AS montant_total_commandes
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id
ORDER BY 
    montant_total_commandes DESC
LIMIT 1

-- Commandes > à la moyenne des montants de commande.
SELECT 
    o.order_id,
    c.first_name || ' ' || c.last_name AS client,
    o.order_date,
    o.total_amount,
    (SELECT AVG(total_amount) FROM orders) AS moyenne_commandes,
    o.total_amount - (SELECT AVG(total_amount) FROM orders) AS difference_moyenne
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
WHERE 
    o.total_amount > (SELECT AVG(total_amount) FROM orders)
ORDER BY 
    o.total_amount DESC
-- Challenge 5 : Création de Vues
-- Créez une vue customer_orders_view (client + commandes).
CREATE OR REPLACE VIEW customer_orders_view AS
SELECT 
    c.customer_id,                  
    c.first_name || ' ' || c.last_name AS customer_name, 
    c.email,                         
    c.phone_number,                  
    COUNT(o.order_id) AS total_orders, 
    COALESCE(SUM(o.total_amount), 0) AS total_spent, -- Somme des commandes (avec gestion des NULL)
    ROUND(COALESCE(AVG(o.total_amount), 0), 2) AS avg_order_value, -- Moyenne arrondie
    MIN(o.order_date) AS first_order_date, -- Date de première commande
    MAX(o.order_date) AS last_order_date  -- Date de dernière commande
FROM 
    customers c
LEFT JOIN 
    orders o ON c.customer_id = o.customer_id  -- Jointure avec possibilité de NULL
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email, c.phone_number
-- Toutes les colonnes non-agrégées doivent être dans GROUP BY
CREATE OR REPLACE VIEW customer_orders_view AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,  -- Concaténation
    c.email,
    c.phone_number,
    COUNT(o.order_id) AS total_orders,                   -- Agrégat
    COALESCE(SUM(o.total_amount), 0) AS total_spent,     -- Agrégat + gestion NULL
    ROUND(COALESCE(AVG(o.total_amount), 0), 2) AS avg_order_value, -- Agrégat arrondi
    MIN(o.order_date) AS first_order_date,               -- Agrégat
    MAX(o.order_date) AS last_order_date                 -- Agrégat
FROM 
    customers c
LEFT JOIN 
    orders o ON c.customer_id = o.customer_id
GROUP BY 
    -- Toutes les colonnes non-agrégées du SELECT :
    c.customer_id, 
    c.first_name,  -- Note: on décompose la concaténation
    c.last_name, 
    c.email, 
    c.phone_number
-- Utilisez cette vue pour afficher les clients avec > 1000 € en commandes.
SELECT 
    customer_id,
    customer_name,
    email,
    total_spent,
    total_orders
FROM 
    customer_orders_view
WHERE 
    total_spent > 1000
ORDER BY 
    total_spent DESC
-- Créez une vue monthly_sales_view (ventes totales par mois).
CREATE OR REPLACE VIEW monthly_sales_view AS
SELECT 
    DATE_TRUNC('month', order_date)::DATE AS month,
    EXTRACT(YEAR FROM order_date) AS year,
    TO_CHAR(order_date, 'YYYY-MM') AS year_month,
    TO_CHAR(order_date, 'Month') AS month_name,
    COUNT(DISTINCT order_id) AS number_of_orders,
    COUNT(DISTINCT customer_id) AS number_of_customers,
    SUM(total_amount) AS total_sales,
    ROUND(SUM(total_amount) / COUNT(DISTINCT order_id), 2) AS average_order_value,
    SUM(total_amount) / COUNT(DISTINCT customer_id) AS sales_per_customer,
    LAG(SUM(total_amount), 1) OVER (ORDER BY DATE_TRUNC('month', order_date)) AS previous_month_sales,
    SUM(total_amount) - LAG(SUM(total_amount), 1) OVER (ORDER BY DATE_TRUNC('month', order_date)) AS monthly_growth
FROM 
    orders
GROUP BY 
    DATE_TRUNC('month', order_date),
    EXTRACT(YEAR FROM order_date),
    TO_CHAR(order_date, 'YYYY-MM'),
    TO_CHAR(order_date, 'Month')
ORDER BY 
    month
