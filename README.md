# Project SAS (2008 - Projet Etudiant "LP Conception de Systèmes Décisionnels")
Le but du projet est d’aider un vendeur de véhicules de sport, qui souhaite rassurer sa clientèle
sur un investissement pérenne. L’idée de base est que le commercial assure la sécurité de ses
clients, dans l’acquisition d’une voiture de sport ou de haut de gamme, qui peut-être un
placement plus ou moins à long terme pour un client ; sachant que ce financement peut
s’avouer être imprudent ; en s’appuyant sur une base de données comprenant des véhicules de
collection, de sport ou de haut de gamme. L’information de ces véhicules sera constituée
d’une partie sur la description de l’automobile et d’autre part, la tendance de ses valeurs
financières au cours du temps, dont son coût à la commercialisation et de ses différentes aux
enchères ; pour cette même voiture ou semblable à celle qui est présentée.

# Objectifs
Le projet consiste à réaliser une application dynamique au travers de plusieurs pages web,
listant les différents véhicules de collection, enregistrés dans une base de données. En
présentant, leurs différentes caractéristiques primaires. Pour définir chacune de ces voitures, il
convient en outre de les présenter, et d’y rattacher des éléments clés concernant leur valeur.
Pour cette étude, il a été convenu d’y ajouter une mise en forme, la plus adaptée possible à
cette application.

Plusieurs contraintes ont été affectées à la réalisation de ce projet. Dans un premier temps, les
éléments de reporting doivent uniquement utiliser trois techniques distinctes, qui sont : les
procédures TABULATE et REPORT, ainsi que l’ODSOUT dans une étape DATA ; du
module SAS/BASE. Ces techniques seront définies dans le prochain chapitre. D’autre part,
l’utilisation de la procédure PRINT, du module SAS/BASE, n’est pas autorisée pour la
conception de cet ouvrage.

Pour ce projet, nous ne conserverons que les automobiles, dont nous connaissons leurs
caractéristiques et leurs valeurs aux enchères. Chaque voiture sera représentée par une table,
qui contiendra sa description et ses différentes valeurs financières de début (coûts initiaux) et
de fin (coûts des enchères). Une page web sera composée de plusieurs lignes, sachant qu’une
ligne correspondra à une voiture, en fonction de son année de mise en circulation avec le coût
à la commercialisation de celle-ci, et la moyenne des coûts des véhicules vendus aux
enchères. Les valeurs financières seront exprimées en euros constant (€). De plus, on y
déterminera la progression de sa valeur (en %), entre son coût initial et la moyenne des coûts
des voitures semblables à celle-ci vendus aux enchères ; ainsi que son délai de conservation
entre l’année de mise en circulation et sa date aux enchères. Toutes ces informations seront
affichées au sein d’un tableau de données.

Pour la réalisation de cette application, il a fallu créer une macro qui devait concevoir autant
de rapports que de véhicules complets ; c’est-à-dire ses données initiales et enchères, ainsi
que ses éléments clés primaires. Ces rapports figureront sur des feuilles html distinctes et
comporter un nom unique (xxx.html), pour chaque automobile. Cette application sera
constituée de plusieurs liens distincts entre le document initial et les documents finaux.

## Contact
Auteur - Julien CHANU
Email - julienchanu@gmail.com
