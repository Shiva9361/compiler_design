%{
#include<stdio.h>
#include<stdbool.h>
extern FILE *yyin;
void check(int, int, int);
/**
* Checking as much as possible
* Error handling is not done
*/
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
A: DAY SEP MONTH SEP YEAR {check($1,$3,$5)} ;
%%

int yyerror(char *msg){
	printf("Rejected\n");
	return 0;
}

void check(int day,int mon,int year){
	if (mon==3) printf("Rejected -> Month wrong format\n");
	else if (mon==0){
		if (day>0 && day<31) printf("Accepted\n");
		else printf("Rejected -> Day out of range\n");
	} 
	else if (mon==1){
		if (day>0 && day<32) printf("Accepted\n");
		else printf("Rejected -> Day out of range\n");
	}
	else if ((year%4==0 && year%100!=0) || (year%400==0)){
		if (day>0 && day <30) printf("Accepted\n");
		else printf("Rejected -> Day out of range\n");
	}
	else{
		if (day>0 && day<29) printf("Accepted\n");
		else printf("Rejected -> Day out of range\n");	
	}
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
