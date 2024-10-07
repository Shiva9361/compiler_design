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
%type <str> FAC TERM EXPR FACI 
%left '+' '-'
%left '*' '/'

%%
S: A  S|{printf("Done\n");} ;
A: IDEN EQUAL EXPR ';' {if (eflag){printf("%s -> %s -> Rejected",buffer,error);eflag=0;error[0]="\0";} else printf("%s -> Accepted\n",buffer); buffer[0]='\0';}
 	| EXPR ';' {if (eflag){printf("%s -> %s -> Rejected",buffer,error);eflag=0;error[0]="\0";} else printf("%s -> Accepted\n",buffer); buffer[0]='\0';}
	| error ';' {if (eflag) {eflag=0;error[0]="\0";}printf("%s -> Invalid Statement -> Rejected\n",buffer);yyerrok;buffer[0]='\0';};
EXPR: EXPR PLUS TERM {strcpy($$, $1); strcat($$, $2); strcat($$, $3);}
    | EXPR MINUS TERM {strcpy($$, $1); strcat($$, $2); strcat($$, $3);}
	| TERM {strcpy($$, $1);}

TERM: TERM STAR FAC {strcpy($$, $1); strcat($$, $2); strcat($$, $3);} 
    | TERM DIV FAC {strcpy($$, $1); strcat($$, $2); strcat($$, $3);}
    | TERM MOD FACI {strcpy($$, $1); strcat($$, $2); strcat($$, $3);}
    | FAC {strcpy($$, $1);};

FAC: INT {strcpy($$, $1);} 
   	| MINUS INT {strcpy($$,$1);strcat($$,$2);}
    | FLOAT {strcpy($$, $1);} 
	| MINUS FLOAT {strcpy($$,$1);strcat($$,$1);}
    | IDEN {strcpy($$, $1);} 
	| MINUS IDEN {strcpy($$,$1);strcat($$,$2);}
    | LPAREN EXPR RPAREN {strcpy($$, $2);} 
 	| LPAREN EXPR error {strcpy(error,"Missing Right Parenthesis");eflag=1;strcpy($$,$1);strcat($$,$2);yyerrok};

FACI: INT {strcpy($$, $1);} 
   	| MINUS INT {strcpy($$,$1);strcat($$,$2);}
    | FLOAT {strcpy(error,"Invalid Operand");eflag=1;} 
	| MINUS FLOAT {strcpy(error,"Invalid Operand");eflag=1;}
    | IDEN {strcpy($$, $1);} 
	| MINUS IDEN {strcpy($$,$1);strcat($$,$2);}
    | LPAREN EXPR RPAREN {strcpy($$, $2);} 
 	| LPAREN EXPR error {strcpy(error,"Missing Right Parenthesis");eflag=1;strcpy($$,$1);strcat($$,$2);yyerrok};



%%
int yyerror(char *msg){
	return 0;
}



int main(int argc, char *argv[]){
	//yydebug=1;
	if (argc < 2) {
		printf("Usage : parser filename");
		return -1;
	}
	yyin = fopen(argv[1], "r");	
	yyparse();
	return 0;
}
