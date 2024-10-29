%{
#include<stdio.h>
FILE *symbolTable;
char **symbols;
int loc=0;
void insert(char * string,int len,char* type);
/**
* All parsed symbols are written to SymbolTable.txt
* Format TOKEN: LEXEME
* Duplicate entries are removed
* Scope is not considered 
*/
%}
keywords (auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while)
identifier ([[:alpha:]_]+[[:alnum:]_]*)
operator ("<<="|">>="|"+"|"-"|"+="|"-="|"/="|"*="|"<"|">"|"<="|">="|"!="|">>"|"<<"|"&&"|"&"|"|"|"||"|"="|"!"|"/"|"*"|"~"|"~="|"^"|"^="|"|="|"&="|"==")
punctuation (\.|;|\[|\]|\(|\)|\{|\}|~)
int ([[:digit:]]+)
float ([[:digit:]]+(\.)?[[:digit:]]*|[[:digit:]]*(\.)?[[:digit:]]+)
ws [ \t]
newline \n
%%
"//".* ;
"#".* ;
"/*"(.|{newline})*"*/" ;
{keywords} {printf("KEYWORD: %s\n",yytext);insert(yytext,yyleng+9,"KEYWORD: ");}
{identifier} {printf("IDENTIFIER: %s\n",yytext);insert(yytext,yyleng+12,"IDENTIFIER: ");}
\".*\" {printf("STRING: %s\n",yytext);insert(yytext,yyleng+8,"STRING: ");}
'.' {printf("CHARACTER: %s\n",yytext);insert(yytext,yyleng+6,"CHAR: ");}
{int} {printf("INTEGER: %s\n",yytext);insert(yytext,yyleng+5,"INT: ");}
{float} {printf("FLOAT: %s\n",yytext);insert(yytext,yyleng+7,"FLOAT: ");}
{operator} {printf("OPERATOR: %s\n",yytext);insert(yytext,yyleng+10,"OPERATOR: ");}
{punctuation} {printf("SPECIALSYMBOL: %s\n",yytext);insert(yytext,yyleng+15,"SPECIALSYMBOL: ");}
. ;

%%

void insert(char* string,int len,char* type){
	char* temp = malloc(len*sizeof(char*));
	strcpy(temp,type);
	strcat(temp,string);
    for (int i=0;i<loc;i++){
        if (!strcmp(temp,symbols[i])) return;
    }   
    symbols[loc] = malloc(len*sizeof(char*));
    strcpy(symbols[loc++],temp);
}

void writesymbols(){
	fprintf(symbolTable,"TOKEN: LEXEME\n");
    for (int i=0;i<loc;i++){
        fprintf(symbolTable,"%s\n",symbols[i]);
    }
}

int main(int argc, char *argv[]){
	if (argc < 2) {
		printf("Usage : lexer filename");
		return -1;
	}
	FILE *infile = fopen(argv[1], "r");
	symbols = (char**) malloc(1e7 * sizeof(char*));
	symbolTable = fopen("SymbolTable.txt","w");
  	// make sure it's valid:
  	if (!infile) {
    	printf("Can't open the file!");
    	return -1;
  	}
  	// set lex to read from file
  	yyin = infile;    
	yylex();
	fclose(infile);
	writesymbols();
	return 0;
}
