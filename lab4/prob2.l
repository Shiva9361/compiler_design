%{
#include<stdio.h>
#include"y.tab.h"
#include<stdlib.h>
#include<string.h>
char buffer[1024]="";

void append(const char* str) {
    if (strlen(buffer) + strlen(str) < 1024) {
        strcat(buffer, str);
    } else {
        fprintf(stderr, "Buffer overflow error!\n");
        exit(1);
    }   
}

%}

ws [ \t]
day [[:digit:]]{2}
month30 ([Aa][pP][Rr]|[Jj][Uu][Nn]|[Ss][Ee][Pp]|[Nn][Oo][Vv])
error [[:alpha:]]{3}
month31 ([Jj][aA][Nn]|[Mm][Aa][Rr]|[Mm][Aa][Yy]|[jJ][Uu][Ll]|[aA][Uu][Gg]|[oO][Cc][Tt]|[dD][Ee][Cc]) 
feb ([Ff][Ee][Bb])
year [[:digit:]]{4}
%%

{month30} {yylval.mon.m=0;strcpy(yylval.mon.ma,yytext);append(yytext);return MONTH;}
{month31} {yylval.mon.m=1;strcpy(yylval.mon.ma,yytext);append(yytext);return MONTH;}
{feb} 	  {yylval.mon.m=2;strcpy(yylval.mon.ma,yytext);append(yytext);return MONTH;}
{error}   {yylval.mon.m=3;strcpy(yylval.mon.ma,yytext);append(yytext);return MONTH;}
{year}    {yylval.year=atoi(yytext);append(yytext);return YEAR;}
{day}     {yylval.day=atoi(yytext);append(yytext);return DAY;}
-  		  {append(yytext);return SEP;}	
.         {append(yytext);return yytext[0];} 
 
%%
