%{
#include<stdio.h>
#include<string.h>
#include<stdbool.h>
extern FILE *yyin;
extern char buffer[];
char error[1024]="";
int eflag=0;
%}
%union {
	char str[1024];
}
%token <str> IDEN INT FLOAT PLUS MINUS STAR DIV EQUAL MOD LPAREN RPAREN
%type <str> FAC EXPR FACI 
%left ERR
%left PLUS MINUS
%left STAR DIV MOD
%nonassoc UMINUS
%left NON

%%
S: A  S|{printf("Done\n");} ;
A: IDEN EQUAL EXPR ';' {if (eflag){printf("%s -> %s -> Rejected",buffer,error);eflag=0;error[0]="\0";} else printf("%s -> Accepted\n",buffer); buffer[0]='\0';}
 	| EXPR ';' {if (eflag){printf("%s -> %s -> Rejected",buffer,error);eflag=0;error[0]="\0";} else printf("%s -> Accepted\n",buffer); buffer[0]='\0';}
	| error ';' {if (eflag) {eflag=0;error[0]="\0";printf("Error");}printf("%s -> Invalid Statement -> Rejected\n",buffer);yyerrok;buffer[0]='\0';};
EXPR: EXPR PLUS FAC  {;}
    | EXPR MINUS FAC  {;}
	| EXPR DIV FAC  {;}
	| EXPR MOD FACI {;}
	| EXPR STAR FAC {;}
	| FAC {;} ;
OPMISS: IDEN IDEN {;}
		| INT INT {;}
		| FLOAT FLOAT {;} 
		| LPAREN EXPR RPAREN LPAREN EXPR RPAREN {;}
		| LPAREN EXPR RPAREN BTYPES {;}
		| BTYPES LPAREN EXPR RPAREN {;};

BTYPES: INT{;} | FLOAT{;} | IDEN{;};

FAC: INT {;} 
   	| OPMISS {strcpy(error,"Missing Operator");eflag=1;}
   	| MINUS INT {;}
    | FLOAT  {;} 
	| MINUS FLOAT {;}
    | IDEN {;} 
	| MINUS IDEN {;}
    | LPAREN EXPR RPAREN {;} 
 	| LPAREN EXPR error {strcpy(error,"Missing Right Parenthesis");eflag=1;yyerrok;};

FACI: INT {;} 
   	| MINUS INT %prec UMINUS{strcpy(error,"Invalid Operand");eflag=1;}
    | FLOAT {strcpy(error,"Invalid Operand");eflag=1;} 
	| MINUS FLOAT %prec UMINUS{strcpy(error,"Invalid Operand");eflag=1;}
    | IDEN {;} 
	| MINUS IDEN %prec UMINUS{strcpy(error,"Invalid Operand");eflag=1;}
    | LPAREN EXPR RPAREN  {;} 
 	| LPAREN EXPR error {strcpy(error,"Missing Right Parenthesis");eflag=1;yyerrok;};



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
