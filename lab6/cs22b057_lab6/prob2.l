%{
#include<stdio.h>
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

"++" {append(yytext);return INC;}
"--" {append(yytext);return DEC;}
"+=" {append(yytext);return PASN;}
"-=" {append(yytext);return MASN;}
"*=" {append(yytext);return SASN;}
"/=" {append(yytext);return DASN;}
({num}|{num2}) {append(yytext);return NUM;} 
{iden} {append(yytext);return IDEN;}
{ws} {append(yytext);}
. {append(yytext);return yytext[0];}

%%

