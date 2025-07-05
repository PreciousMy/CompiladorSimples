%{
#include <string.h>
#include "aula5.tab.h"
%}

NUM [0-9]+\.?[0-9]*
VARS[a-z]+[0-9]*
FIM "FIM"
IF "IF"
ELSE "ELSE"
WHILE "WHILE"
PRINT "PRINT"
SCAN "LER"
INT "int"
FLOAT "float"
STRING "string"
STRING_LITERAL \"[^"]*\" 

%%
"//"[^\n]* {;} 

{FIM} {return FIM;}
{IF} {return IF;}
{ELSE} {return ELSE;}
{WHILE} {return WHILE;}
{PRINT} {return PRINT;}
{SCAN} {return SCAN;}
{INT} {return INT;}
{FLOAT} {return FLOAT;}
{STRING} {return STRING;}

{VARS} {
    strcpy(yylval.str,yytext);
    return VARS;
}

{STRING_LITERAL} {
    strncpy(yylval.str, yytext + 1, yyleng - 2);
    yylval.str[yyleng - 2] = '\0';
    return STRING_LITERAL;
}

{NUM} {
    yylval.flo = atof(yytext);
    return NUM;
}

[-+()=/*^{};\[\]] {return *yytext;}

">" {yylval.fn = 1; return CMP; }
"<" {yylval.fn = 2; return CMP; }
"<>" {yylval.fn = 3; return CMP; }
"==" {yylval.fn = 4; return CMP; }
">=" {yylval.fn = 5; return CMP; }
"<=" {yylval.fn = 6; return CMP; }

[\ \n\t]* {;}
%%

int yywrap(){
    return 1;
}