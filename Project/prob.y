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
int offset=0;
int saveoffset;

typedef struct Symbol{
	char name[100];
	char type[100];
	int size;
	int offset;
	struct Symbol*next;
} Symbol;

struct Type{
	char str[1000];
	int size;
};

struct Decl{
	char key[1000];
	char type[1000];
	char lt[100];
	char op[100];
	int size;
	int re;
	struct Decl* next;
};

struct Node{
	struct Node* next;
	int addr;
};
struct Expr{
	char str[1000];
	char type[100];
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

struct Decl* createDecl(char* key){
	struct Decl *node = (struct Decl*)malloc(sizeof(struct Decl));
	node->re=0;
	strcpy(node->key,key);
	return node; 
}

struct Expr* createExpr(){
	return (struct Expr*)malloc(sizeof(struct Expr));
}

struct Type* createType(){
	return (struct Type*)malloc(sizeof(struct Type));
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

int checkfloat(char* t){
	while(*t){
		if (*t=='.') return 1;
		t++;
	}
	return 0;
}

void backpatch(struct Node* a,int addr){
	while(a!=NULL){
		// printf("%d\n",a->addr);
		if (imcode[a->addr][strlen(imcode[a->addr])-1]!='\n')sprintf(imcode[a->addr]+strlen(imcode[a->addr]),"%d\n",addr);
		a = a->next;
	}
}	

Symbol* createSymbol(char* name){
	Symbol* node = (Symbol*)malloc(sizeof(Symbol));
	strcpy(node->name,name);
	return node;
}

typedef struct Env {
    struct Env* prev;
	int prev_offset;
    struct Table* table;
} Env;

Env* envs[1000]; 
int env_count = 0;  

typedef struct TableEntry {
    char* key;
    Symbol* value;
    struct TableEntry* next;
} TableEntry;

typedef struct Table {
    TableEntry** buckets;
    int size;
} Table;

#define TABLE_SIZE 501

unsigned int hash(const char* key) {
    unsigned int hash = 0;
    while (*key) {
        hash = (hash << 5) + *key++;
    }
    return hash % TABLE_SIZE;
}

Table* create_table() {
    Table* table = malloc(sizeof(Table));
    table->buckets = calloc(TABLE_SIZE, sizeof(TableEntry*));
    table->size = TABLE_SIZE;
    return table;
}

void put(Table* table, const char* key, Symbol* sym) {
    unsigned int index = hash(key);
    TableEntry* new_entry = malloc(sizeof(TableEntry));
    new_entry->key = strdup(key);
    new_entry->value = sym;
    new_entry->next = table->buckets[index];
    table->buckets[index] = new_entry;
}

Symbol* get(Table* table, const char* key) {
    unsigned int index = hash(key);
    TableEntry* entry = table->buckets[index];
    while (entry) {
        if (strcmp(entry->key, key) == 0) {
            return entry->value;
        }
        entry = entry->next;
    }
    return NULL;
}

Env* create_env(Env* prev,int offset) {
    Env* env = malloc(sizeof(Env));
    env->prev = prev;
    env->table = create_table();
	env->prev_offset = offset;
	envs[env_count++] = env;
    return env;
}

void env_put(Env* env, const char* key, Symbol* sym) {
    put(env->table, key, sym);
}

Symbol* env_get(Env* env, const char* key) {
    for (Env* e = env; e != NULL; e = e->prev) {
        Symbol* found = get(e->table, key);
        if (found != NULL) {
            return found;
        }
    }
    return NULL;
}

Env* top = NULL;
void print_table(Table* table) {
    for (int i = 0; i < table->size; i++) {
        TableEntry* entry = table->buckets[i];
        while (entry) {
            printf("0x%04X %s %s \n",entry->value->offset,entry->value->name,entry->value->type);
            entry = entry->next;
        }
    }
}

void print_all_envs() {
	printf("\nStorage Layout");
    for (int i = 0; i < env_count; i++) {
        printf("\n\n", i);
        print_table(envs[i]->table);
    }
}

void checkType(struct Expr* op1,struct Expr* op2,char* opr1,char*opr2,char* type){
	if (strcmp(op1->type,op2->type)==0){
		strcpy(type,op1->type);
		return;
	}
	if (strcmp(op1->type,"int")==0 && strcmp(op2->type,"float")==0){
		char* t = genvar();
		strcpy(opr1,t);
		sprintf(imcode[code],"%d %s = (float) %s\n",code,opr1,op1->str);
		code++;
		strcpy(type,"float");
		return;
	}
	if (strcmp(op1->type,"float")==0 && strcmp(op2->type,"int")==0){
		char* t = genvar();
		strcpy(opr2,t);
		sprintf(imcode[code],"%d %s = (float) %s\n",code,opr2,op2->str);
		code++;
		strcpy(type,"float");
		return;
	}
}
void checkTypeAssign(struct Expr* op1,struct Expr* op2,char*opr ){
	if (strcmp(op1->type,op2->type)==0){
		return;
	}
	if (strcmp(op1->type,"int")==0 && strcmp(op2->type,"float")==0){
		char* t = genvar();
		strcpy(opr,t);
		sprintf(imcode[code],"%d %s = (int) %s\n",code,opr,op2->str);
		code++;
		return;
	}
	if (strcmp(op1->type,"float")==0 && strcmp(op2->type,"int")==0){
		char* t = genvar();
		strcpy(opr,t);
		sprintf(imcode[code],"%d %s = (float) %s\n",code,opr,op2->str);
		code++;
		return;
	}
}

%}

%union{
	char str[1000];
	struct BoolNode* b;
	struct Expr *expr;
	int addr;
	struct Type* type;
	struct Decl* decl;
}

%nonassoc error
%nonassoc PASN MASN DASN SASN
%left OR 
%left AND
%nonassoc '!'
%left LT GT LE GE EQ NE
%left '+' '-'
%left '/' '*' '%'
%nonassoc INC DEC
%nonassoc '(' ')'
%nonassoc UMINUS ELSE IDEN 
%nonassoc ';'
%token <str> IDEN NUM PASN MASN DASN SASN INC DEC LT GT LE GE NE OR AND EQ IF ELSE TR FL WHILE INT FLOAT CHAR CHARR
%token MEOF
%type <str> ASSGN UN OPR 
%type <expr>  EXPR TERM
%type <b> BOOLEXPR STMNTS A ASNEXPR NN
%type <addr> M 
%type <type> TYPE INDEX
%type <decl> DECLLIST
%%

S: 	{top = create_env(top,0);} STMNTS M MEOF{
	if (e){
			printf("%s\nRejected \n%s \nCould not generate Three Address Code / Storage Layout\n",buffer,err);
			e=0;err[0]="\0";buffer[0]='\0';} 
 		else {	
			backpatch($2->N,$3); // for last statement
			printf("%s\nAccepted -> Three Address Code:\n",buffer);
			for (int i=0;i<code;i++){
				printf("%s",imcode[i]);
			}
			print_all_envs(top);
			
		}YYACCEPT;} 
	| MEOF{YYACCEPT;}
	| error MEOF{e=1;strcpy(err,"Invalid Statements");
		printf("%s \nRejected -> %s \nCould not generate Three Address Code / Storage Layout\n",buffer,err);
		YYACCEPT; // stop the parsing
		};
	

A: ASNEXPR ';' {if (!e){$$ = $1;}}
	| ASNEXPR error MEOF{strcat(err,"; missing\n");yyerrok;e=1;
							printf("%s\nRejected -> %s -> Could not generate Three Address Code / Storage Layout\n",buffer,err);
							YYACCEPT; // stop the parsing
							}
	| IF '(' BOOLEXPR ')' M  A {if (!e){backpatch($3->T,$5);
										$$ = createBoolNode();
										$$->N = merge($3->F,$6->N);
										}}
	| IF '(' BOOLEXPR ')' M A ELSE NN M A {if (!e){
		backpatch($3->T,$5);
		backpatch($3->F,$9);
		$$ = createBoolNode();
		$$->N = merge(merge($6->N,$8->N),$10);
	}}
	| EXPR error MEOF{{strcat(err,"; missing");yyerrok;e=1;}
							printf("%s\nRejected -> %s -> Could not generate Three Address Code / Storage Layout\n",buffer,err);
							YYACCEPT; // stop the parsing
							}
	| IF BOOLEXPR ')' M A ELSE NN M A{{strcat(err,"missing (\n");e=1;}}

	| WHILE M '(' BOOLEXPR ')' M A{if (!e){
		backpatch($7->N,$2);
		backpatch($4->T,$6);
		$$ = createBoolNode();
		$$->N = $4->F;
		sprintf(imcode[code],"%d goto %d\n",code,$2);
		code++;
		}}
	| WHILE M  BOOLEXPR ')' M A{{strcat(err,"missing (\n");e=1;}}
	| '{' {top = create_env(top,offset);offset=0;} STMNTS '}' {if (!e) {
						$$ = createBoolNode();
						$$->N = $3->N;
						top = top->prev;
						if (!top) offset =0;
						else offset = top->prev_offset;
						}} 
	| '{' '}' {if (!e){$$=createBoolNode();}}
	| EXPR ';'{if (!e) {$$=createBoolNode();}}
	| DECLSTATEMENT {if (!e){$$=createBoolNode();}};

DECLSTATEMENT: TYPE DECLLIST ';' {
	struct Decl* temp = $2;
	while(temp){
		if (temp->re){
			e=1;
			Symbol* s = get(top->table,temp->key);
			if (strcmp(s->type,$1->str)==0){
				sprintf(err+strlen(err),"Redeclaration of %s\n",s->name);
			}
			else{
				sprintf(err+strlen(err),"conflicting types for %s\n",s->name);
			}
		}
		if (strcmp(temp->type,"")==0){
			Symbol* s = get(top->table,temp->key);
			s->offset = offset;
			offset+=$1->size;
			strcpy(s->type,$1->str);
		}
		else{
			Symbol* s = get(top->table,temp->key);
			s->offset = offset;
			offset+=(temp->size*$1->size);
			strcpy(s->type,temp->type);
			sprintf(s->type+strlen(s->type),"%s %d",$1,temp->size*$1->size);
		}
		if (strcmp(temp->lt,"u")==0){}
		else if (strcmp($1,temp->lt)==0){
			sprintf(imcode[code],"%d %s = %s\n",code,temp->key,temp->op);code++;
		}
		else{
			sprintf(imcode[code],"%d %s = (%s) %s\n",code,temp->key,$1,temp->op);code++;
		}

		temp = temp->next;
	}}
	| TYPE DECLLIST  error MEOF{{strcat(err,"; missing\n");yyerrok;e=1;}
							printf("%s\nRejected -> %s -> Could not generate Three Address Code / Storage Layout\n",buffer,err);
							YYACCEPT; }
;

DECLLIST: IDEN ',' DECLLIST {if (get(top->table,$1)==NULL){
								Symbol* s = createSymbol($1);
								put(top->table,$1,s);
								$$ = createDecl($1);
								$$->next = $3;
							}
							else{
								$$ = createDecl($1);
								strcpy($$->type,"");
								$$->re =1;
								}strcpy($$->lt,"u");
						}
	| IDEN INDEX ',' DECLLIST {
				if (get(top->table,$1)==NULL){
					Symbol* s = createSymbol($1);
					put(top->table,$1,s);
					$$ = createDecl($1);
					$$->next = $4;
					strcpy($$->type,$2->str);
					$$->size = $2->size;
				}
				else{
					$$ = createDecl($1);
					strcpy($$->type,"");
					$$->re =1;
				}strcpy($$->lt,"u");
	}
	| IDEN {if (get(top->table,$1)==NULL){
						Symbol* s = createSymbol($1);
						put(top->table,$1,s);
						$$ = createDecl($1);
			}
			else{
						$$ = createDecl($1);
						strcpy($$->type,"");
						$$->re = 1;
						}strcpy($$->lt,"u");}
	| IDEN '=' EXPR {//sprintf(imcode[code],"%d %s = %s\n",code,$1,$3);code++;
					if (get(top->table,$1)==NULL){
						Symbol* s = createSymbol($1);
						put(top->table,$1,s);
						$$ = createDecl($1);
						strcpy($$->lt,$3->type);
						strcpy($$->op,$3->str);
						}
					else{
						$$ = createDecl($1);
						strcpy($$->type,"");
						strcpy($$->lt,$3->type);
						strcpy($$->op,$3->str);
						$$->re=1;
					}}
	| IDEN INDEX {if (get(top->table,$1)==NULL){
						Symbol* s = createSymbol($1);
						put(top->table,$1,s);
						$$ = createDecl($1);
						strcpy($$->type,$2->str);
						$$->size = $2->size;
						}
					else{
						$$ = createDecl($1);
						strcpy($$->type,"");
						$$->re=1;
					}strcpy($$->lt,"u");};

INDEX: '[' NUM ']' {$$ = createType();$$->size=atoi($2);sprintf($$->str,"array ");
					if (checkfloat($2)){
						e=1;sprintf(err+strlen(err),"Array index cannot be float\n");
					}}
	| '[' NUM ']' INDEX {$$ = createType();$$->size=$4->size*atoi($2);sprintf($$->str,"array %s",$4->str);
						if (checkfloat($2)){e=1;sprintf(err+strlen(err),"Array index cannot be float\n");
					}};

TYPE: INT {$$ = createType(); strcpy($$->str,$1);$$->size=4;} 
	| FLOAT  {$$ = createType();strcpy($$->str,$1);$$->size=4;}
	| CHAR {$$ = createType();strcpy($$->str,$1);$$->size=1;};

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
	 BOOLEXPR OR M BOOLEXPR {  if (!e){backpatch($1->F,$3);
							 	$$ = createBoolNode();	
								$$->T = merge($1->T,$4->T);
								$$->F = $4->F;
							 }}
    | BOOLEXPR AND M BOOLEXPR {	if (!e){backpatch($1->T,$3);
								$$ = createBoolNode();
								$$->T = $4->T;
								$$->F = merge($1->F,$4->F);
								}}
	| '!' BOOLEXPR {
		if (!e){
		$$ = createBoolNode();
		$$->T = $2->F;
		$$->F = $2->T;
		}
	}
	| '(' BOOLEXPR ')' {
		if (!e){
		$$ = createBoolNode();
		$$->T = $2->T;
		$$->F = $2->F;
		}
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
							$$->F = createNode(code);code++;}} 
	| TR {if (!e){
		$$ = createBoolNode();
		$$->T = createNode(code);
		sprintf(imcode[code],"%d goto ",code);
		code++;
	}}
	
	| FL {if (!e){
		$$ = createBoolNode();
		$$->F = createNode(code);
		sprintf(imcode[code],"%d goto ",code);
		code++;
	}};

M: {$$=code;};
NN: {$$=createBoolNode();
	$$->N = createNode(code);
	sprintf(imcode[code],"%d goto ",code);
	code++;
	};

ASNEXPR: EXPR ASSGN EXPR {if (!e && $1->lv){
							char* ct1 = (char*)malloc(sizeof(char));strcpy(ct1,"");
							checkTypeAssign($1,$3,ct1);
							if(strcmp(ct1,"")){
								strcpy($3->str,ct1);
							}
							if (strlen($2)==1){sprintf(imcode[code],"%d %s = %s\n",code,$1,$3);code++;}
							else{
								char* t = genvar();
								sprintf(imcode[code],"%d %s = %s %c %s\n",code,t,$1,$2[0],$3);code++;
								sprintf(imcode[code],"%d %s = %s\n",code,$1,t);code++;
								
							}
							$$ = createBoolNode();
							}
							if (!$1->lv){e=1;strcat(err,"L value not assignable\n");}}

EXPR: EXPR '+' EXPR {if (!e){$$ = createExpr();char* ct1 = (char*)malloc(sizeof(char));strcpy(ct1,"");char* ct2 = (char*)malloc(sizeof(char));strcpy(ct2,"");checkType($1,$3,ct1,ct2,$$->type);if(strcmp(ct1,"")){strcpy($1->str,ct1);}if(strcmp(ct2,"")){strcpy($3->str,ct2);}char* t = genvar();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s + %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
    | EXPR '-' EXPR {if (!e){$$ = createExpr();char* ct1 = (char*)malloc(sizeof(char));strcpy(ct1,"");char* ct2 = (char*)malloc(sizeof(char));strcpy(ct2,"");checkType($1,$3,ct1,ct2,$$->type);if(strcmp(ct1,"")){strcpy($1->str,ct1);}if(strcmp(ct2,"")){strcpy($3->str,ct2);}char* t = genvar();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s - %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
    | EXPR '*' EXPR {if (!e){$$ = createExpr();char* ct1 = (char*)malloc(sizeof(char));strcpy(ct1,"");char* ct2 = (char*)malloc(sizeof(char));strcpy(ct2,"");checkType($1,$3,ct1,ct2,$$->type);if(strcmp(ct1,"")){strcpy($1->str,ct1);}if(strcmp(ct2,"")){strcpy($3->str,ct2);}char* t = genvar();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s * %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
	| EXPR '/' EXPR {if (!e){$$ = createExpr();char* ct1 = (char*)malloc(sizeof(char));strcpy(ct1,"");char* ct2 = (char*)malloc(sizeof(char));strcpy(ct2,"");checkType($1,$3,ct1,ct2,$$->type);if(strcmp(ct1,"")){strcpy($1->str,ct1);}if(strcmp(ct2,"")){strcpy($3->str,ct2);}char* t = genvar();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s / %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
	| EXPR '%' EXPR {if (!e){if (strcmp($3->type,"float")==0 || strcmp($1->type,"float")==0){e=1;sprintf(err+strlen(err),"invalid operands to binary % (float)\n");}$$ = createExpr();char* ct1 = (char*)malloc(sizeof(char));strcpy(ct1,"");char* ct2 = (char*)malloc(sizeof(char));strcpy(ct2,"");checkType($1,$3,ct1,ct2,$$->type);if(strcmp(ct1,"")){strcpy($1->str,ct1);}if(strcmp(ct2,"")){strcpy($3->str,ct2);}char* t = genvar();strcpy($$->str,t);sprintf(imcode[code],"%d %s = %s %% %s\n",code,t,$1->str,$3->str);code++;$$->lv=0;}}
	| '(' EXPR ')'  {if (!e){$$ = createExpr();strcpy($$->str,$2->str);}}
    /* | '(' EXPR error {e=1;strcpy(err,"missing R-Paren");yyerrok;} */
	| EXPR OP ';'{e=1;strcpy(err,"Missing operand");yyerrok;}
    | TERM {$$ = $1;};

OP: '+' | '-' | '*' | '/' | '%';
TERM: UN OPR IDEN B  {if (strcmp($1,"-")){
							Env* temp = top;
							int found=0;
							while(temp){
								if (get(temp->table,$3)){
									found = 1;
									Symbol* t = get(temp->table,$3);
									strcpy($$->type,t->type);
									break;
								}
								temp = temp->prev;
							}
							if (!found){
								sprintf(err+strlen(err),"%s is not declared in scope\n",$3);
								e=1;
							}
							char*t2=genvar();
							sprintf(imcode[code],"%d %s = %s %c 1\n",code,t2,$3,$2[0]);code++;
							sprintf(imcode[code],"%d %s = %s\n",code,$3,t2);code++;
							$$ = createExpr();
							strcpy($$->str,t2);} 
					  else {
							if (!strcmp($2,"--")){e=1;strcpy(err,"--- not allowed");}
							Env* temp = top;
							int found=0;
							while(temp){
								if (get(temp->table,$3)){
									found = 1;
									Symbol* t = get(temp->table,$3);
									strcpy($$->type,t->type);
									break;
								}
								temp = temp->prev;
							}
							if (!found){
								sprintf(err+strlen(err),"%s is not declared in scope\n",$3);
								e=1;
							}
							else{
								char*t=genvar();char*t2=genvar();
								sprintf(imcode[code],"%s = %s %c 1\n%s = %s\n%s = - %s\n",t,$3,$2[0],$3,t,t2,t);
								$$ = createExpr();
								strcpy($$->str,t2);	
								}
							}
						$$->lv = 0;
					 }
    | UN IDEN OPR B {if (strcmp($1,"-")){char*t = genvar();char*t2=genvar();
							sprintf(imcode[code],"%d %s = %s\n",code,t,$2);code++;
							sprintf(imcode[code],"%d %s = %s %c 1\n",code,t2,$2,$3[0]);code++;
							sprintf(imcode[code],"%d %s = %s\n",code,$2,t2);code++;
							$$ = createExpr();
							strcpy($$->str,t);
							Env* temp = top;
							int found=0;
							while(temp){
								if (get(temp->table,$2)){
									found = 1;
									Symbol* t = get(temp->table,$2);
									strcpy($$->type,t->type);
									break;
								}
								temp = temp->prev;
							}
							if (!found){
								sprintf(err+strlen(err),"%s is not declared in scope\n",$2);
								e=1;
							}
							} 
					 	else{
							char* t = genvar();char* t1 = genvar();char *t3 = genvar();
							sprintf(imcode[code],"%d %s = %s\n",code,t,$2);code++;
							sprintf(imcode[code],"%d %s = %s %c 1\n",code,t1,$2,$3[0]);code++;
							sprintf(imcode[code],"%d %s = %s\n",code,$2,t1);code++;
							sprintf(imcode[code],"%d %s = -%s\n",code,t3,t);code++;
							$$ = createExpr();
							strcpy($$->str,t3);	
							Env* temp = top;
							int found=0;
							while(temp){
								if (get(temp->table,$2)){
									found = 1;
									Symbol* t = get(temp->table,$2);
									strcpy($$->type,t->type);
									break;
								}
								temp = temp->prev;
							}
							if (!found){
								sprintf(err+strlen(err),"%s is not declared in scope\n",$2);
								e=1;
							}
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
				if (checkfloat($2)){
					strcpy($$->type,"float");
				}
				else{
					strcpy($$->type,"int");
				}
				$$->lv = 0;}
    | UN IDEN C {if (!strcmp($1,"-")) {char* t = genvar();$$ = createExpr();strcpy($$->str,t);
										sprintf(imcode[code],"%d %s = - %s\n",code,t,$2);
										code++;$$->lv=0;} 
				 else{$$ = createExpr();strcpy($$,$2);
						$$->lv=1;}
				Env* temp = top;
				int found=0;
				while(temp){
					if (get(temp->table,$2)){
						found = 1;
						Symbol* t = get(temp->table,$2);
						strcpy($$->type,t->type);
						break;
					}
					temp = temp->prev;
				}
				if (!found){
					sprintf(err+strlen(err),"%s is not declared in scope\n",$2);
					e=1;
							}}
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
	/* printf("%s\nRejected -> Invalid Statement -> Could not generate Three Address Code\n",buffer); */
	return 0;
}

int main(int argc,char* argv[]){
	/* yydebug=1; */
	yyin = fopen(argv[1],"r");
	yyparse();
	return 0;
}


