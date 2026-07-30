# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Ce dépôt

Ce répertoire (`docs/`) est un sous-dossier du dépôt Git racine `D:\Dev\Project_SAS` (`git rev-parse --show-toplevel` pointe vers la racine, pas vers `docs/`). Il ne contient **aucun code source** : c'est la **sortie générée** par le programme SAS `Voiture.sas` situé à la racine du dépôt — un doublon du dossier `Sortie/` (voir le commit "Duplication du répertoire Sortie en docs"). Toutes les pages `.html` de ce dossier sont produites automatiquement par SAS (ODS HTML) ; elles ne sont pas écrites à la main.

Contexte du projet (voir `README.md` à la racine) : projet étudiant 2008 ("LP Conception de Systèmes Décisionnels") pour un vendeur de voitures de sport/collection. L'application liste les véhicules, leurs caractéristiques, et la progression de leur valeur entre le prix neuf et le prix moyen aux enchères.

## Pipeline de génération (à connaître avant de modifier une page)

Le flux complet part de `../Voiture.sas` :

1. **Import et nettoyage** des données sources (`../Donnees Etudiants/`) dans des tables SAS (`../Auto/*.sas7bdat`) : enchères (`auto.encheres`), descriptions (`auto.description`), prix neufs (`auto.price`), indices des prix à la consommation (`auto.ipconso`) — utilisés pour convertir toutes les valeurs monétaires en euros constants.
2. **Fusion** des tables par une clé composite `cle` (marque + modèle + type, accents et espaces supprimés) en une table unique `auto.voitures`, avec calcul de `progression` (évolution du prix en %) et `delai` (délai de revente en semestres).
3. **Génération de formats SAS** (`proc format CNTLIN`) qui transforment chaque valeur de `marque`/`modele` en lien HTML (`<A HREF="...">`) — c'est ce qui produit la navigation entre pages.
4. **Macro `%voiture`** : boucle sur chaque marque puis chaque modèle pour générer les pages HTML via `ods html path=sortie file="&mark&model..html" ... stylesheet=(url='style.css')`, avec `PROC REPORT` (description technique) et `PROC TABULATE` (valeurs financières). `PROC PRINT` est interdit par les contraintes du projet.

Hiérarchie de pages résultante :
- `Voiture.html` — liste des marques (logos, tableau ODSOUT construit "à la main" en DATA step).
- `<Marque>.html` (ex. `Ferrari.html`) — liste des modèles de la marque, générée par `PROC REPORT`.
- `<Marque><Modèle>.html` (ex. `FerrariF355.html`) — fiche détail d'un modèle : tableau descriptif (`PROC REPORT`) + tableau financier (`PROC TABULATE`), avec le logo de la marque en lien retour.

Convention de nommage des fichiers : concaténation `mark` + `model` sans espaces ni accents (variables `mark`/`model` calculées dans `Voiture.sas` via `COMPRESS`/`TRANWRD`). `index.html` et `index.php` sont la page d'accueil statique (logo "entrez" → `Voiture.html`).

## Modifier une page générée

- **Ne pas éditer le contenu tabulaire ou les données** directement dans un fichier `.html` de `docs/` : ces valeurs viennent des sources sous `../Donnees Etudiants/` et `../Auto/*.sas7bdat` et de la logique de `../Voiture.sas`. Toute correction de données ou de calcul doit se faire dans `Voiture.sas` puis être régénérée (SAS n'est pas exécutable depuis cet environnement — signaler à l'utilisateur qu'une régénération manuelle via SAS est nécessaire).
- Un correctif ponctuel directement dans un fichier HTML généré (typo, encodage) n'est acceptable que comme correctif temporaire — il sera écrasé à la prochaine régénération SAS. Le signaler à l'utilisateur.
- **Encodage** : SAS ODS HTML génère nativement ces pages en **Windows-1252** (balise `<meta charset=windows-1252>` d'origine). Le 29/07/2026, tous les fichiers `.html` de `docs/` ont été réencodés en UTF-8 réel (octets + balise `<meta charset=utf-8>` mis à jour en cohérence) pour corriger un mojibake sur les caractères accentués français. **Si `Voiture.sas` est réexécuté, les pages seront régénérées en Windows-1252** et il faudra rejouer cette conversion (relire les octets en CP1252, réencoder en UTF-8, corriger la balise `charset`) plutôt que de modifier `Voiture.sas` pour changer l'encodage de sortie, sauf demande explicite. `index.html`/`index.php` étaient déjà en UTF-8/ASCII propre et n'ont pas été touchés.
- `style.css` est la feuille de style ODS SAS partagée par toutes les pages générées (classes `.Table`, `.Header`, `.RowHeader`, `.Data`, etc. — noms de classes imposés par le moteur ODS, pas de convention libre). `images/` contient les logos de marques et les fonds d'écran référencés en chemin relatif (`../images/...` depuis les pages, `images/...` depuis `index.html`).
- **Casse des noms de fichiers image** : `Voiture.sas` construit les balises `<img src="...">` avec la casse brute de la variable `marque` (ex. `Ferrari.png`, `BMW.png`, `De Tomaso.png`), alors que les fichiers dans `images/` sont historiquement suivis en minuscules dans Git (`ferrari.png`, `bmw.png`, `de tomaso.png`...). Sous Windows, le système de fichiers étant insensible à la casse (et `core.ignorecase=true` dans ce dépôt), cette incohérence est invisible en local — mais casserait l'affichage des logos sur un déploiement sensible à la casse (ex. Linux/Synology, voir `README.md`). Le 30/07/2026, les 9 logos de marque (`images/*.png`) ont été renommés pour correspondre exactement à la casse attendue par le HTML généré, via un double `git mv` (nécessaire pour que Git enregistre un changement de casse pur malgré `core.ignorecase`). Si de nouvelles marques sont ajoutées via `Voiture.sas`, vérifier que le nom du fichier logo correspondant dans `images/` respecte exactement la casse de la variable `marque`.

## Pas d'outillage de build/lint/test

Il n'y a pas de build, de linter, ni de suite de tests dans ce dossier : ce sont des pages HTML statiques générées. Pour vérifier un changement, ouvrir le fichier `.html` concerné directement dans un navigateur.
