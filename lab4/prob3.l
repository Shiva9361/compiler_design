%{
#include<stdio.h>
#include<string.h>
#include"y.tab.h"
char buffer[1024];
void append(const char* str) {
    if (strlen(buffer) + strlen(str) < 1024) {
        strcat(buffer, str);
    } else {
        fprintf(stderr, "Buffer overflow error!\n");
        exit(1);
    }   
}

%}

AL a*b*c*
ERR [[:alpha:]]*
ws [ \n\t]

%%
{AL} {strcpy(yylval.str,yytext);append(yytext);return AL;}
{ERR} {strcpy(yylval.str,yytext);append(yytext);return ER;}
.    {append(yytext);return yytext[0];}
%%
