%{
#include<stdio.h>
#include<stdbool.h>
bool checker(char*,int);
%}
/**
* Need to check if length is even 
* Then normal palindrome checking by 2 pointers
*/
%%
^(0|1)*$ {if (yyleng %2==0 && checker(yytext,yyleng)) {
				printf("Accepted String %s\n",yytext);
		    }else{
				printf("Rejected String %s\n",yytext);
			}
}
.* {printf("Rejected String %s\n",yytext);}

%%
/**
* Helper to count x and y
*/
bool checker(char* str, int length){
	for (int i=0,j=length-1;i<=j;i++,j--){
		if (str[i]!=str[j]) return false;
	}
	return true;
}

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
