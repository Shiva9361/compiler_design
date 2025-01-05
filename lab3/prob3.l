%{
#include<stdio.h>
#include"y.tab.h"
#include<stdlib.h>
#include<string.h>
%}


day [[:digit:]][[:digit:]]
month30 ([Aa]pr|[Jj]un|[Ss]ep|[Nn]ov)
month31 ([Jj]an|[Mm]ar|[Mm]ay|[jJ]ul|[aA]ug|[oO]ct|[dD]ec) 
feb ([Ff]eb)
wrong [[:alpha:]]{3}
year [[:digit:]]{4}
%%

{month30} {yylval.mon=0;return MONTH;}
{month31} {yylval.mon=1;return MONTH;}
{feb} 	  {yylval.mon=2;return MONTH;}
{wrong}   {yylval.mon=3;return MONTH;}
{year}    {yylval.year=atoi(yytext);return YEAR;}
{day}     {yylval.day=atoi(yytext);return DAY;}
-  		  {return SEP;}	
.         {return yytext[0];} 
 
%%
