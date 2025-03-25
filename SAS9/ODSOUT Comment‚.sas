libname donnees "D:\LP CSD\Cours\SAS Macro\donnees";
filename sortie "D:\LP CSD\Cours\SAS Macro\donnees";


proc sql;
 create table work.socio as select
 	sitfam, sexe, sum(sum(prim1),sum(prim2),sum(prim3),sum(prim4)) as p_tot,
		count (distinct nopol) as nb_contrat
		from donnees.police
		group by sitfam, sexe
		order by sitfam, sexe;
run;quit;

ods html path=sortie 
	file="fichier.html" style=statdoc;
title "Les enfants, les sous et la situation de famille";
title2 "Mais en fait c'est pour la bonne cause!";
	data a;
		set socio end=fin_fic;
		by sitfam sexe;
	/*On déclare l'objet ODSOUT sur la 1ère observation avant le*/
		/*début de la boucle qu'est une étape DATA*/
		if _n_=1 then do;
			declare odsout mis_form();
			/*L'objet doit avoir un nom... Pour l'exemple c'est mis_form*/
				mis_form.title(TEXT:"Par situation de famille et code Sexe");
			/*On trace une ligne*/
				mis_form.Line();
				mis_form.title(TEXT:"Quelques statistiques");
			/*On insère une image*/
				mis_form.Image(TEXT:"C:\Users\erwan\Pictures\langoustine.bmp");
			/*On début un tableau*/
				mis_form.table_start("tableau ODSOUT...");
				/*à l'intérieur duquel on crée une ligne*/
				/*Cette ligne est de type Entête (Heading)*/
					mis_form.row_start(type:"HEADING");
					/*Dans cette ligne on crée une cellule fusionnée sur deux lignes */
						mis_form.format_cell(text:"Situation#Famille",
											ROW_SPAN:2,
											SPLIT:"#",
											OVERRIDES:"VJUST=MIDDLE");
					/*A la suite, on crée une Nouvelle cellule fusionnée sur deux lignes */
						mis_form.format_cell(text:"Sexe",
											ROW_SPAN:2,
											OVERRIDES:"VJUST=MIDDLE");
					/*Dans cette ligne on crée une Nouvelle cellule fusionnée sur deux colonnes */
						mis_form.format_cell(text:"Indicateurs",
											COLUMN_SPAN:2,
											OVERRIDES:"JUST=CENTER");
					mis_form.row_end();
					mis_form.row_start(type:"HEADING");
					/*On crée une nouvelle ligne (en dessous d'indicateurs par construction)*/
						mis_form.format_cell(text:"Prime");
						mis_form.format_cell(text:"Nb contrats");
					mis_form.row_end();
		end; /*Fin du traitement initial*/

		if first.sitfam then do; /*Si l'on est sur la 1ère occurence d'une situation de famille*/
			mis_form.row_start(type:"HEADING");
			/*On crée dans ce tableau de 4 colonnes une cellule fusionnée sur 4*/
			/*Avec les valeurs de sitfam obtenue de cette observation*/
				mis_form.format_cell(text:"Mesure pour la situation "||sitfam,
									COLUMN_SPAN:4,
									OVERRIDES:"JUST=CENTER");
			mis_form.row_end();
		end;
		mis_form.row_start();
		/*Il ne reste plus qu'à renseigner dans l'ordre les valeurs des cellules*/
		/*Auquelles il convient de donner un format adéquat*/
			mis_form.format_cell(text:sitfam);
			mis_form.format_cell(text:sexe);
			mis_form.format_cell(text:put(p_tot,numx12.2));
			mis_form.format_cell(text:put(nb_contrat,numx12.0));
		mis_form.row_end();
		if last.sitfam and fin_fic ne 1 then do;
		/*On crée dans le tableau une ligne de rupture, sauf pour la dernière observation*/
			mis_form.row_start(type:"HEADING");
				mis_form.format_cell(text:'',
									COLUMN_SPAN:4,
									OVERRIDES:"JUST=CENTER");
			mis_form.row_end();
		end;
	if fin_fic then mis_form.table_end();
run;
ods html close;
