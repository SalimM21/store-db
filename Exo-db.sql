-- Exercice : Gestion d'une Bibliothèque Numérique
-- Création de la table Utilisateurs
CREATE TABLE Utilisateurs (
    id_utilisateur SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('lecteur', 'bibliothecaire', 'admin')),
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Création de la table Livre
CREATE TABLE Livre (
    id_livre SERIAL PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    auteur VARCHAR(100) NOT NULL,
    categorie VARCHAR(50),
    disponible BOOLEAN DEFAULT TRUE,
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Création de la table Emprunts
CREATE TABLE Emprunts (
    id_emprunt SERIAL PRIMARY KEY,
    id_utilisateur INTEGER NOT NULL REFERENCES Utilisateurs(id_utilisateur),
    id_livre INTEGER NOT NULL REFERENCES Livre(id_livre),
    date_emprunt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_retour_prevue TIMESTAMP NOT NULL,
    date_retour_reelle TIMESTAMP,
    statut VARCHAR(20) DEFAULT 'en cours' CHECK (statut IN ('en cours', 'retourné', 'en retard')),
    CONSTRAINT check_dates CHECK (date_retour_prevue > date_emprunt AND 
                               (date_retour_reelle IS NULL OR date_retour_reelle >= date_emprunt))
);

-- Création de la table Commentaires
CREATE TABLE Commentaires (
    id_commentaire SERIAL PRIMARY KEY,
    id_utilisateur INTEGER NOT NULL REFERENCES Utilisateurs(id_utilisateur),
    id_livre INTEGER NOT NULL REFERENCES Livre(id_livre),
    texte TEXT NOT NULL,
    note INTEGER CHECK (note BETWEEN 1 AND 5),
    date_commentaire TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX idx_livre_titre ON Livre(titre);
CREATE INDEX idx_livre_auteur ON Livre(auteur);
CREATE INDEX idx_emprunts_utilisateur ON Emprunts(id_utilisateur);
CREATE INDEX idx_emprunts_livre ON Emprunts(id_livre);
CREATE INDEX idx_commentaires_livre ON Commentaires(id_livre);

-- Partie 1 : Requêtes SQL basiques
-- Insertion des utilisateurs
INSERT INTO Utilisateurs (id_utilisateur, nom, email, role) VALUES
(1, 'Alice Martin', 'alice.martin@mail.com', 'lecteur'),
(2, 'John Doe', 'john.doe@mail.com', 'bibliothecaire'),
(3, 'Sarah Lopez', 'sarah.lopez@mail.com', 'lecteur'),
(4, 'Marc Dupont', 'marc.dupont@mail.com', 'admin'),
(5, 'Emma Bernard', 'emma.bernard@mail.com', 'bibliothecaire'),
(6, 'Thomas Durand', 'thomas.durand@mail.com', 'lecteur');

-- Vérification des données insérées
SELECT * FROM Utilisateurs ORDER BY id_utilisateur;

-- Insertion des livres avec gestion de la séquence d'ID
BEGIN;

-- Option 1: Insertion avec IDs explicites (nécessite la réinitialisation de la séquence)
INSERT INTO Livre (id_livre, titre, auteur, categorie, disponible) VALUES
(1, 'L''Étranger', 'Albert Camus', 'Roman', TRUE),
(2, '1984', 'George Orwell', 'Science-fiction', FALSE),
(3, 'Le Petit Prince', 'Antoine de Saint-Ex.', 'Conte', TRUE),
(4, 'Dune', 'Frank Herbert', 'Science-fiction', FALSE),
(5, 'Les Misérables', 'Victor Hugo', 'Classique', TRUE),
(6, 'Sapiens', 'Yuval Noah Harari', 'Histoire', TRUE);

-- Réinitialisation de la séquence pour les prochains inserts automatiques
SELECT setval('livre_id_livre_seq', (SELECT MAX(id_livre) FROM Livre));

COMMIT;

-- Vérification
SELECT * FROM Livre ORDER BY id_livre;

-- Insertion des emprunts avec gestion de la séquence d'ID
BEGIN;

INSERT INTO Emprunts (id_emprunt, id_utilisateur, id_livre, date_emprunt, date_retour_prevue, date_retour_reelle) VALUES
(1, 1, 2, '2024-06-01', '2024-06-15', NULL),
(2, 3, 4, '2024-06-20', '2024-07-05', '2024-07-03'),
(3, 6, 2, '2024-05-10', '2024-05-25', '2024-05-24'),
(4, 1, 4, '2024-07-01', '2024-07-15', NULL);

-- Réinitialisation de la séquence pour les prochains inserts automatiques
SELECT setval('emprunts_id_emprunt_seq', (SELECT MAX(id_emprunt) FROM Emprunts));

COMMIT;

-- Vérification des données
SELECT * FROM Emprunts ORDER BY id_emprunt;

-- Insertion des commentaires avec gestion de la séquence d'ID
BEGIN;

INSERT INTO Commentaires (id_commentaire, id_utilisateur, id_livre, texte, note) VALUES
(1, 1, 2, 'Un classique à lire absolument', 5),
(2, 3, 4, 'Très dense, mais fascinant', 4),
(3, 6, 2, 'Excellent, mais un peu long', 4),
(4, 1, 4, 'Très bon roman de SF', 5),
(5, 3, 1, 'Lecture facile et intéressante', 3);

-- Réinitialisation de la séquence pour les prochains inserts automatiques
SELECT setval('commentaires_id_commentaire_seq', (SELECT MAX(id_commentaire) FROM Commentaires));

COMMIT;

-- Vérification des données
SELECT * FROM Commentaires ORDER BY id_commentaire;

-- Partie 1 : Requêtes SQL basiques
-- Lister tous les livres disponibles.
SELECT 
    id_livre,
    titre,
    auteur,
    categorie,
    date_ajout
FROM 
    Livre
WHERE 
    disponible = TRUE
ORDER BY 
    titre


-- Afficher les utilisateurs ayant le rôle ‘bibliothecaire’.
SELECT 
    id_utilisateur,
    nom,
    email,
    date_inscription
FROM 
    Utilisateurs
WHERE 
    role = 'bibliothecaire'
ORDER BY 
    nom;
-- Trouver tous les emprunts en retard (date_retour_reelle est NULL et date_retour_prevue < aujourd'hui).
SELECT 
    e.id_emprunt,
    u.nom AS utilisateur,
    u.email,
    l.titre AS livre,
    e.date_emprunt,
    e.date_retour_prevue,
    CURRENT_DATE - e.date_retour_prevue AS jours_retard
FROM 
    Emprunts e
JOIN 
    Utilisateurs u ON e.id_utilisateur = u.id_utilisateur
JOIN 
    Livre l ON e.id_livre = l.id_livre
WHERE 
    e.date_retour_reelle IS NULL
    AND e.date_retour_prevue < CURRENT_DATE
ORDER BY 
    jours_retard DESC;
-- Donner le nombre total d’emprunts effectués.
SELECT COUNT(*) AS nombre_total_emprunts
FROM Emprunts;
-- Afficher les 5 derniers commentaires publiés avec le nom de l'utilisateur et le titre du livre.
SELECT 
    c.id_commentaire,
    u.nom AS utilisateur,
    l.titre AS livre,
    c.texte,
    c.note,
    c.date_commentaire
FROM 
    Commentaires c
JOIN 
    Utilisateurs u ON c.id_utilisateur = u.id_utilisateur
JOIN 
    Livre l ON c.id_livre = l.id_livre
ORDER BY 
    c.date_commentaire DESC
LIMIT 5;

-- Partie 2 : Requêtes SQL avancées
-- Pour chaque utilisateur, afficher le nombre de livres qu’il a empruntés.
SELECT 
    u.id_utilisateur,
    u.nom,
    u.email,
    COUNT(e.id_emprunt) AS nombre_livres_empruntes
FROM 
    Utilisateurs u
LEFT JOIN 
    Emprunts e ON u.id_utilisateur = e.id_utilisateur
GROUP BY 
    u.id_utilisateur, u.nom, u.email
ORDER BY 
    nombre_livres_empruntes DESC;
-- Afficher les livres jamais empruntés.
SELECT 
    l.id_livre,
    l.titre,
    l.auteur,
    l.categorie,
    l.date_ajout
FROM 
    Livre l
LEFT JOIN 
    Emprunts e ON l.id_livre = e.id_livre
WHERE 
    e.id_emprunt IS NULL
ORDER BY 
    l.titre;
-- Calculer la durée moyenne de prêt par livre (en jours).
SELECT 
    l.id_livre,
    l.titre,
    l.auteur,
    ROUND(
        AVG(
            EXTRACT(DAY FROM 
                CASE 
                    WHEN e.date_retour_reelle IS NOT NULL 
                    THEN (e.date_retour_reelle - e.date_emprunt)
                    ELSE (CURRENT_DATE - e.date_emprunt)
                END
            )
        )::numeric, 1
    ) AS duree_moyenne_jours,
    COUNT(e.id_emprunt) AS nombre_emprunts
FROM 
    Livre l
JOIN 
    Emprunts e ON l.id_livre = e.id_livre
GROUP BY 
    l.id_livre, l.titre, l.auteur
ORDER BY 
    duree_moyenne_jours DESC;
-- Lister les 3 livres les mieux notés (moyenne des notes).
SELECT 
    l.id_livre,
    l.titre,
    l.auteur,
    ROUND(AVG(c.note)::numeric, 2) AS note_moyenne,
    COUNT(c.id_commentaire) AS nombre_avis
FROM 
    Livre l
JOIN 
    Commentaires c ON l.id_livre = c.id_livre
GROUP BY 
    l.id_livre, l.titre, l.auteur
HAVING 
    COUNT(c.id_commentaire) > 0  -- Exclut les livres sans commentaires
ORDER BY 
    note_moyenne DESC
LIMIT 3;
-- Afficher les utilisateurs qui ont emprunté au moins un livre de la catégorie "Science-fiction".
SELECT DISTINCT
    u.id_utilisateur,
    u.nom,
    u.email,
    u.role
FROM
    Utilisateurs u
JOIN
    Emprunts e ON u.id_utilisateur = e.id_utilisateur
JOIN
    Livre l ON e.id_livre = l.id_livre
WHERE
    l.categorie = 'Science-fiction'
ORDER BY
    u.nom;

-- Partie 3 : Mises à jour & transactions
-- Mettre à jour le champ disponible à FALSE pour tous les livres actuellement empruntés.
-- Mettre à jour la disponibilité des livres empruntés et non retournés

UPDATE Livre
SET disponible = FALSE
WHERE id_livre IN (
    SELECT DISTINCT e.id_livre
    FROM Emprunts e
    WHERE e.date_retour_reelle IS NULL
);

-- Vérification des résultats
SELECT 
    l.id_livre, 
    l.titre, 
    l.disponible,
    e.date_retour_reelle
FROM 
    Livre l
LEFT JOIN 
    Emprunts e ON l.id_livre = e.id_livre
    AND e.date_retour_reelle IS NULL
WHERE 
    l.disponible = FALSE;
	-- ================================================================
-- Écrire une transaction SQL pour : Emprunter un livre (insérer dans Emprunts)
BEGIN;

-- Vérifications et insertion en une seule opération
WITH verification AS (
    SELECT 
        l.id_livre,
        u.id_utilisateur,
        l.disponible AS livre_dispo,
        (u.id_utilisateur IS NOT NULL) AS utilisateur_valide
    FROM 
        Livre l
    CROSS JOIN 
        Utilisateurs u
    WHERE 
        l.id_livre = 123  -- Remplacez par l'ID du livre
        AND u.id_utilisateur = 456  -- Remplacez par l'ID utilisateur
)
INSERT INTO Emprunts (
    id_utilisateur,
    id_livre,
    date_emprunt,
    date_retour_prevue,
    statut
)
SELECT 
    id_utilisateur,
    id_livre,
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '15 days',
    'en cours'
FROM 
    verification
WHERE 
    livre_dispo AND utilisateur_valide;

-- Si aucune ligne n'a été insérée, déclencher une exception
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Emprunts WHERE id_livre = 123 AND date_retour_reelle IS NULL) THEN
        RAISE EXCEPTION 'Emprunt impossible : livre non disponible ou utilisateur invalide';
    END IF;
END $$;

-- Mettre à jour la disponibilité si l'insertion a réussi
UPDATE Livre 
SET disponible = FALSE 
WHERE id_livre = 123 
AND EXISTS (SELECT 1 FROM Emprunts WHERE id_livre = 123 AND date_retour_reelle IS NULL);

COMMIT;
-- ROLLBACK; -- En cas d'erreur (décommenter si nécessaire)
-- =========================================
-- Mettre à jour le statut disponible du livre: Vérifier que le livre n’est pas déjà emprunté (disponible = FALSE)
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- 1. Vérifier que le livre existe et n'est pas déjà emprunté
    DECLARE @estDisponible BIT;
    DECLARE @livreExiste BIT;
    
    SELECT 
        @livreExiste = CASE WHEN EXISTS (
            SELECT 1 FROM Livre WHERE id_livre = 123  -- Remplacez par l'ID du livre
        ) THEN 1 ELSE 0 END,
        
        @estDisponible = disponible 
    FROM Livre 
    WHERE id_livre = 123;
    
    -- 2. Valider les conditions
    IF @livreExiste = 0
        THROW 50001, 'Le livre spécifié n''existe pas.', 1;
        
    IF @estDisponible = 0
        THROW 50002, 'Le livre est déjà emprunté (non disponible).', 1;
    
    -- 3. Mettre à jour le statut si tout est valide
    UPDATE Livre 
    SET disponible = 0  -- FALSE
    WHERE id_livre = 123;
    
    -- 4. Confirmer l'opération
    PRINT 'Le statut du livre a été mis à jour avec succès (disponible = FALSE)';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
    PRINT 'Erreur: ' + ERROR_MESSAGE();
END CATCH;
-- Supprimer tous les commentaires des utilisateurs inactifs (ceux qui n’ont jamais emprunté de livre).
-- Méthode sécurisée avec transaction
BEGIN TRANSACTION;

-- 1. D'abord identifier les utilisateurs inactifs et leurs commentaires
SELECT 
    u.id_utilisateur,
    u.nom,
    COUNT(c.id_commentaire) AS nombre_commentaires
FROM 
    Utilisateurs u
LEFT JOIN 
    Emprunts e ON u.id_utilisateur = e.id_utilisateur
JOIN 
    Commentaires c ON u.id_utilisateur = c.id_utilisateur
WHERE 
    e.id_emprunt IS NULL
GROUP BY 
    u.id_utilisateur, u.nom;

-- 2. Si le résultat est correct, procéder à la suppression
DELETE FROM Commentaires
WHERE id_utilisateur IN (
    SELECT u.id_utilisateur
    FROM Utilisateurs u
    LEFT JOIN Emprunts e ON u.id_utilisateur = e.id_utilisateur
    WHERE e.id_emprunt IS NULL
);

-- 3. Vérifier le nombre de commentaires supprimés
SELECT @@ROWCOUNT AS nombre_commentaires_supprimes;

-- Valider ou annuler
-- COMMIT TRANSACTION;  -- Décommenter pour exécuter réellement
-- ROLLBACK TRANSACTION;  -- Décommenter pour annuler (test seulement)

-- Partie 4 : Vues et fonctions SQL
-- Créer une vue appelée Vue_Emprunts_Actifs qui affiche tous les emprunts en cours (sans retour).
CREATE OR REPLACE VIEW Vue_Emprunts_Actifs AS
SELECT 
    e.id_emprunt,
    e.id_utilisateur,
    u.nom AS nom_utilisateur,
    u.email AS email_utilisateur,
    e.id_livre,
    l.titre AS titre_livre,
    l.auteur AS auteur_livre,
    e.date_emprunt,
    e.date_retour_prevue,
    (e.date_retour_prevue - CURRENT_DATE) AS jours_restants,
    CASE 
        WHEN e.date_retour_prevue < CURRENT_DATE THEN 'En retard'
        ELSE 'En cours'
    END AS statut_emprunt
FROM 
    Emprunts e
JOIN 
    Utilisateurs u ON e.id_utilisateur = u.id_utilisateur
JOIN 
    Livre l ON e.id_livre = l.id_livre
WHERE 
    e.date_retour_reelle IS NULL
ORDER BY 
    e.date_retour_prevue ASC;
-- Créer une fonction SQL nb_emprunts_utilisateur(id_utilisateur INT) qui retourne le nombre d’emprunts effectués par un utilisateur donné.
CREATE OR REPLACE FUNCTION nb_emprunts_utilisateur(id_utilisateur INT) 
RETURNS INTEGER AS $$
DECLARE
    nombre_emprunts INTEGER;
BEGIN
    SELECT COUNT(*) INTO nombre_emprunts
    FROM emprunts
    WHERE utilisateur_id = id_utilisateur;
    
    RETURN nombre_emprunts;
END;
$$ LANGUAGE plpgsql;