%{
#include <stdio.h>
#include "calc.tab.h"
int DEBUGL = 0;
%}
%option yylineno
%%

"main()" {if(DEBUGL)printf("<Main>\n"); return(TOK_MAIN);}
"{" {if(DEBUGL)printf("<LBrace>\n"); return(TOK_LBRACE);}
"}" {if(DEBUGL)printf("<RBrace>\n"); return(TOK_RBRACE);}
printvar {if(DEBUGL)printf("<Printvar>\n"); return(TOK_PRINTVAR);}
"int" {sscanf(yytext, "%s", yylval.id);if(DEBUGL)printf("<Int>\n"); return(TOK_TYPE);}
"float" {sscanf(yytext, "%s", yylval.id);if(DEBUGL)printf("<Float>\n"); return(TOK_TYPE);}
";" {if(DEBUGL)printf("<Semi>\n"); return(TOK_SEMI);}
[0-9]+ { sscanf(yytext, "%d", &yylval.number.value.int_value);yylval.number.type=0; if(DEBUGL)printf("<Int>: %s\n", yytext); return(TOK_INT);}
[0-9]\.[0-9]+ { sscanf(yytext, "%f", &yylval.number.value.float_value);yylval.number.type=1;if(DEBUGL)printf("<Float>: %s\n", yytext); return(TOK_FLOAT);}
[a-z][a-z0-9]* {sscanf(yytext, "%s", yylval.id); if(DEBUGL)printf("<ID>: %s\n", yytext); return(TOK_ID);}
"+" {if(DEBUGL)printf("<Add>\n"); return(TOK_ADD);}
"-" {if(DEBUGL)printf("<Sub>\n"); return(TOK_SUB);}
"*" {if(DEBUGL)printf("<Mul>\n"); return(TOK_MUL);}
"/" {if(DEBUGL)printf("<Div>\n"); return(TOK_DIV);}
"=" {if(DEBUGL)printf("<Eq>\n"); return(TOK_EQ);}
[ \n]
[ \t]
\" {printf("Line %d: Syntax error\n", yylineno); exit(1);}
\' {printf("Line %d: Syntax error\n", yylineno); exit(1);}
. {printf("Line %d: Syntax error\n", yylineno); exit(1);}
;

%%