%{
#include<stdio.h>
#include<string.h>
#include"y.tab.h"
char buffer[1024]="";
void append(const char* str){
        if (strlen(buffer)+strlen(str)<1024){
                strcat(buffer,str);
        }
}
%}

iden [[:alpha:]_][[:alnum:]_]*
num [[:digit:]]+\.?[[:digit:]]*
num2 [[:digit:]]*\.?[[:digit:]]+
ws [\n\t ]
%%

"++" {append(yytext);strcpy(yylval.str,yytext);return INC;}
"--" {append(yytext);strcpy(yylval.str,yytext);return DEC;}
"+=" {append(yytext);strcpy(yylval.str,yytext);return PASN;}
"-=" {append(yytext);strcpy(yylval.str,yytext);return MASN;}
"*=" {append(yytext);strcpy(yylval.str,yytext);return SASN;}
"/=" {append(yytext);strcpy(yylval.str,yytext);return DASN;}
({num}|{num2}) {append(yytext);strcpy(yylval.str,yytext);return NUM;} 
{iden} {append(yytext);strcpy(yylval.str,yytext);return IDEN;}
{ws} {append(yytext);}
. {append(yytext);strcpy(yylval.str,yytext);return yytext[0];}

%%

