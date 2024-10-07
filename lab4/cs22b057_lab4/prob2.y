%{
#include<stdio.h>
#include<stdbool.h>
extern FILE *yyin;
extern buffer[];
void check(int, int, int,char*);
/**
* Most checks in check method
*/
%}
%name parser
%union {
	int day;
	int year;
	struct {
		int m;
		char ma[10];
	} mon
}
%token <mon> MONTH
%token <day> DAY
%token <year> YEAR
%token SEP

%%
S: A  S|{printf("Done\n");} ;
A: DAY SEP MONTH SEP YEAR ';' {check($1,$3.m,$5,$3.ma);} 
 | error ';' {printf("%s -> Rejected -> Invalid Format\n",buffer);buffer[0]='\0';}

%%

int yyerror(char *msg){
	return 0;
}

void check(int day,int mon,int year,char *ma){
	buffer[0] = '\0';
	if (mon==3) printf("%d-%s-%d -> Rejected -> Month wrong\n",day,ma,year);
	else if (mon==0){
		if (day>0 && day<31) printf("%d-%s-%d -> Accepted\n",day,ma,year);
		else printf("%d-%s-%d -> Rejected -> Day out of range\n",day,ma,year);
	} 
	else if (mon==1){
		if (day>0 && day<32) printf("%d-%s-%d -> Accepted\n",day,ma,year);
		else printf("%d-%s-%d -> Rejected -> Day out of range\n",day,ma,year);
	}
	else if ((year%4==0 && year%100!=0) || (year%400==0)){
		if (day>0 && day <30) printf("%d-%s-%d -> Accepted\n",day,ma,year);
		else printf("%d-%s-%d -> Rejected -> Day out of range\n",day,ma,year);
	}
	else{
		if (day>0 && day<29) printf("%d-%s-%d -> Accepted\n",day,ma,year);
		else printf("%d-%s-%d -> Rejected -> Day out of range\n",day,ma,year);	
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
