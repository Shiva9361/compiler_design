%{
#include<string.h>
extern FILE *yyin;
extern char buffer[];
char err[1000];
int e=0;
%}

%nonassoc PASN MASN DASN SASN
%token IDEN NUM
%left '+' '-'
%left '/' '*' '%'
%nonassoc INC DEC
%nonassoc '(' ')'

%%
S: A S | {printf("Done\n");};
A: IDEN ASSGN EXPR ';' {if (e){printf("%s -> Rejected -> %s\n",buffer,err);err[0]='\0';buffer[0]='\0';e=0;} else {printf("%s -> Accepted\n",buffer);buffer[0]='\0';}} | error ';' {printf("%s -> Rejected -> Invalid Expression\n",buffer);yyerrok;buffer[0]='\0';} ;
ASSGN: '=' 
	 | PASN
	 | MASN
     | DASN
     | SASN ;
EXPR: EXPR '+' EXPR 
    | EXPR '-' EXPR
    | EXPR '*' EXPR
	| EXPR '/' EXPR
	| EXPR '%' EXPR
	| '(' EXPR ')'
    | '(' EXPR error {e=1;strcpy(err,"missing R-Paren");}
    | EXPR OP error {e=1;strcpy(err,"missing operand");}
    | term;
OP: '+' | '-' | '*' | '/'| '%' ;
term: UN OPR IDEN B 
    | UN IDEN OPR B 
    | UN NUM C 
    | UN IDEN C
    | UN INC NUM {e=1;strcpy(err,"cannot increment a constant value");}
    | UN DEC NUM {e=1;strcpy(err,"cannot decrement a constant value");}
    | UN NUM INC {e=1;strcpy(err,"cannot increment a constant value");}
    | UN NUM DEC {e=1;strcpy(err,"cannot decrement a constant value");} ;
OPR: INC | DEC;
B : OPR {e=1;strcpy(err,"expression is not assignable");} 
  | IDEN {e=1;strcpy(err,"missing operator");}
  | NUM {e=1;strcpy(err,"missing operator");}
  |;
C : IDEN {e=1;strcpy(err,"missing operator");}
  | NUM {e=1;strcpy(err,"missing operator");}
  |;
UN : '-' |  ;

%%

int yyerror(char* msg){
	return 0;
}

int main(int argc,char* argv[]){
	yyin = fopen(argv[1],"r");
	yyparse();
	return 0;
}


