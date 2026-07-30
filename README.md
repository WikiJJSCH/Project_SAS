# Project SAS (2008 - Projet Etudiant "LP Conception de Systèmes Décisionnels")
Le but du projet est d'aider un vendeur de véhicules de sport à rassurer sa clientèle sur la
pérennité de son investissement : l'acquisition d'une voiture de sport ou de haut de gamme peut
constituer un placement à plus ou moins long terme, mais ce financement peut aussi s'avérer
imprudent. L'application s'appuie sur une base de données de véhicules de collection, de sport
ou de haut de gamme, décrivant chaque automobile ainsi que l'évolution de sa valeur financière
dans le temps (coût à la commercialisation puis prix constatés aux enchères pour ce modèle ou
un modèle similaire).

# Objectifs
Réaliser une application web dynamique, composée de plusieurs pages, listant les véhicules de
collection enregistrés en base avec leurs caractéristiques principales et les éléments clés de
leur valeur, le tout mis en forme de façon adaptée.

Contraintes du projet : les éléments de reporting doivent utiliser exclusivement trois techniques
du module SAS/BASE — les procédures TABULATE et REPORT, ainsi que l'objet ODSOUT dans
une étape DATA. L'usage de la procédure PRINT est interdit.

Seules sont conservées les automobiles dont on connaît à la fois les caractéristiques et les
valeurs aux enchères. Chaque voiture est représentée par une table contenant sa description et
ses valeurs financières de début (coût initial) et de fin (coût aux enchères), en euros constants
(€). Une page web liste, par voiture, son année de mise en circulation, son coût à la
commercialisation, la moyenne des coûts constatés aux enchères pour des véhicules similaires,
la progression de sa valeur (en %) et son délai de conservation (de la mise en circulation à la
vente aux enchères).

Une macro génère, pour chaque véhicule, une page html distincte au nom unique (xxx.html),
reprenant ses données initiales et d'enchères ainsi que ses éléments clés ; l'ensemble de ces
pages est relié par des liens hypertextes entre le document initial et les documents finaux.

## ▶ Utilisation
https://wikijjsch.github.io/Project_SAS/

## Contact
Auteur - Julien CHANU
Email - julienchanu@gmail.com
