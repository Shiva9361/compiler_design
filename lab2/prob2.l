%{
#include<stdio.h>
%}

/**
int a = .5; is considered valid in c
int a=5;int b=6; is also valid in c
We can have white space inbetween tokens
We can have white space at the start and end
Value can be integer or float and can be preceded with +,-
*/

types (int|float)
identifier ([[:alpha:]_]+[[:alnum:]_]*)
value -?\+?([[:digit:]]+(\.)?[[:digit:]]*|[[:digit:]]*(\.)?[[:digit:]]+)
ws [ \t]

%%

({ws}*{types}{ws}+({identifier}({ws}*={ws}*{value})?{ws}*(,{ws}*{identifier}({ws}*={ws}*{value})?{ws}*)*){ws}*;)+ {printf("Accepted string %s",yytext);}
.* {printf("Rejected string %s",yytext);}

%%


int main(int argc, char *argv[]){
	if (argc < 2) {
		printf("Usage : lexer filename");
		return -1;
	}
	FILE *infile = fopen(argv[1], "r");
  	// make sure it's valid:
  	if (!infile) {
    	printf("Can't open the file!");
    	return -1;
  	}
  	// set lex to read from file
  	yyin = infile;    
	yylex();
	fclose(infile);
	return 0;
}
