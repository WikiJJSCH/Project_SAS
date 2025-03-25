/*Gestion des dossiers sources et des dossiers de sorties.*/
%let chemin = D:\LP CSD\Projet SAS; /*Chemin à modifier avant de l'éxécution du programme.*/

libname auto "&chemin\Auto\";
filename entree "&chemin\Donnees Etudiants\";
filename sortie "&chemin\Sortie\";
filename image "&chemin\images\";
options fmtsearch = (auto work library) fmterr;

/*Le cours des devises à la date du 06 octobre 2008 à 10H45.*/
%let dm = 1.95583;
%let dollar = 0.7355;
%let livrester = 1.2928;
%let chf = 0.6452;
%let franc = 6.55957;

/*Recodage les modalités des variables Qualité et Conduite de la table auto.enchères.*/
proc format;
	value $qualite
		"OR+", "OR-", "OR" = "Origine"
		"REST+", "REST-", "REST" = "Restaurée"
		"EX+", "EX-", "EX" = "Exceptionnelle"
		"RAR" = "Reste à restaurer"
	;
	value $cond
		"RHD" = "Droite"
		"LHD" = "Gauche"
	;
run;

/*Création de la table auto.encheres*/
data auto.encheres;/*Création de la table auto.encheres.*/
/*Importation du fichier Encheres.txt à partir de la deuxième ligne, ainsi que les valeurs manquantes, le délimiteurs est la virgule ",".*/
	infile entree(Encheres.txt) firstobs=2 missover dsd dlm=",";
/*Insertion de variables et définition de leurs tailles dans la table auto.encheres.*/
	input	ville :$30.
			date_v :$8.
			marque :$20.
			modele :$20.
			type :$50.
			annee :4.
			num_serie :$15.
			conduite :$10.
			kilometrage :6.
			prix_propose :6.
			adjuge :6.
			qualite :$15.
			commentaire :$100.
			devise :$10.
	;
/*Redéfinition de la date de vente aux enchères, pour une meilleur compréhension et pour la définir au format DATE.*/
	if length(date_v) = 8 then do;
		if substr(date_v, 5, 4) = '0000' then
			date_vente = input((substr(date_v, 1, 4) || '0630'), YYMMDD8.);
		else
			date_vente = input(date_v, ANYDTDTE8.);
	end;
	else if length(date_v) = 6 then do;
		date_vente = input((substr(date_v, 1, 6) || '15'), YYMMDD8.);
	end;
	attrib date_vente format= DDMMYY10.;
/*Attribution de la modalité Euros, pour les véhicules ayant un champ vide dans la variable devise.*/
	if devise = "" then
		devise = 'Euros';
/*Conversion des prix proposés et des prix vendus en Euros.*/
	if devise = "DM" then
		propose = prix_propose / &dm;
	else if devise = "Livre ster" then
		propose = prix_propose * &livrester;
	else if devise = "Dollar US" then
		propose = prix_propose * &dollar;
	else if devise = "Euros" then
		propose = prix_propose;
	else if devise = "CHF" then
		propose = prix_propose * &chf;
	else if devise = "FF" then
		propose = prix_propose / &franc;
	if devise = "DM" then
		vendu = adjuge / &dm;
	else if devise = "Livre ster" then
		vendu = adjuge * &livrester;
	else if devise = "Dollar US" then
		vendu = adjuge * &dollar;
	else if devise = "Euros" then
		vendu = adjuge;
	else if devise = "CHF" then
		vendu = adjuge * &chf;
	else if devise = "FF" then
		vendu = adjuge / &franc;
	dev = "Euros";
/*Extraction de l'année de vente aux enchères.*/
	annee_vente = YEAR(date_vente);
/*Application de la procédure FORMAT précédemment.*/
	format conduite $cond.;
	format qualite $qualite.;
/*Définition de la taille des variables propose et vendu.*/
	format propose 15.0;
	format vendu 15.0;
/*Attribution de la modalité Autre, pour les voitures qui ne possédent pas de type.*/
	if type = "" then type = "Autre";
/*Conserver uniquement les variables ci-dessous dans la table auto.encheres.*/
	keep ville marque modele type annee num_serie conduite kilometrage qualite commentaire date_vente annee_vente propose vendu dev;
run;

/*Création de la table auto.description*/
data auto.description;
/*Importation du fichier auto.csv à partir de la deuxième ligne, ainsi que les valeurs manquantes,
le délimiteurs est le point-virgule ";".*/
	infile entree(description auto.csv) firstobs=2 missover dsd dlm=";";
/*Insertion de variables et définition de leurs tailles dans la table auto.description.*/
	input	marque :$30.
			modele :$30.
			type :$20.
			carrosserie :$20.
			deb_construction :$6.
			fin_construction :$6.
			nb_exemplaire :5.
			type_moteur :$4.
			turbo :$3.
			cv_din :3.
			vitesse :3.
			nb_place :1.
	;
/*Redéfinition de la date du début de fabrication de la voiture, pour une meilleur compréhension et pour la définir au format DATE.*/
	if length(deb_construction) = 6 then
		date_debut = input((substr(deb_construction, 1, 6) || '01'),YYMMDD8.);
	else if length(deb_construction) = 4 then
		date_debut = input((substr(deb_construction, 1, 4) || '0101'),YYMMDD8.);
		else date_debut=.;
/*Redéfinition de la date de fin de fabrication de la voiture, pour une meilleur compréhension et pour la définir au format DATE.*/
	if length(fin_construction) = 6 then 
		date_fin = input((substr(fin_construction, 1, 6) || '15'),YYMMDD8.);
	else if length(fin_construction) = 4 then
		date_fin = input((substr(fin_construction, 1, 4) || '1215'),YYMMDD8.);
	else date_fin=.;
	attrib	date_debut format = DDMMYY10.
			date_fin format = DDMMYY10.;
/*Attribuer le dernier jour du mois à la date_fin, pour déterminer la date de fin de fabrication du véhicule.*/
			date_fin=intnx('MONTH',date_fin,0,'E');
	drop deb_construction fin_construction;
/*Attribution de la modalité Autre, pour les voitures qui ne possédent pas de type.*/
	if type = "" then type = "Autre";
run;

/*Création de la table auto.price*/
data auto.price;
/*Importation du fichier Vehicule.txt à partir de la deuxième ligne, ainsi que les valeurs manquantes, le délimiteurs est la virgule ",".*/
	infile entree(Prix Vehicule.txt) firstobs=2 missover dsd dlm=",";
/*Insertion de variables et définition de leurs tailles dans la table auto.price.*/
	input	marque :$20.
			modele :$20.
			type :$20.
			annee :4.
			prix_courant :10.
			devise :$1.
	;
/*Conversion du prix_courant en Euros.*/
	prix_courant = prix_courant / &franc;
	devise = '€';
/*Détermination de la taille de la variable prix_courant.*/
	format prix_courant 15.0;
/*Attribution de la modalité Autre, pour les voitures qui ne possédent pas de type.*/
	if type = "" then type = "Autre";
run;

/*Création de la table auto.ipconso*/
data auto.ipconso;
/*Importation du fichier IPConsommation base 100 1970.csv à partir de la deuxième ligne, ainsi que les valeurs manquantes,
le délimiteurs est le point-virgule ";".*/
	infile entree(IPConsommation base 100 1970.csv) firstobs=2 missover dsd dlm=";";
/*Insertion de variables et définition de leurs tailles dans la table auto.ipconso.*/
	input	annee :4.
			semestre :$2.
			indice_prix :numx10.
	;
run;

/*Création de la table auto.ipconsommation, contenant les variables annee et ip.
La variable ip est une moyenne de l'indice des prix en fonction de l'année.*/
proc sql noprint;
	CREATE TABLE auto.ipconsommation AS SELECT DISTINCT annee, AVG(indice_prix) AS ip 
	FROM auto.ipconso GROUP BY annee;
	/*Suppression de la table auto.ipconso*/
	DROP TABLE auto.ipconso;
quit;

/*Sélectionner l'indice prix le plus récent et le sauvegarder dans une liste listip.*/
proc sql noprint;
	SELECT ip into: listip separated by "£"
	FROM auto.ipconsommation
	WHERE annee = (SELECT MAX(annee) FROM auto.ipconsommation);
quit;

/*Programmer une macro iprecent qui permet de stocker l'indice prix le plus récent dans une macro-variable ip_act,
en fonction de la liste listip.*/
%macro iprecent;
	%do i = 1 %to 1;
	%global ip_act;
	%let ip_act = %scan(&listip, &i, "£");
	%end;
%mend;

/*Exécution de la macro iprecent.*/
%iprecent;

/*Afficher l'indice prix le plus récent dans le journal(log), pour connaître sa valeur.*/
%put &ip_act;

/*Création de la table auto.enchere, contenant toutes les variables de la table auto.encheres, sauf les variables propose et vendu,
qui ont été remplacées par prix_propose et prix_vendu, pour pouvoir appliquer les indices prix en fonction de l'année sur une base 100
à partir de 1970.*/
proc sql noprint;
	CREATE TABLE auto.enchere AS SELECT ville, marque, modele, type, encheres.annee, num_serie, conduite, kilometrage, qualite,
	commentaire, date_vente,
	((((propose * 100) / ip) * &ip_act) / 100) AS prix_propose,
	((((vendu * 100) / ip) * &ip_act) / 100) AS prix_vendu, dev
	FROM auto.encheres, auto.ipconsommation
	WHERE annee_vente = ipconsommation.annee;
/*Suppression de la table auto.ipencheres.*/
	DROP TABLE auto.encheres;
quit;

/*Création de la table auto.prix, contenant toutes les variables de la table auto.encheres, sauf la variable prix_courant,
qui a été remplacée par prix_achat, pour pouvoir appliquer les indices prix en fonction de l'année sur une base 100
à partir de 1970.*/
proc sql noprint;
	CREATE TABLE auto.prix AS SELECT marque, modele, type, price.annee, ((((prix_courant * 100) / ip) * &ip_act) / 100) AS prix_achat,
	devise
	FROM auto.price, auto.ipconsommation
	WHERE price.annee = ipconsommation.annee;
/*Suppression de la table auto.price.*/
	DROP TABLE auto.price;
quit;

/*Modification de la table auto.enchere, les caractères spéciaux ont été remplacés par des espaces et le caractère é par un e,
et de supprimer tous les espaces dans les variables marque, modèle et type, pour pouvoir créer une sorte de clé primaire nommé cle.*/
data auto.enchere;
	set auto.enchere;
	mark = COMPRESS(marque, "-");
	mark = COMPRESS(mark);
	model = COMPRESS(modele, "-");
	model = TRANWRD(model, "é", "e");
	model = COMPRESS(model);
	typ = TRANWRD(type, "-", " ");
	typ = TRANWRD(typ, "é", "e");
	typ = TRANWRD(typ, "/", " ");
	typ = TRANWRD(typ, "+", " ");
	typ = TRANWRD(typ, ".", " ");
	typ = TRANWRD(typ, ",", " ");
	typ = COMPRESS(typ);
	cle = TRIM(mark)||TRIM(model)||TRIM(typ);
run;

/*Modification de la table auto.description, les caractères spéciaux ont été remplacés des espaces et le caractère é par un e,
et de supprimer tous les espaces dans les variables marque, modèle et type, pour pouvoir créer une sorte de clé primaire nommé cle.*/
data auto.description;
	set auto.description;
	mark = COMPRESS(marque, "-");
	mark = COMPRESS(mark);
	model = COMPRESS(modele, "-");
	model = TRANWRD(model, "é", "e");
	model = COMPRESS(model);
	typ = TRANWRD(type, "-", " ");
	typ = TRANWRD(typ, "é", "e");
	typ = TRANWRD(typ, "/", " ");
	typ = TRANWRD(typ, "+", " ");
	typ = TRANWRD(typ, ".", " ");
	typ = TRANWRD(typ, ",", " ");
	typ = COMPRESS(typ);
	cle = TRIM(mark)||TRIM(model)||TRIM(typ);
run;

/*Modification de la table auto.prix, les caractères spéciaux ont été remplacés des espaces et le caractère é par un e,
et de supprimer tous les espaces dans les variables marque, modele et type, pour pouvoir créerune sorte de clé primaire nommé cle.*/
data auto.prix;
	set auto.prix;
	mark = COMPRESS(marque, "-");
	mark = COMPRESS(mark);
	model = COMPRESS(modele, "-");
	model = TRANWRD(model, "é", "e");
	model = COMPRESS(model);
	typ = TRANWRD(type, "-", " ");
	typ = TRANWRD(typ, "é", "e");
	typ = TRANWRD(typ, "/", " ");
	typ = TRANWRD(typ, "+", " ");
	typ = TRANWRD(typ, ".", " ");
	typ = TRANWRD(typ, ",", " ");
	typ = COMPRESS(typ);
	cle = TRIM(mark)||TRIM(model)||TRIM(typ);
run;

/*Trier la table auto.enchere par ordre alphabétique à partir de la variable cle.*/
proc sort data=auto.enchere;
	by cle;
run;

/*Trier la table auto.description par ordre alphabétique à partir de la variable cle.*/
proc sort data = auto.description;
	by cle;
run;

/*Trier la table auto.prix par ordre alphabétique à partir de la variable cle.*/
proc sort data = auto.prix;
	by cle;
run;

/*Création de la table auto.cars qui est une jointure des tables auto.description et auto.prix,
par la variable cle qui est une clé primaire. Conservation des variables marque, modele, type, annee, carrosserie, type_moteur,
cv_din, date_debut, date_fin, prix_achat, devise, mark, model et cle.*/
data auto.cars;
	merge auto.description auto.prix;
	by cle;
	keep marque modele type annee carrosserie type_moteur cv_din date_debut date_fin prix_achat devise mark model cle;
run;

/*Création de la table auto.voitures qui est une jointure des tables auto.cars et auto.enchere,
par la variable cle qui est une clé primaire. Conservation des variables marque, modele, type, annee, carrosserie, type_moteur,
cv_din, date_debut, date_fin, prix_achat, date_vente, prix_propose, prix_vendu, dev, mark, model et cle.*/
data auto.voitures;
	merge auto.cars auto.enchere;
	by cle;
	keep marque modele type annee carrosserie type_moteur cv_din date_debut date_fin prix_achat date_vente prix_propose
	prix_vendu dev mark model cle;
run;

/*Modification de la table auto.voitures, en ajoutant la variable progression qui calcule la progression du prix vente du véhicule
à l'enchère par rapport au prix neuf de la voiture. La variable delai correspond à la différence de temps entre l'année du véhicule
et l'année de vente aux enchères, calculée en semestre.*/
data auto.voitures;
	set auto.voitures;
	progression = (((prix_vendu - prix_achat) / prix_achat) * 100);
	delai = ((YEAR(date_vente) - annee) * 2);
	annee_vente = YEAR(date_vente);
/*Attribution de la modalité 0, pour les voitures ne possédant pas d'année de vente aux enchères.*/
	if annee_vente = "" then annee_vente = 0;
/*Attribution de la modalité 0, pour les voitures ne possédant pas d'année de mise en circulation.*/
	if annee = "" then annee = 0;
/*Attribution de la modalité Inconnu, pour les voitures ne possédant pas de carrosserie.*/
	if carrosserie = "" then carrosserie = "Inconnu";
/*Attribution de la modalité Inconnu, pour les voitures ne possédant pas de moteur.*/
	if type_moteur = "" then type_moteur = "Inconnu";
/*Attribution de la modalité 0, pour les voitures n'ayant pas de puissance au niveau moteur.*/
	if cv_din = "" then cv_din = 0;
/*Attribution de la modalité 0, pour les voitures ne possédant pas de date de début de fabrication.*/
	if date_debut = "" then date_debut = 0;
/*Attribution de la modalité 0, pour les voitures ne possédant pas de date de fin de fabrication.*/
	if date_fin = "" then date_fin = 0;
/*Détermination de la taille des variables prix_propose, prix_vendu, prix_achat, progression et delai.*/
	format prix_propose 15.;
	format prix_vendu 15.;
	format prix_achat 15.;
	format progression 5.;
	format delai 3.;
run;

proc sql noprint;
/*Suppression des voitures n'ayant pas été vendu aux enchères, et n'ayant pas de description.*/
	DELETE FROM auto.voitures WHERE annee_vente = 0;
	DELETE FROM auto.voitures WHERE annee = 0;
	DELETE FROM auto.voitures WHERE carrosserie = "Inconnu"
	AND type_moteur = "Inconnu"
	AND cv_din = 0
	AND date_debut = 0
	AND date_fin = 0;
quit;

data auto.voitures;
	set auto.voitures;
/*Recodage des variables, de façon que ce soit compréhensible.*/
	if carrosserie = "Inconnu" then carrosserie = "";
	if type_moteur = "Inco" then type_moteur = "";
	if cv_din = 0 then cv_din = "";
	if date_debut = 0 then date_debut = "";
	if date_fin = 0 then date_fin = "";
run;

proc sql noprint;
/*Création de la table auto.marque à partir de la table auto.voitures, contenant seulement les variables marque et mark,
groupé par marque.*/
	CREATE TABLE auto.marque AS SELECT DISTINCT marque, mark
	FROM auto.voitures
	ORDER BY marque;

/*Création de la table auto.modele à partir de la table auto.voitures, contenant seulement les variables marque, mark, modele et model,
groupé par marque.*/
	CREATE TABLE auto.modele AS SELECT DISTINCT marque, mark, modele, model
	FROM auto.voitures
	ORDER BY marque;

/*Suppression de la table auto.cars.*/
	DROP TABLE auto.cars;
quit;

/*Création de la table auto.formatmarque à partir de la table auto.marque, qui permettra de renommer les modalités de la variable marque.*/
data auto.formatmarque;
	set auto.marque;
/*Attribution et nomination de variables dans la table auto.formatmarque.*/
	attrib START
		LABEL = "START";
	attrib LABEL
		LABEL = "LABEL";
	attrib FMTNAME
		LABEL = "FMTNAME";
	attrib TYPE
		LABEL = "TYPE";
/*Nom de la procédure FORMAT qui sera appliqué à la variable marque.*/
	FMTNAME = "markvoiture";
/*Insertion des différentes modalités de la variable marque dans la variable START.*/
	START = marque;
/*Détermination du type alphanumérique pour le format de la variable marque.*/
	TYPE = "C";
/*Codage des modalités de la variable marque en lien hypertexte, pour les sorties en html.*/
	LABEL = '<A HREF="'||COMPRESS(mark)||'.html">'||TRIM(START)||"</a>";
run;

/*Création de la table auto.formatmodele à partir de la table auto.modele, qui permettra de renommer les modalités de la variable modele.*/
data auto.formatmodele;
	set auto.modele;
/*Attribution et nomination de variables dans la table auto.formatmodele.*/
	attrib START
		LABEL = "START";
	attrib LABEL
		LABEL = "LABEL";
	attrib FMTNAME
		LABEL = "FMTNAME";
	attrib TYPE
		LABEL = "TYPE";
/*Insertion des différentes modalités de la variable modele dans la variable START.*/
	START = modele;
/*Nom de la procédure FORMAT qui sera appliqué à la variable modele.*/
	FMTNAME = "modelevoiture";
/*Détermination du type alphanumérique pour le format de la variable modele.*/
	TYPE = "C";
/*Codage des modalités de la variable marque en lien hypertexte, pour les sorties en html.*/
	LABEL = '<A HREF="'||COMPRESS(mark)||COMPRESS(model)||'.html">' ||TRIM(START)|| "</a>";
run;

/*Création de la table auto.formatvoiture par la jointure des tables auto.formatmarque et auto.formatmodele.*/
data auto.formatvoiture;
	set auto.formatmarque auto.formatmodele;
run;

/*Application de la définition de nos propres formats pour la lecture et pour l'écriture des valeurs des variables marque et modele.*/
proc format CNTLIN = auto.formatvoiture LIBRARY = auto;
run;

/*Modification de la table auto.marque, pour stocker le chemin des logos des différentes marques et pour l'affectation de lien hypertexte.*/
data auto.marque;
	set auto.marque;
	lien_logo = ("<A href ='"||TRIM(mark)||".html'><img border='0' src = '../images/"||TRIM(marque)||".png'></A>");
run;

/*Trier la table auto.marque par ordre alphabétique de la variable marque.*/
proc sort data = auto.marque;
	by marque;
run;

/*Création de la page web Voiture.html en y appliquant notre propre feuille de style.*/
ods html path = sortie file="Voiture.html" (title = "Marques des voitures") stylesheet = (url = 'style.css');
/*Titre de la page web.*/
	title "Liste des marques de voitures";
	data auto.vehicule;
		set auto.marque end=fin_fic;
		by marque;
/*On déclare l'objet ODSOUT sur la 1ère observation avant le début de la boucle qu'est une étape DATA.*/
		if _n_=1 then do;
/*L'objet ODSOUT doit avoir un nom. Pour le projet, c'est mis_form.*/
			declare odsout mis_form();
/*On construit un tableau.*/
				mis_form.table_start();
		end;
		if first.marque then do;
/*On ajoute une ligne dans le tableau.*/
			mis_form.row_start();
			mis_form.row_end();
/*On rajoute une ligne dans le tableau. Cette ligne est de type en-tête (HEADING).*/
			mis_form.row_start(type:"HEADING");
/*Dans cette ligne, on remplit les cellules contenant les différentes modalités de la variable lien_logo.*/	
				mis_form.format_cell(text:lien_logo,
									OVERRIDES:"JUST=CENTER", OVERRIDES:"VJUST=MIDDLE");
/*Dans cette ligne, on remplit les cellules contenant les différentes modalités de la variable marque,
en y appliquant le format crée précédemmant.*/
				mis_form.format_cell(text:put(marque, $markvoiture.),
									OVERRIDES:"JUST=CENTER", OVERRIDES:"VJUST=MIDDLE");
			mis_form.row_end();
		end;
/*Fin du tableau de l'ODSOUT.*/
	if fin_fic then mis_form.table_end();
/*Information de mise à jour dans le pied page de la page web.*/
	footnote "Mis à jour le %sysfunc(today(), ddmmyy) à %sysfunc(time(),hhmm)";
run;
/*Fermeture de la page web Voiture.html.*/
ods html close;

/*Sélectionner les marques de voitures de la variable marque de la table auto.voitures et les stocker dans la liste listmarque.*/
proc sql noprint;
	SELECT DISTINCT marque into: listmarque separated by "£"
	FROM auto.voitures;
quit;

/*Sauvegarder le nombre de marques de voitures dans la macro-variable maxmarque.*/
%let maxmarque = &sqlobs;

/*Sélectionner les marques de voitures de la variable mark de la table auto.voitures et les stocker dans la liste listmark.*/
proc sql noprint;
	SELECT DISTINCT mark into: listmark	separated by "£"
	FROM auto.voitures;
quit;

/*Création de la macro voiture.*/
%macro voiture;
/*Boucle j partant de 1 jusqu'au nombre de marques différentes.*/
	%do j = 1 %to &maxmarque;

/*Stockage des marques listées dans la liste listmarque, dans la macro-variable marque.*/
		%let marque = %scan(&listmarque, &j, "£");
/*Stockage des marque listées dans la liste listmark, dans la macro-variable mark.*/
		%let mark = %scan(&listmark, &j, "£");

/*Création des tables auto.&mark à partir de la table auto.voitures,
sélectionnant des modèles de voitures à partir de la variable marque, en fonction de la marque desvoitures.*/
		proc sql;
			CREATE TABLE auto.&mark AS SELECT DISTINCT modele
			FROM auto.voitures
			WHERE marque = "&marque";
		quit;

/*Création des pages web &mark.html en y appliquant notre propre feuille de style.*/
		ods html path = sortie file = "&mark..html" (title = "&marque") stylesheet = (url = 'style.css');
/*Utilisation de le procédure REPORT pour les tables auo.&mark, avec interdiction d'ouvrir une fenêtre indépendante de windows,
soulignez tous les en-têtes de colonnes et inscription d'une interligne sous toutes les en-têtes de colonnes.*/
			proc report data = auto.&mark nowindows headline headskip;
/*Titres des pages web &mark.html.*/
				title "Liste des modèles des voitures &marque";
				title2;
				title3 "<img src = '../images/&marque..png'>";
/*Création d'un tableau avec une seule colonne comprenant les valeurs de la variable modele des tables auto.&mark.*/ 
				columns modele;
/*Renommer l'en-tête de la colonne modele dans le tableau.*/
				define modele / display "Modèle";
/*Recodage des modalités de la variable modele comprenant les liens hypertextes, avec l'aide la procédure Format CNTLIN réalisée précédemment.*/
				format modele $modelevoitu.;
/*Information de mise à jour et de lien de redirection vers le fichier racine Voiture.html dans le pied page de la page web.*/
				footnote "<A HREF ='Voiture.html'>Liste des marques de voitures</A>";
				footnote2 "Mis à jour le %sysfunc(today(), ddmmyy) à %sysfunc(time(),hhmm)";
			run;
/*Fermeture des pages web &mark.html.*/
		ods html close;

/*Modification des tables auto.&mark à partir de la table auto.voitures,
sélection des modèles de voitures à partir des variables modele et model, en fonction de la marque des voitures.*/
		proc sql noprint;
			CREATE TABLE auto.&mark AS SELECT modele, model
			FROM auto.voitures
			WHERE marque = "&marque";
/*Sélectionner les modèles de voitures de la variable model des tables auto.&mark et de les stocker dans la liste listmodel,
en fonction de la marque des voitures.*/
			SELECT DISTINCT model into: listmodel separated by "£"
			FROM auto.&mark;
/*Sélectionner les modèles de voitures de la variable modele des tables auto.&mark et de les stocker dans la liste listmodele,
en fonction de la marque des voitures.*/
			SELECT DISTINCT modele into: listmodele separated by "£"
			FROM auto.&mark;
		quit;

/*Sauvegarder le nombre de modèles de voitures dans la macro-variable maxmodele, en fonction de la marque de la voiture.*/
		%let maxmodele = &sqlobs;

/*Modification des tables auto.&mark à partir de la table auto.voitures, comprenant uniquement les variables qui nous intéresse,
en fonction de la marque des voitures.*/
		proc sql noprint;
			CREATE TABLE auto.&mark AS SELECT modele, type, annee, carrosserie, type_moteur, cv_din, date_debut, date_fin, prix_achat,
			date_vente, annee_vente, prix_propose, prix_vendu, dev, progression, delai
			FROM auto.voitures
			WHERE marque = "&marque";
		quit;
		
/*Boucle k partant de 1 jusqu'au nombre de modèles différents de la marque des voitures.*/
		%do k = 1 %to &maxmodele;

/*Stockage des modèles listées dans la liste listmodele, dans la macro-variable modele, en fonction de la marque des voitures.*/
			%let modele = %scan(&listmodele, &k, "£");
/*Stockage des modèles listées dans la liste listmodel, dans la macro-variable model, en fonction de la marque des voitures.*/
			%let model = %scan(&listmodel, &k, "£");

/*Création des tables auto.&mark&model à partir des tables auto.&mark,
sélectionnant uniquement les variables qui nous intéresse pour faire la description d'une voiture,
en fonction de la marque et du modèle des voitures. Regrouper par type.*/
			proc sql noprint;
				CREATE TABLE auto.&mark&model AS SELECT DISTINCT type, carrosserie, type_moteur, cv_din,
				date_debut, date_fin
				FROM auto.&mark
				WHERE modele = "&modele"
				ORDER BY type;

/*Création des tables auto.&mark&model&model à partir des tables auto.&mark,
sélectionnant uniquement les variables qui nous intéresse pour descrire les valeurs financières d'une voiture,
en fonction de la marque et du modèle des voitures. Regrouper par type.*/
				CREATE TABLE auto.&mark&model&model AS SELECT DISTINCT type, annee, prix_achat, annee_vente, prix_propose, prix_vendu,
				progression, delai
				FROM auto.&mark
				WHERE modele = "&modele"
				ORDER BY annee;
			quit;

/*Création des pages web &mark&model.html en y appliquant notre propre feuille de style.*/
			ods html path = sortie file = "&mark&model..html" (title = "&marque &modele") stylesheet = (url = 'style.css');
/*Titres des pages web &mark&model.html.*/
				title " Description de la &marque &modele";
				title2;
				title3 "<A href ='&mark..html'><img border='0' src = '../images/&marque..png'></A>";

/*Utilisation de le procédure REPORT pour les tables auto.&mark&model, avec interdiction d'ouvrir une fenêtre indépendante de windows,
soulignez tous les en-têtes de colonnes et inscription d'une interligne sous toutes les en-têtes de colonnes.*/
				proc report data = auto.&mark&model nowindows headline headskip;
/*Création d'un tableau a six colonnes comprenant les valeurs des variable type, carrosserie, type_moteur, cv_din, date_debut et date_fin
des tables auto.&mark&model.*/ 
					columns type carrosserie type_moteur cv_din date_debut date_fin;
/*Renommer les en-têtes des colonnes type, carrosserie, type_moteur,cv_din, date_debut et date_fin dans le tableau.*/
					define type / display "Type de &marque &modele";
					define carrosserie / display "Carrosserie";
					define type_moteur / display "Type de motorisation";
					define cv_din / display "Puissance du moteur (en ch)";
					define date_debut / display "Date du début de fabrication du véhicule";
					define date_fin / display "Date de fin de fabrication du véhicule";
					footnote "Mis à jour le %sysfunc(today(), ddmmyy) à %sysfunc(time(),hhmm)";
				run;				

/*Utilisation de le procédure TABULATE pour les tables auto.&mark&model&model.*/
				proc tabulate data = auto.&mark&model&model;
/*Autre titre des pages web &mark&model.html.*/
					title " Les valeurs financières de la &marque &modele";
/*Renommer les en-têtes des colonnes type, annee, prix_achat, annee_vente, prix_propose, prix_vendu, progression et delai
du tableau statistique.*/
					label	type = "Type"
							annee = "Année de mise en circulation"
							prix_achat = "Prix neuf du véhicule"
							annee_vente = "Année de la vente aux enchères"
							prix_propose = "Prix proposé lors de l'enchère"
							prix_vendu = "Prix vendu lors de l'enchère"
							progression = "Evolution du prix depuis sa commercialisation (en %)"
							delai = "Délai de vente (en semestres)";
/*Liste des variables d'analyse sur lesquelles sont effectuées les calculs statistiques.*/
					var prix_achat prix_propose prix_vendu progression delai;
/*Liste des variables de classe définissant les pages, les lignes et les colonnes.*/
					class type annee annee_vente;
/*Définir la construction du tableau statistique, sachant que le tableau peut avoir au maximum trois dimensions.
Avec insertion du logo de la marque dans la boîte vide au-dessus des titres de lignes du tableau statistique,
avec lien de redirection vers la liste des modèles de la marque des voitures, à partir du logo de la marque.*/
					table type * annee_vente, prix_achat * mean prix_propose * mean prix_vendu * mean progression * mean delai * mean /
					BOX = "<A href ='&mark..html'><img border='0' src = '../images/&marque..png'></A>";
					by annee;
/*Renommer les en-têtes aux mots clés définissant les statistiques.*/
					keylabel MEAN = "Moyenne";
/*Information de mise à jour.*/
					footnote "Mis à jour le %sysfunc(today(), ddmmyy) à %sysfunc(time(),hhmm)";
				run;
/*Fermeture des pages web &mark&model.html.*/
			ods html close;
/*Fin de la boucle k.*/
		%end;
/*Fin de la boucle j.*/
	%end;
/*Fermeture de la macro voiture.*/
%mend;
/*Exécution de la macro voiture.*/
%voiture;
