%{
#include<stdio.h>
#include<stdbool.h>
extern FILE *yyin;
bool check(int, int, int);
%}
%name parser
%union {
    int mon;
	int day;
	int year;  
}
%token <mon> MONTH
%token <day> DAY
%token <year> YEAR
%token SEP

%%
S: A ';' S|{printf("Done\n")} ;
A: DAY SEP MONTH SEP YEAR {if (check($1,$3,$5)) printf("Accepted\n"); else printf("Rejected\n")} ;
%%

int yyerror(char *msg){
	printf("Rejected\n");
	return 0;
}

bool check(int day,int mon,int year){
	if (mon==0){
		if (day>0 && day<31) return true;
		else return false;
	} 
	else if (mon==1){
		if (day>0 && day<32) return true;
		else return false;
	}
	else if ((year%4==0 && year%100!=0) || (year%400==0)){
		if (day>0 && day <30) return true;
		else return false;
	}
	if (day>0 && day<29) return true;
	return false;	
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
