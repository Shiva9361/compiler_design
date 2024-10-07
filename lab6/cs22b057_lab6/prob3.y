%{
#include<string.h>
extern FILE *yyin;
extern char buffer[];
char err[1000];
int e=0;

struct Node{
	struct Node* left;
	struct Node* right;
	char val[1024];
	int type;
};

struct Node* createNode(char* val, int type,struct Node* left, struct Node* right) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
	strcpy(node->val, val);
    node->left = left;
    node->right = right;
	node->type = type;
    return node;
}
char* postorder(struct Node* root);
int label=0;
%}

%union{
	char str[1000];
	struct Node* node;
}
%nonassoc PASN MASN DASN SASN 
%left '+' '-'
%left '/' '*' '%'
%nonassoc INC DEC
%nonassoc '(' ')'

%token <str> IDEN NUM PASN MASN DASN SASN INC DEC  
%type <node> A EXPR TERM 
%type <str> ASSGN UN OPR
%%
S: A {label=0;} S{;} | {printf("Done\n");};
A: IDEN ASSGN EXPR ';' {if (e){printf("%s -> %s -> Could not construct Syntax Tree\n",buffer,err);e=0;err[0]="\0";buffer[0]='\0';} else {$$ = createNode($2,3,createNode($1,0,NULL,NULL),$3);printf("%s -> \nThree Address Code:\n",buffer);postorder($$);buffer[0]='\0';printf("\n");}}
	| error ';' {if (e){e=0;err[0]='\0';}printf("%s -> Invalid Statement -> Could not construct Syntax Tree\n",buffer);yyerrok;buffer[0]='\0';} ;
ASSGN: '=' {strcpy($$,"=");}
	 | PASN {strcpy($$,$1);}
	 | MASN {strcpy($$,$1);}
     | DASN {strcpy($$,$1);}
     | SASN {strcpy($$,$1);} ;
EXPR: EXPR '+' EXPR {$$ = createNode("+",1,$1,$3);}
    | EXPR '-' EXPR {$$ = createNode("-",1,$1,$3);}
    | EXPR '*' EXPR {$$ = createNode("*",1,$1,$3);}
	| EXPR '/' EXPR {$$ = createNode("/",1,$1,$3);}
	| EXPR '%' EXPR {$$ = createNode("%",1,$1,$3);}
	| '(' EXPR ')'  {$$ = $2;}
    | '(' EXPR error {e=1;strcpy(err,"missing R-Paren");}
    | EXPR OP error {e=1;strcpy(err,"missing operand");}
    | TERM {$$ = $1;};
OP: '+' | '-' | '*' | '/'| '%' ;
TERM: UN OPR IDEN B  {if (strcmp($1,"-")){$$ = createNode($2,4,createNode($3,0,NULL,NULL),NULL);} else {$$ = createNode($1,2,createNode($2,4,createNode($3,0,NULL,NULL),NULL),NULL);}}
    | UN IDEN OPR B {if (strcmp($1,"-")){$$ = createNode($3,5,createNode($2,0,NULL,NULL),NULL);} else {$$ = createNode($3,2,createNode($2,5,createNode($1,0,NULL,NULL),NULL),NULL);}}
    | UN NUM C {if (!strcmp($1,"-")) {$$ = createNode($1,2,createNode($2,0,NULL,NULL),NULL);} else{$$ = createNode($2,0,NULL,NULL);}}
    | UN IDEN C {if (!strcmp($1,"-")) {$$ = createNode($1,2,createNode($2,0,NULL,NULL),NULL);} else{$$ = createNode($2,0,NULL,NULL);}}
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

int yyerror(char* msg){
	return 0;
}

char* postorder(struct Node* root){
	if (root == NULL) return NULL;
    
	if (root->type == 0) {
        char*re = (char*)malloc(sizeof(char)*100);
        strcpy(re,root->val);
		return re;
    }
	
	char *l = postorder(root->left);
    char *r = postorder(root->right);
	if (l==NULL) l = "";
	if (r==NULL) r = "";
	
	if (root->type == 1) {
		printf("t%d = %s %s %s\n",label,l,root->val,r);
		char *re = (char*)malloc(sizeof(char)*100);
		sprintf(re,"t%d",label);
		label++;
		return re;
	}
	if (root->type == 2){
		printf("%s = - %s\n",label,l);
		char *re = (char*)malloc(sizeof(char)*100);
        sprintf(re,"t%d",label);
		label++;
		return re;

	}
	if (root->type == 3){
		if (strlen(root->val)==2){
			printf("t%d = %s %c %s\n",label,l,root->val[0],r);
			printf("%s = t%d\n",l,label++);
			
		}
		else printf("%s = %s\n",l,r);
		return NULL;
	}
	if (root->type == 4){
		if (!strcmp(root->val,"--")){
			printf("t%d = %s - 1\n",label,l);
			printf("%s = t%d\n",l,label);
			char *re = (char*)malloc(sizeof(char)*100);
            sprintf(re,"t%d",label);
            label++;
            return re;
		}
		else{
			printf("t%d = %s + 1\n",label,l);
            printf("%s = t%d\n",l,label);
            char *re = (char*)malloc(sizeof(char)*100);
            sprintf(re,"t%d",label);
            label++;
            return re; 
		}
	}
	if (root->type == 5){
		if (!strcmp(root->val,"--")){
            printf("t%d = %s\n",label,l);
			printf("t%d = %s - 1\n",label+1,l);
			printf("%s = t%d\n",l,label+1);
			char *re = (char*)malloc(sizeof(char)*100);
       	    sprintf(re,"t%d",label);
            label+=2;
            return re; 
        }   
        else{
        	printf("t%d = %s\n",label,l);
            printf("t%d = %s + 1\n",label+1,l);
            printf("%s = t%d\n",l,label+1);
			char *re = (char*)malloc(sizeof(char)*100);
            sprintf(re,"t%d",label);
            label++;
            return re;
		}
	}
    //printf("%s ", root->val);
	return NULL;
}

int main(int argc,char* argv[]){
	yyin = fopen(argv[1],"r");
	yyparse();
	return 0;
}


