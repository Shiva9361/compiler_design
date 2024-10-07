%{
#include<stdio.h>
extern FILE *yyin;
extern char buffer[];
%}
%name parser
%union {
    char sval[100];  
} 
%token<sval> NEG POS IM NUM
%%
S: A S |{printf("Done\n");} ;
A: NEG NUM NEG IM ';' {printf("%s%s%s%s -> Accepted\n",$1,$2,$3,$4);buffer[0]='\0';} 
 | NEG NUM POS IM ';' {printf("%s%s%s%s -> Accepted\n",$1,$2,$3,$4);buffer[0]='\0';}
 | NUM POS IM ';' {printf("%s%s%s -> Accepted\n",$1,$2,$3);buffer[0]='\0';}
 | NUM NEG IM ';' {printf("%s%s%s -> Accepted\n",$1,$2,$3);buffer[0]='\0';}
 | NUM NEG NUM ';' {printf("%s -> Rejected - missing 'i'\n",buffer);buffer[0]='\0';yyerrok;} 
 | NUM POS NUM ';'{printf("%s -> Rejected - missing 'i'\n",buffer);buffer[0]='\0';yyerrok;}
 | NUM POS 'i' ';'{printf("%s -> Rejected - missing imaginary part coefficient\n",buffer);buffer[0]='\0';yyerrok;}
 | NUM NEG 'i' ';'{printf("%s -> Rejected - missing imaginary part coefficient\n",buffer);buffer[0]='\0';yyerrok;}
 | NUM error ';'{printf("%s -> Rejected - Invalid format\n",buffer);buffer[0]='\0';yyerrok;}
 | IM ';' {printf("%s -> Rejected - missing real part\n",buffer);buffer[0]='\0';yyerrok;}
 | NUM ';' {printf("%s -> Rejected - missing imaginary part\n",buffer);buffer[0]='\0';yyerrok;}
 | NEG NUM ';' {printf("%s -> Rejected - missing imaginary part\n",buffer);buffer[0]='\0';yyerrok;}
 | NEG IM ';'{printf("%s -> Rejected - missing real part\n",buffer);buffer[0]='\0';yyerrok;}
 | POS IM ';' {printf("%s -> Rejected - missing real part\n",buffer);buffer[0]='\0';yyerrok;}  
 | error ';' {printf("%s -> Rejected - Invalid format\n",buffer);buffer[0]='\0';yyerrok;} ; 
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
