%{
#include<stdio.h>
extern FILE *yyin;
%}
%name parser
%union {
    char sval[100];  
}
%token NUM NEG POS IM NOT
%%
S: A ';' S|{printf("\rDone\n")} ;
A: NEG NUM NEG IM {printf("\rAccepted\n")} 
 | NEG NUM POS IM {printf("\rAccepted\n")}
 | NUM POS IM  {printf("\rAccepted\n")}
 | NUM NEG IM  {printf("\rAccepted\n")}
 | NUM NEG NUM {printf("\rImaginary part i missing\n");yyerrok;} 
 | NUM POS NUM {printf("\rImaginary part i missing\n");yyerrok;}
 | NUM POS 'i' {printf("\rImaginary part number missing\n");yyerrok;}
 | NUM NEG 'i' {printf("\rImaginary part number missing\n");yyerrok;}
 | NUM error {printf("\rInvalid format\n");yyerrok;} 
 | NOT {printf("\rInvalid format\n");};
%%

int yyerror(char *msg){
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
