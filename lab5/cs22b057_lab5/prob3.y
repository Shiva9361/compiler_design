%{
#include<stdio.h>
#include<string.h>
#include<stdbool.h>
extern FILE *yyin;
extern char buffer[];
char error[1024]="";
int eflag=0;

struct Node{
	struct Node* left;
	struct Node* right;
	char val[1024];
};

struct Node* createNode(char* val, struct Node* left, struct Node* right) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
	strcpy(node->val, val);
    node->left = left;
    node->right = right;
    return node;
}

void postorder(struct Node* root);

%}
%union {
	char str[1024];
	struct Node* node;
}
%token <str> IDEN INT FLOAT PLUS MINUS STAR DIV EQUAL MOD LPAREN RPAREN
%type <node> FAC TERM EXPR FACI A S 
%left PLUS MINUS
%left STAR DIV MOD

%%
S: A  S|{printf("Done\n");} ;
A: IDEN EQUAL EXPR ';' {if (eflag){printf("%s -> %s -> Could not construct Syntax Tree\n",buffer,error);eflag=0;error[0]="\0";buffer[0]='\0';} else {$$ = createNode("=",createNode($1,NULL,NULL),$3);printf("%s -> \nPost-Order: ",buffer);postorder($$);buffer[0]='\0';printf("\n");}}
 	| EXPR ';' {if (eflag){printf("%s -> %s -> Could not construct Syntax Tree\n",buffer,error);eflag=0;error[0]="\0";buffer[0]='\0';} else {$$=$1;printf("%s -> \nPost-Order: ",buffer);postorder($$);buffer[0]='\0';printf("\n");}}
	| error ';' {if (eflag){eflag=0;error[0]='\0';}printf("%s -> Invalid Statement -> Could not construct Syntax Tree\n",buffer);yyerrok;buffer[0]='\0';} ;

EXPR: EXPR PLUS TERM { $$ = createNode("+", $1, $3); }
    | EXPR MINUS TERM { $$ = createNode("-", $1, $3); }
    | TERM { $$ = $1; }
    ;

TERM: TERM STAR FAC { $$ = createNode("*", $1, $3); }
    | TERM DIV FAC { $$ = createNode("/", $1, $3); }
    | TERM MOD FACI { $$ = createNode("%", $1, $3); }
    | FAC { $$ = $1; }
    ;

FAC: INT { $$ = createNode($1, NULL, NULL); }
   | MINUS INT { $$ = createNode("-", createNode($2, NULL, NULL), NULL); }
   | FLOAT { $$ = createNode($1, NULL, NULL); }
   | MINUS FLOAT { $$ = createNode("-", createNode($2, NULL, NULL), NULL); }
   | IDEN { $$ = createNode($1, NULL, NULL); }
   | MINUS IDEN { $$ = createNode("-", createNode($2, NULL, NULL), NULL); }
   | LPAREN EXPR RPAREN { $$ = $2; }
   | LPAREN EXPR error { strcpy(error, "Missing Right Parenthesis"); eflag = 1; yyerrok; }
   ;

FACI: INT { $$ = createNode($1, NULL, NULL); }
    | MINUS INT { strcpy(error,"Invalid Operand"); eflag=1;$$ = createNode("", NULL, NULL); }
    | FLOAT { strcpy(error, "Invalid Operand"); eflag = 1; $$ = createNode("", NULL, NULL); }
    | MINUS FLOAT { strcpy(error, "Invalid Operand"); eflag = 1; $$ = createNode("", NULL, NULL); }
    | IDEN { $$ = createNode($1, NULL, NULL); }
    | MINUS IDEN { strcpy(error,"Invalid Operand"); eflag=1; $$ = createNode("",NULL,NULL); }
	| LPAREN EXPR RPAREN {$$ = $2;}
	| LPAREN EXPR error {strcpy(error,"Missing Right Parenthesis");eflag=1;yyerrok;}
    ;


%%
int yyerror(char *msg){
	return 0;
}

void postorder(struct Node* root){
	if (root == NULL) return;
    postorder(root->left);
    postorder(root->right);
    printf("%s ", root->val);
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
