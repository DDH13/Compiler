%{
    #include <stdio.h>
    #include <stdlib.h>
    extern FILE* yyin;
extern int yylex();
%}

%token TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_EQ TOK_SEMI TOK_FLOAT TOK_INT TOK_PRINTVAR TOK_INT_TYPE TOK_FLOAT_TYPE TOK_MAIN TOK_ID TOK_LBRACE TOK_RBRACE
%union {
    int int_val;
    float float_val;
    char* string_val;
}
%type <int_val> E
%type <int_val> TOK_ID

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%
Prog: TOK_MAIN TOK_LBRACE Stmts TOK_RBRACE
Stmts: Stmt TOK_SEMI Stmts | ;
Stmt: 
TOK_INT_TYPE TOK_ID 
| TOK_FLOAT_TYPE TOK_ID 
| TOK_ID TOK_EQ E 
| TOK_PRINTVAR TOK_ID { printf("%d\n", $2); }
E: 
TOK_INT 
| TOK_FLOAT 
| TOK_ID 
| E TOK_ADD E {$$=$1+$3;}
| E TOK_SUB E {$$=$1-$3;}

%%
int yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
    return 0;
}
int main(int argc, char **argv) {
    
    //check for correct number of arguments
    if (argc != 2) {
        fprintf(stderr, "Usage: ./calc filename\n");
        return 1;
    }
    
    // Open the file and set it to yyin
    char filename[100];
    snprintf(filename, sizeof(filename), "testcases/%s", argv[1]);
    yyin = fopen(filename, "r");
    if (yyin == NULL) {
        fprintf(stderr, "Error: could not open %s\n", filename);
        return 1;
    }
    printf("Opened %s:\n\n", filename);
    int c;
    while ((c = fgetc(yyin)) != EOF) {
        putchar(c);
    }
    printf("\n\n");
    //reset the file pointer to the beginning of the file
    fseek(yyin, 0, SEEK_SET);


    //call yyparse
    yyparse();
    return 0;

}
