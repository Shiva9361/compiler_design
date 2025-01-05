%{
#include<stdio.h>
#include<stdbool.h>
extern FILE *yyin;
extern char buffer[];
void check(char *);
/**
* Checking as much as possible
* Error handling is added 
*/
%}
%name parser
%union {
	char str[100];
}
%token <str> AL ER

%%
S: A S|{printf("Done\n");} ;
A: AL ';' {check($1);}
 | ER ';' {printf("%s -> Rejected -> Invalid string\n",buffer);buffer[0]='\0';} 
 | error ';' {printf("%s -> Rejected -> Invalid string\n",buffer);buffer[0]='\0';}

%%

int yyerror(char *msg){
	return 0;
}

void check(char *str){
	int count[] = {0,0,0};
	while(*str !='\0'){
		count[*str-'a']++;
		str++;
	}
	if (count[0] != count[1] && count[1] != count[2]) {printf("%s -> Accepted\n",buffer);}
	else {printf("%s -> Rejected -> Number of a!=b!=c is not satisfied\n",buffer);}
	buffer[0]='\0';
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
