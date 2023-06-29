%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    extern FILE* yyin;
    extern int yylex();
    
    // a linked list of variable names and values
    typedef struct var {
        int type; //0 for int, 1 for float
        char* name;
        float value;
        struct var* next;
    } var;

    //HEAD pointer for the linked list of variables
    var* head = NULL;

    // a function to add a variable to the linked list
    void add_var(char* name, float value, int type) {
        var* new_var = malloc(sizeof(var));
        new_var->name = malloc(strlen(name) + 1);
        strcpy(new_var->name, name);
        new_var->value = value;
        new_var->type = type;
        new_var->next = head;
        head = new_var;
    }

    //a function to declare a variable
    void declare_var(char* name, char* type) {
        var* current = head;
        while (current != NULL) {
            printf("comparing %s and %s\n", current->name, name);
            if (strcmp(current->name, name) == 0) {
                printf("Error: variable %s already declared\n", name);
                return;
            }
            current = current->next;
        }
        if (strcmp(type, "int") == 0) {
            add_var(name, 0, 0);
            printf("added %s as %s\n", name, type);
        }
        else if (strcmp(type, "float") == 0) {
            add_var(name, 0, 1);
            printf("added %s as %s\n", name, type);
        }
        else {
            printf("Error: invalid type %s\n", type);
            return;
        }
    }
    
    // a function to assign a value to a declared variable
    int assign_var(char* name, float value) {
        var* current = head;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                current->value = value;
                return 0;
            }
            current = current->next;
        }
        printf("Error: variable %s not declared\n", name);
        return 1;
    }

    // a function to get the value of a variable
    float get_var(char* name) {
        var* current = head;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                return current->value;
            }
            current = current->next;
        }
        return -1;
    }

    // a function to check if a variable is an int or a float
    int get_type(char* name) {
        var* current = head;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                return current->type;
            }
            current = current->next;
        }
        return -1;
    }

    // a function to print the list nicely name,value,type
    void print_list() {
        var* current = head;
        if (current == NULL) {
            printf("List is empty\n");
            return;
        }
        printf("name\tvalue\ttype\n");
        while (current != NULL) {
            printf("%s\t%.2f\t%d\n", current->name, current->value, current->type);
            current = current->next;
        }
    }

%}

%token TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_EQ TOK_SEMI TOK_FLOAT TOK_INT TOK_PRINTVAR TOK_TYPE TOK_MAIN TOK_ID TOK_LBRACE TOK_RBRACE
%union {
    char id[50];
    float both; //0 for int, 1 for float
}
%type <id> TOK_ID TOK_TYPE
%type <both> Expr AssignStmt TOK_INT TOK_FLOAT

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%
Program: TOK_MAIN TOK_LBRACE Stmts TOK_RBRACE
Stmts: Stmt Stmts | Stmt
Stmt:  
    DclStmt 
    | PrintStmt 
    | AssignStmt 
    | Expr 
DclStmt: TOK_TYPE TOK_ID TOK_SEMI{printf("declaring %s as %s\n", $2, $1); declare_var($2, $1); print_list();}
AssignStmt: TOK_ID TOK_EQ Expr TOK_SEMI{printf("assigning %f to %s\n", $3, $1); assign_var($1, $3); print_list();}
PrintStmt: TOK_PRINTVAR TOK_ID TOK_SEMI {if(get_type($2)==1) printf("%f\n", get_var($2)); else printf("%d\n", (int)get_var($2));}
Expr: 
    Expr TOK_ADD Expr  {printf("adding %f and %f\n", $1, $3); $$ = $1 + $3;}
    | Expr TOK_SUB Expr  {printf("subtracting %f and %f\n", $1, $3); $$ = $1 - $3;}
    | Expr TOK_MUL Expr  {printf("multiplying %f and %f\n", $1, $3); $$ = $1 * $3;}
    | Expr TOK_DIV Expr  {printf("dividing %f and %f\n", $1, $3); $$ = $1 / $3;}
    | TOK_INT {printf("int %f\n", $1); $$ = $1;}
    | TOK_ID { printf("id %s\n", $1); $$ = get_var($1);}
    

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
