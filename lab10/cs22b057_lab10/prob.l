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
"<=" {append(yytext);strcpy(yylval.str,yytext);return LE;}
">=" {append(yytext);strcpy(yylval.str,yytext);return GE;}
"<" {append(yytext);strcpy(yylval.str,yytext);return LT;}
">" {append(yytext);strcpy(yylval.str,yytext);return GT;}
"==" {append(yytext);strcpy(yylval.str,yytext);return EQ;}
"!=" {append(yytext);strcpy(yylval.str,yytext);return NE;}
"||" {append(yytext);strcpy(yylval.str,yytext);return OR;}
"&&" {append(yytext);strcpy(yylval.str,yytext);return AND;}
true {append(yytext);strcpy(yylval.str,yytext);return TR;}
false {append(yytext);strcpy(yylval.str,yytext);return FL;}
while {append(yytext);strcpy(yylval.str,yytext);return WHILE;}
if   {append(yytext);strcpy(yylval.str,yytext);return IF;}
else {append(yytext);strcpy(yylval.str,yytext);return ELSE;}
int {append(yytext);strcpy(yylval.str,yytext);return INT;}
float {append(yytext);strcpy(yylval.str,yytext);return FLOAT;}
char {append(yytext);strcpy(yylval.str,yytext);return CHAR;}
({num}|{num2}) {append(yytext);strcpy(yylval.str,yytext);return NUM;} 
{iden} {append(yytext);strcpy(yylval.str,yytext);return IDEN;}
{ws} {append(yytext);}
<<EOF>> {return EOF;}
. {append(yytext);strcpy(yylval.str,yytext);return yytext[0];}



%%

