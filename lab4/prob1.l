%{
#include<stdio.h>
#include"y.tab.h"
#include<stdlib.h>
#include<string.h>

char buffer[1024] = "";

void append(const char* str) {
    if (strlen(buffer) + strlen(str) < 1024) {
        strcat(buffer, str);
    } else {
        fprintf(stderr, "Buffer overflow error!\n");
        exit(1);
    }
}
%}


num ([[:digit:]]+\.?[[:digit:]]*|[[:digit:]]*\.?[[:digit:]]+)
%%
[ \t\n]+ ;
({num}i|i{num}) 			{strcpy(yylval.sval,yytext);append(yytext);return IM;}
{num} 						{strcpy(yylval.sval,yytext);append(yytext);return NUM;}
"-" 						{strcpy(yylval.sval,yytext);append(yytext);return NEG;}
"+"                         {strcpy(yylval.sval,yytext);append(yytext);return POS;}
.                        	{char temp[2] = {yytext[0], '\0'}; append(temp);return yytext[0];}
							 						
 
%%
