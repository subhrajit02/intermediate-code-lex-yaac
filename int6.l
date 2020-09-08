%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
void showError();
%}

%%
[\n]quit   {return QUIT;}
if    { return IF;}
else   { return ELSE;}
for   {  return FOR;}
print					{return (PRINT);}
[a-z][a-z_0-9]*			{  sscanf(yytext, "%s", yylval.name); return VARIABLE;  }
[0-9]+[.]?[0-9]*      			{  yylval.f = atof(yytext); return NUMBER;  }
[ \t]    ;
[;]?[\n]?    		   {return (SEMICOLON);}
.							{  return yytext[0];  }




%%


void showError()
{
    printf("INVALID INPUT");
}
int yywrap(void)
{
	return 1;
}





