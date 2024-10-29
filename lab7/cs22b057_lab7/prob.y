%{
#include<stdio.h>
#include<string.h>
extern FILE *yyin;
extern char buffer[];
char err[1000];
int e=0;
int label=0;
char* genvar();
char imcode[10000][10000];
int code=0;

struct Node{
	struct Node* next;
	int addr;
};
struct Expr{
	char str[1000];
	int lv;
};
struct BoolNode{
	struct Node* T;
	struct Node* F;
	struct Node* N;
};

struct Node* createNode(int addr){
	struct Node* node = (struct Node*)malloc(sizeof(struct Node));
	node->next = NULL;
	node->addr = addr;
	return node;
}

struct Expr* createExpr(){
	return (struct Expr*)malloc(sizeof(struct Expr));
}

struct BoolNode* createBoolNode(){
	struct BoolNode* node = (struct BoolNode*)malloc(sizeof(struct BoolNode));
	return node;
}

struct Node* merge(struct Node* a,struct Node* b){
	if (a==NULL && b==NULL) return NULL;
	if (a==NULL) return b;
	if (b==NULL) return a;
	struct Node* t = a;
	while(t->next!=NULL){
		t = t->next; 
	}
	t->next = b;
	return a;
}
void backpatch(struct Node* a,int addr){
	while(a!=NULL){
		// printf("%d\n",a->addr);
		if (imcode[a->addr][strlen(imcode[a->addr])-1]!='\n')sprintf(imcode[a->addr]+strlen(imcode[a->addr]),"%d\n",addr);
		a = a->next;
	}
}	
%}

%union{
	char str[1000];
	struct BoolNode* b;
	struct Expr *expr;
	int addr;
}

%nonassoc error
%nonassoc PASN MASN DASN SASN
%left OR 
%left AND
%left LT GT LE GE EQ NE
%left '+' '-'
%left '/' '*' '%'
%nonassoc INC DEC
%nonassoc '(' ')'
%nonassoc UMINUS ELSE IDEN
%nonassoc ';'
%token <str> IDEN NUM PASN MASN DASN SASN INC DEC LT GT LE GE NE OR AND EQ IF ELSE
%type <str> ASSGN UN OPR 
%type <expr>  EXPR TERM
%type <b> BOOLEXPR STMNTS A ASNEXPR NN
%type <addr> M 
%%

S: 	STMNTS M {
	if (e){
			printf("%s Rejected -> %s -> Could not generate Three Address Code\n",buffer,err);
			e=0;err[0]="\0";buffer[0]='\0';} 
 		else {	
			backpatch($1->N,$2); // for last statement
			printf("%s Accepted -> \nThree Address Code:\n",buffer);
			for (int i=0;i<code;i++){
				printf("%s",imcode[i]);
			}
			
		}} ;

A: ASNEXPR ';' {if (!e){$$ = $1;}}
	| IF '(' BOOLEXPR ')' M  A {if (!e){backpatch($3->T,$5);
										$$ = createBoolNode();
										$$->N = merge($3->F,$6->N);
										}}
	| IF '(' BOOLEXPR ')' M A ELSE NN M A {if (!e){
		backpatch($3->T,$5);
		backpatch($3->F,$9);
		$$ = createBoolNode();
		$$->N = merge(merge($6->N,$8->N),$10);
	}
	}
	| IF error {if (!e){strcpy(err,"missing (");yyerrok;e=1;}}
	| '{' STMNTS '}' {if (!e) {
						$$ = createBoolNode();
						$$->N = $2->N;
						}} 
	| EXPR ';'{;}
	| EXPR error {if (!e) {strcpy(err,"; missing");yyerrok;e=1;}}
	| error ';' {if (!e){strcpy(err,"Invalid Statement");}yyerrok;e=1;};

STMNTS: STMNTS M A {if (!e){backpatch($1->N,$2);
					$$ = createBoolNode();
					$$->N = $3->N;}} 
	| A M{if (!e){$$ = createBoolNode();
		$$->N = $1->N;}};

ASSGN: '=' {strcpy($$,"=");}
	 | PASN {strcpy($$,$1);}
	 | MASN {strcpy($$,$1);}
     | DASN {strcpy($$,$1);}
     | SASN {strcpy($$,$1);} ;

BOOLEXPR:     
	| BOOLEXPR OR M BOOLEXPR {  backpatch($1->F,$3);
							 	// $$ = createBoolNode();	
								// $$->T = merge($1->T,$4->T);
								// $$->F = $4->F;
							 }
    | BOOLEXPR AND M BOOLEXPR {	backpatch($1->T,$3);
								// $$ = createBoolNode();
								// $$->T = $4->T;
								// $$->F = merge($1->F,$4->F);
								}
	| EXPR LT EXPR  {if(!e) {sprintf(imcode[code],"%d if %s %s %s goto ",code,$1->str,$2,$3->str);
							$$ = createBoolNode();
							$$->T = createNode(code);
							code++;
							sprintf(imcode[code],"%d goto ",code);
							$$->F = createNode(code);
							code++;
							}} 
    | EXPR GT EXPR  {if(!e) {sprintf(imcode[code],"%d if %s %s %s goto ",code,$1->str,$2,$3->str);
							$$ = createBoolNode();
							$$->T = createNode(code);
							code++;
							sprintf(imcode[code],"%d goto ",code);
							$$->F = createNode(code);code++;}} 
	| EXPR EQ EXPR  {if(!e) {sprintf(imcode[code],"%d if %s %s %s goto ",code,$1->str,$2,$3->str);
							$$ = createBoolNode();
							$$->T = createNode(code);
							code++;
							sprintf(imcode[code],"%d goto ",code);
							$$->F = createNode(code);code++;}} 
    | EXPR NE EXPR  {if(!e) {sprintf(imcode[code],"%d if %s %s %s goto ",code,$1->str,$2,$3->str);
							$$ = createBoolNode();
							$$->T = createNode(code);
							code++;
							sprintf(imcode[code],"%d goto ",code);
							$$->F = createNode(code);code++;}} 
	| EXPR LE EXPR  {if(!e) {sprintf(imcode[code],"%d if %s %s %s goto ",code,$1->str,$2,$3->str);
							$$ = createBoolNode();
							$$->T = createNode(code);
							code++;
							sprintf(imcode[code],"%d goto ",code);
							$$->F = createNode(code);code++;}} 
    | EXPR GE EXPR  {if(!e) {sprintf(imcode[code],"%d if %s %s %s goto ",code,$1->str,$2,$3->str);
							$$ = createBoolNode();
							$$->T = createNode(code);
							code++;
							sprintf(imcode[code],"%d goto ",code);
							$$->F = createNode(code);code++;}} ;

M: {$$=code;};
NN: {$$=createBoolNode();
	$$->N = createNode(code);
	sprintf(imcode[code],"%d goto ",code);
	code++;
	};

ASNEXPR: EXPR ASSGN EXPR {if (!e && $1->lv){if (strlen($2)==1){sprintf(imcode[code],"%d %s = %s\n",code,$1,$3);code++;}
							else{
								char* t = genvar();
								sprintf(imcode[code],"%d %s = %s %c %s\n",code,t,$1,$2[0],$3);code++;
								sprintf(imcode[code],"%d %s = %s\n",code,$1,t);code++;
								
							}
							$$ = createBoolNode();
							}
							if (!$1->lv){e=1;strcpy(err,"L value not assignable");}}

EXPR: EXPR '+' EXPR {if (!e){char* t = genvar();$$ = createExpr();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s + %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
    | EXPR '-' EXPR {if (!e){char* t = genvar();$$ = createExpr();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s - %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
    | EXPR '*' EXPR {if (!e){char* t = genvar();$$ = createExpr();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s * %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
	| EXPR '/' EXPR {if (!e){char* t = genvar();$$ = createExpr();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s / %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
	| EXPR '%' EXPR {if (!e){char* t = genvar();$$ = createExpr();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s % %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
	| '(' EXPR ')'  {if (!e){strcpy($$->str,$2->str);}}
    | '(' EXPR error {e=1;strcpy(err,"missing R-Paren");yyerrok;}
    | TERM {$$ = createExpr();strcpy($$->str,$1);$$->lv=$1->lv;};

TERM: UN OPR IDEN B  {if (strcmp($1,"-")){
							char*t2=genvar();
							sprintf(imcode[code],"%d %s = %s %c 1\n",code,t2,$3,$2[0]);code++;
							sprintf(imcode[code],"%d %s = %s\n",code,$3,t2);code++;
							$$ = createExpr();
							strcpy($$->str,t2);} 
					  else {
							if (!strcmp($2,"--")){e=1;strcpy(err,"--- not allowed");}
							else{
								char*t=genvar();char*t2=genvar();
								sprintf(imcode[code],"%s = %s %c 1\n%s = %s\n%s = - %s\n",t,$3,$2[0],$3,t,t2,t);
								$$ = createExpr();
								strcpy($$->str,t2);	
								}
							}
						$$->lv = 1;
					 }
    | UN IDEN OPR B {if (strcmp($1,"-")){char*t = genvar();char*t2=genvar();
							sprintf(imcode[code],"%d %s = %s\n",code,t,$2);code++;
							sprintf(imcode[code],"%d %s = %s %c 1\n",code,t2,$2,$3[0]);code++;
							sprintf(imcode[code],"%d %s = %s\n",code,$2,t2);code++;
							$$ = createExpr();
							strcpy($$->str,t);
							} 
					 	else{
							char* t = genvar();char* t1 = genvar();char *t3 = genvar();
							sprintf(imcode[code],"%d %s = %s\n",code,t,$2);code++;
							sprintf(imcode[code],"%d %s = %s %c 1\n",code,t1,$2,$3[0]);code++;
							sprintf(imcode[code],"%d %s = %s\n",code,$2,t1);code++;
							sprintf(imcode[code],"%d %s = -%s\n",code,t3,t);code++;
							$$ = createExpr();
							strcpy($$->str,t3);	
						  	}
							$$->lv=0;}
    | UN NUM C {if (!strcmp($1,"-")) {char* t = genvar();$$ = createExpr();strcpy($$->str,t);
										sprintf(imcode[code],"%d %s = - %s\n",code,t,$2);
										code++;} 
				else{char* t = genvar();$$ = createExpr();
					$$ = createExpr();
					strcpy($$->str,t);
					sprintf(imcode[code],"%d %s = %s\n",code,t,$2);code++;
				}
				$$->lv = 0;}
    | UN IDEN C {if (!strcmp($1,"-")) {char* t = genvar();$$ = createExpr();strcpy($$->str,t);
										sprintf(imcode[code],"%d %s = - %s\n",code,t,$2);
										code++;} 
				 else{char* t = genvar();$$ = createExpr();strcpy($$,t);
				 		sprintf(imcode[code],"%d %s = %s\n",code,t,$2);
						code++;}
				$$->lv = 1;}
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

void findfloat(char* t){
	int ans=0;
	while(t!='\0') if (t++=='.') ans=1;
	return ans;
}

char* genvar(){
	char *re = (char*)malloc(sizeof(char)*100);
    sprintf(re,"t%d",label);
    label++;
    return re;
}

int yyerror(char* msg){
	/* printf("%s",msg); */
	return 0;
}

int main(int argc,char* argv[]){
	/* yydebug=1; */
	yyin = fopen(argv[1],"r");
	yyparse();
	return 0;
}


