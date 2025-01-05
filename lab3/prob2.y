%{
#include<stdio.h>
extern FILE *yyin;
/**
* Assuming that  +a -bi is not valid
*/
%}
%name parser
%union {
    char sval[100];  
}
%token NUM NEG POS IM NOT
%%
S: A ';' S|{printf("Done\n")} ;
A: NEG NUM NEG IM {printf("Accepted\n")} 
 | NEG NUM POS IM {printf("Accepted\n")}
 | NUM POS IM  {printf("Accepted\n")}
 | NUM NEG IM  {printf("Accepted\n")} ;
%%

int yyerror(char *msg){
	printf("Rejected\n");
	return 0;
}

int main(int argc, char *argv[]){
	if (argc < 2) {
		printf("Usage : parser filename");
		return -1;
	}
	yyin = fopen(argv[1], "r");	
	yyparse();
	return 0;
}
