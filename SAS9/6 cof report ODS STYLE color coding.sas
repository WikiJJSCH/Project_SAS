proc format;
 value upcent low-<100="white"
 				100-high="#FF0099";
value font low-50="Verdana"
			50<-high="Arial";
				run;

ods html path="C:\13ii\Missions\Educasoft\COFINOGA" file="report et style.html" style=statdoc;
proc report data=sashelp.class nowindows headline headskip

style(HEADER)={font_face='Verdana'}
style(SUMMARY)={background=#9aadc7 font_weight=bold};

/*Définition des colonnes. Attention les colonnes calculées DOIVENT être postérieures aux 
colonnes dont elles sont dérivées*/
columns sex name age ('Mesures' height weight bmi);

define sex / group noprint "Sexe" ;
define name / "Nom" left ;
define age / "Age" analysis mean noprint;
define height / "Hauteur" analysis sum spacing=4 ;
define weight / "Poids" analysis sum center style={background=upcent. font_face=font.};
/*Définition d'une colonne calculée avec mot clé computed*/
define bmi / computed format=8.1 ;
/*Bloc compute qui permet de calculer la valeur de la colonne*/
compute bmi;
bmi=height.sum*height.sum/weight.sum;
endcomp;
/*Insertion d'une ligne AVANT la rupture du code sexe (une par groupe)*/
compute before sex / style={background=#9aadc7 foreground=blue};
line 'Age moyen pour code ' sex $1. ' : ' age.mean;
endcomp;
compute after sex;
line ' ' ;
endcomp;
/*Sommes/Moyennes pour les colonnes de type analysis*/
rbreak after / summarize ; /*Niveau général*/
break after sex / summarize DOL; /*Niveau de la rupture + Double surligné (passe pas en web!!)*/
run;
ods html close;
