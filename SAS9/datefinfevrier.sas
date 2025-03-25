data a;
 dt='15Feb2005'd; 
 fin=intnx('MONTH',dt,0,'E');/*Begin,Middle,Sameday,End*/
	output;
 dt='15Feb2006'd; 
 fin=intnx('MONTH',dt,0,'E');/*Begin,Middle,Sameday,End*/
	output;
 dt='15Feb2007'd; 
 fin=intnx('MONTH',dt,0,'E');/*Begin,Middle,Sameday,End*/
	output;
dt='15Feb2008'd; 
 fin=intnx('MONTH',dt,0,'E');/*Begin,Middle,Sameday,End*/
	output;
format dt fin ddmmyy10.;
run;

proc print;run;
