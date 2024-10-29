%{
#include<string.h>
extern FILE *yyin;
extern char buffer[];
char err[1000];
int e=0;
int label=0;
char* genvar();
char imcode[10000];
%}

%union{
	char str[1000];
}
%nonassoc error
%nonassoc PASN MASN DASN SASN 
%left '+' '-'
%left '/' '*' '%'
%nonassoc INC DEC
%nonassoc '(' ')'
%nonassoc UMINUS
%nonassoc ';'
%token <str> IDEN NUM PASN MASN DASN SASN INC DEC 
%type <str> ASSGN UN OPR A EXPR TERM OP EXPRR 
%%
S: A {label=0;} S{;} | {printf("Done\n");};
A: IDEN ASSGN {if (yychar=='+' || yychar == '/' || yychar == '%' || yychar == '*'){e=1;strcpy(err,"Missing Operand");}} EXPR ';' {
 						if (e){
							printf("%s ->Rejected -> %s -> Could not generate Three Address Code\n",buffer,err);
							e=0;err[0]="\0";buffer[0]='\0';imcode[0]='\0';} 
 						else {	
							printf("%s Accepted -> \nThree Address Code:\n",buffer);
							if (strlen($2)==1){
								sprintf(imcode+strlen(imcode),"%s = %s\n",$1,$4);
								printf("%s",imcode);buffer[0]='\0';imcode[0]='\0';}
							else{
								char* t = genvar();
								sprintf(imcode+strlen(imcode),"%s = %s %c %s\n",t,$1,$2[0],$4);
								sprintf(imcode+strlen(imcode),"%s = %s\n",$1,t);
                            	printf("%s",imcode);
							}
							buffer[0]='\0';imcode[0]='\0';
						}
					}
	| error ';' {if (e){e=0;err[0]='\0';}printf("%s -> Rejected -> Invalid Statement -> Could not generate Three Address Code\n",buffer);yyerrok;buffer[0]='\0';imcode[0]='\0';} ;

ASSGN: '=' {strcpy($$,"=");}
	 | PASN {strcpy($$,$1);}
	 | MASN {strcpy($$,$1);}
     | DASN {strcpy($$,$1);}
     | SASN {strcpy($$,$1);} ;

EXPR: EXPR OP EXPRR {if (!e){char* t = genvar();strcpy($$,t);sprintf(imcode+strlen(imcode),"%s = %s %s %s\n",t,$1,$2,$3);}}
    | '(' EXPR ')'  {strcpy($$,$2);}
    | '(' EXPR error {e=1;strcpy(err,"missing R-Paren");yyerrok;}
	| TERM {strcpy($$,$1);};

EXPRR: EXPR {strcpy($$,$1);}
	|  error {e=1;};

OP: '+' {strcpy($$,"+")} | '-' {strcpy($$,"+")} | '/' {strcpy($$,"+")} | '*' {strcpy($$,"+")} | '%' {strcpy($$,"+")} ;
TERM: UN OPR IDEN B  {if (strcmp($1,"-")){
							char*t2=genvar();sprintf(imcode+strlen(imcode),"%s = %s %c 1\n%s = %s\n",t2,$3,$2[0],$3,t2);strcpy($$,t2);} 
					  else {
							if (!strcmp($2,"--")){e=1;strcpy(err,"--- not allowed");}
							else{
								char*t=genvar();char*t2=genvar();
								sprintf(imcode+strlen(imcode),"%s = %s %c 1\n%s = %s\n%s = - %s\n",t,$3,$2[0],$3,t,t2,t);
								strcpy($$,t2);	
								}
							}
					 }
    | UN IDEN OPR B {if (strcmp($1,"-")){printf("Hlo");char*t = genvar();char*t2=genvar();sprintf(imcode+strlen(imcode),"%s = %s\n%s = %s %c 1\n%s = %s\n",t,$2,t2,$2,$3[0],$2,t2);strcpy($$,t);} 
					 	else{
							char* t = genvar();char* t1 = genvar();char *t3 = genvar();
							printf("Hi");
							sprintf(imcode+strlen(imcode),"%s = %s\n%s = %s %c 1\n%s = %s\n%s = -%s\n",t,$2,t1,$2,$3[0],$2,t1,t3,t);
							strcpy($$,t3);	
						  	}}
    | UN NUM C {if (!strcmp($1,"-")) {char* t = genvar();strcpy($$,t);sprintf(imcode+strlen(imcode),"%s = - %s\n",t,$2);} 
				else{char* t = genvar();strcpy($$,t);sprintf(imcode+strlen(imcode),"%s = %s\n",t,$2);}}
    | UN IDEN C {if (!strcmp($1,"-")) {char* t = genvar();strcpy($$,t);sprintf(imcode+strlen(imcode),"%s = - %s\n",t,$2);} 
				 else{char* t = genvar();strcpy($$,t);sprintf(imcode+strlen(imcode),"%s = %s\n",t,$2);}}
    | UN INC NUM {e=1;strcpy(err,"cannot increment a constant value");}
    | UN DEC NUM {e=1;strcpy(err,"cannot decrement a constant value");}
    | UN NUM INC {e=1;strcpy(err,"cannot increment a constant value");}
    | UN NUM DEC {e=1;strcpy(err,"cannot decrement a constant value");} ;

OPR: INC {strcpy($$,$1);}| DEC {strcpy($$,$1);};

B : OPR {e=1;strcpy(err,"expression is not assignable");} 
  | IDEN {e=1;strcpy(err,"missing operator");}
  | NUM {e=1;strcpy(err,"missing operator");}
  |;
C : IDEN {e=1;strcpy(err,"missing operator");}
  | NUM {e=1;strcpy(err,"missing operator");}
  |;
UN : '-' {strcpy($$,"-");} | {strcpy($$,"");} ;

%%


char* genvar(){
	char *re = (char*)malloc(sizeof(char)*100);
    sprintf(re,"t%d",label);
    label++;
    return re;
}

int yyerror(char* msg){
	return 0;
}

int main(int argc,char* argv[]){
	yyin = fopen(argv[1],"r");
	yyparse();
	return 0;
}


