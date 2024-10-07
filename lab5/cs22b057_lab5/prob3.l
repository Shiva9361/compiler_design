%{
#include<stdio.h>
#include<string.h>
#include"y.tab.h"
char buffer[2048];

void append(const char* str) {
    if (strlen(buffer) + strlen(str) < 2048) {
        strcat(buffer,str);
    } else {
        fprintf(stderr, "Buffer overflow error!\n");
        exit(1);
    }   
}
%}
ws [ \t]
int [[:digit:]]+
float ([[:digit:]]+\.[[:digit:]]*|[[:digit:]]*\.[[:digit:]]+)
iden [[:alpha:]][[:alnum:]]*

%%

{int} {append(yytext);strcpy(yylval.str,yytext);return INT;}
{float} {append(yytext);strcpy(yylval.str,yytext);return FLOAT;}
{iden} {append(yytext);strcpy(yylval.str,yytext);return IDEN;}
"+" {append(yytext);strcpy(yylval.str,yytext);return PLUS;}
"-" {append(yytext);strcpy(yylval.str,yytext);return MINUS;}
"*" {append(yytext);strcpy(yylval.str,yytext);return STAR;}
"/" {append(yytext);strcpy(yylval.str,yytext);return DIV;}
"="   {append(yytext);strcpy(yylval.str,yytext);return EQUAL;}
"%" {append(yytext);strcpy(yylval.str,yytext);return MOD;}
"(" {append(yytext);strcpy(yylval.str,yytext);return LPAREN;}
")" {append(yytext);strcpy(yylval.str,yytext);return RPAREN;}
{ws}+ ;
. {append(yytext);return yytext[0];}
%%
