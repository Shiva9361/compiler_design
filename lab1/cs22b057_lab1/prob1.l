%{
#include<stdio.h>
int count(char,char*);
%}
/**
* 1A
* (01|1)* takes almost all string without 00
* only edge case is last character 0
* This can be added using 0?
* As string should contain 111
* We can use the pattern in front 
* and behind to get all strings
* Assuming whitespace should not be considered
* 1B
* Get all the xyz strings,
* Use a function to check the condition and 
* print accordingly
*/
pattern (01|1)*0?
%%
^{pattern}111{pattern}$ {printf("Accepted string from pattern 1.a %s\n",yytext);}
^[xyz]*$ {if ((count('x',yytext)%2) == (count('y',yytext)%3)){
			printf("Accepted string from pattern 1.b %s\n",yytext);
		 }else{
		 	printf("Rejected string %s\n",yytext);
		 }}
.* {printf("Rejected string %s\n",yytext);}

%%
/**
* Helper to count x and y
*/
int count(char x, char* str){
	int count = 0;
	while(*str) if (*str++ == x) count++;	
	return count;
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
