%{
#include<stdio.h>
#include<string.h>
%}
/**
* My assumptions,
* We are meant to tokenize not verify 
* valid characters for page is alphabets, numbers and -
* valid characters for username is alphabets, numbers _ and -
* password might not be there 
* Some parts I am verifying such as ://, mailto syntax
* lex matches the rule with highest length when overlap occurs
* so mailto will overlap with username@password
*/
valid [[:alnum:]_%+.-]+
query ([[:alnum:]_%+.-]+=[[:alnum:]_%+.-]*)

%%
^(http|https|ftp|file):"//" {printf("Scheme: %.*s\n",(int)(strlen(yytext)-3),yytext);}
^mailto:{valid}@ {printf("Scheme: mailto\nUser: %.*s\n",(int)(strlen(yytext+7)-1),yytext+7);}
[[:alnum:].-]+\.[[:alpha:]]{2,} {printf("Host: %s\n",yytext);}
:[0-9]+ {printf("Port: %s\n",yytext+1);}
{valid}+:{valid}*@ {printf("User:Password : %.*s\n",(int)(strlen(yytext)-1),yytext);}
("/"{valid})*(\.[a-z]*)? {printf("Path: %s\n",yytext);}
"?"({query}"&")*({query}) {printf("Query Parameters: %s\n",yytext+1);} 
"#"{valid} {printf("Fragment: %s\n",yytext+1);}
. ;
%%

int main(int argc, char *argv[]){
	if (argc < 2) {
		printf("Usage : lexer filename");
		return -1;	
	}
	FILE *infile = fopen(argv[1], "r");
  	// make sure it's valid:
 	if (!infile) {
    	printf("Can't open the file!");
    	return -1;
  	}
  	// set lex to read from file
  	yyin = infile;    
	yylex();
	fclose(infile);
	return 0;
}
