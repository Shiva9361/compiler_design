%{
#include<stdio.h>
%}
/**
* Taking alpha as the alphabet of language
* In order to match y, take all possible cases
* a,b,c,d
*/
alpha (a|b|c|d)
%%
^({alpha}+az{alpha}+a|{alpha}+bz{alpha}+b|{alpha}+cz{alpha}+c|{alpha}+dz{alpha}+d)$ {printf("Accepted string %s",yytext);}
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

