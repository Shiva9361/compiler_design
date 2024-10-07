%{
#include<stdio.h>
#include"y.tab.h"
#include<string.h>
%}


num ([[:digit:]]+\.?[[:digit:]]*|[[:digit:]]*\.?[[:digit:]]+)
%%
[ \t\n]+ ;
({num}i|i{num}) 			{return IM;}
{num} 						{return NUM;}
"-" 						{return NEG;}
"+"                         {return POS;}
[i;]                        {return yytext[0];}
 
%%
