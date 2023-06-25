%{
#include <stdio.h>
#include "calc.tab.h"
%}

%%
"main()" {printf("<Main>\n"); return(TOK_MAIN);}
"{" {printf("<LBrace>\n"); return(TOK_LBRACE);}
"}" {printf("<RBrace>\n"); return(TOK_RBRACE);}
"int" {printf("<Int>\n"); return(TOK_INT_TYPE);}
"float" {printf("<Float>\n"); return(TOK_FLOAT_TYPE);}
[0-9]+ {printf("<Int>: %s\n", yytext); return(TOK_INT);}
[0-9]\.[0-9]+ {printf("<Float>: %s\n", yytext); return(TOK_FLOAT);}
printvar {printf("<Printvar>\n"); return(TOK_PRINTVAR);}
[a-z][a-z0-9]* {printf("<ID>: %s\n", yytext); return(TOK_ID);}
"+" {printf("<Add>\n"); return(TOK_ADD);}
"-" {printf("<Sub>\n"); return(TOK_SUB);}
"*" {printf("<Mul>\n"); return(TOK_MUL);}
"/" {printf("<Div>\n"); return(TOK_DIV);}
"=" {printf("<Eq>\n"); return(TOK_EQ);}
";" {printf("<Semi>\n"); return(TOK_SEMI);}
[ \n] ;
[ \t] ;
%%

// int main(){
//     yylex();
// }