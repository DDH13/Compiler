%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    extern FILE* yyin;
    extern int yylex();
    int DEBUGY = 1;
    
    typedef union ValueUnion {
        int int_value;
        float float_value;
    } ValueUnion;

    // a linked list of variable names and values
    typedef struct var {
        int type; //0 for int, 1 for float
        char* name;
        ValueUnion value;
        struct var* next;
    } var;

    //HEAD pointer for the linked list of variables
    var* head = NULL;

    // a function to add a variable to the linked list
    void add_var(char* name, ValueUnion value, int type) {
        var* new_var = malloc(sizeof(var));
        new_var->name = malloc(strlen(name) + 1);
        strcpy(new_var->name, name);
        if (type == 0) {
            new_var->value.int_value = (float)value.int_value;
        }
        else {
            new_var->value.float_value = (int)value.float_value;
        }
        new_var->type = type;
        new_var->next = head;
        head = new_var;
    }

    //a function to declare a variable
    void declare_var(char* name, char* type) {
        var* current = head;
        while (current != NULL) {
            // printf("comparing %s and %s\n", current->name, name);
            if (strcmp(current->name, name) == 0) {
                printf("Error: variable %s already declared\n", name);
                return;
            }
            current = current->next;
        }
        ValueUnion tempstruct;
        if (strcmp(type, "int") == 0) {
            tempstruct.int_value = -1;
            add_var(name, tempstruct, 0);
        }
        else if (strcmp(type, "float") == 0) {
            tempstruct.float_value = -1;
            add_var(name, tempstruct, 1);
        }
        else {
            printf("Error: invalid type %s\n", type);
            return;
        }
    }
    
    // a function to assign a value to a declared variable
    int assign_var(char* name, ValueUnion value) {
        var* current = head;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                if (current->type == 0) {
                    current->value.int_value = (int)value.int_value;
                }
                else if (current->type == 1) {
                    current->value.float_value = (float)value.float_value;
                }
                return 0;
            }
            current = current->next;
        }
        printf("Error: variable %s not declared\n", name);
        return 1;
    }

    // a function to get the value of a variable
    ValueUnion get_var(char* name) {
        var* current = head;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                return current->value;
            }
            current = current->next;
        }
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
            if (current->type == 0) {
                printf("%s\t%d\t%d\n", current->name, current->value.int_value, current->type);
            }
            else {
                printf("%s\t%.2f\t%d\n", current->name, current->value.float_value, current->type);
            }
            current = current->next;
        }
    }

%}

%token TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_EQ TOK_SEMI TOK_FLOAT TOK_INT TOK_PRINTVAR TOK_TYPE TOK_MAIN TOK_ID TOK_LBRACE TOK_RBRACE
%union {
    char id[50];
    int int_val;
    float float_val;
}

%type <id> TOK_ID TOK_TYPE
%type <int_val> IntExpr IntAssignStmt TOK_INT
%type <float_val> FloatExpr FloatAssignStmt TOK_FLOAT

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%%
Program: TOK_MAIN TOK_LBRACE Stmts TOK_RBRACE
Stmts: Stmt Stmts | Stmt
Stmt:  
    DclStmt 
    | PrintStmt 
    | IntAssignStmt 
    | IntExpr 
    | FloatAssignStmt
    | FloatExpr

DclStmt: TOK_TYPE TOK_ID TOK_SEMI {
    if(DEBUGY)printf("declaring %s as %s\n", $2, $1); 
        declare_var($2, $1); 
        print_list();
    }
IntAssignStmt: TOK_ID TOK_EQ IntExpr TOK_SEMI {
        if(get_type($1)==1) {printf("Type Error");return 1;}
        if(DEBUGY)printf("assigning %d to %s\n", $3, $1); 
        ValueUnion tempstruct;
        tempstruct.int_value = $3;
        assign_var($1, tempstruct);
        print_list();
    }
FloatAssignStmt: TOK_ID TOK_EQ FloatExpr TOK_SEMI {
        if(get_type($1)==0) {printf("Type Error");return 1;}
        ValueUnion tempstruct;
        tempstruct.float_value = $3;
        if(DEBUGY)printf("assigning %f to %s\n", $3, $1); 
        assign_var($1, tempstruct);
        print_list();
    }
PrintStmt: TOK_PRINTVAR TOK_ID TOK_SEMI {
        if(get_type($2)==1) printf("%f\n", get_var($2).float_value);
        else printf("%d\n", (int)get_var($2).int_value);
    }
FloatExpr: 
    FloatExpr TOK_ADD FloatExpr  {
        if(DEBUGY)printf("adding %f and %f\n", $1, $3); 
        $$ = $1 + $3;
    }
    | FloatExpr TOK_SUB FloatExpr  {
        if(DEBUGY)printf("subtracting %f and %f\n", $1, $3); 
        $$ = $1 - $3;
    }
    | FloatExpr TOK_MUL FloatExpr  {
        if(DEBUGY)printf("multiplying %f and %f\n", $1, $3); 
        $$ = $1 * $3;
    }
    | FloatExpr TOK_DIV FloatExpr  {
        if(DEBUGY)printf("dividing %f and %f\n", $1, $3); 
        $$ = $1 / $3;
    }
    | TOK_FLOAT {
        if(DEBUGY)printf("float %f\n", $1); 
        $$ = $1;
    }
    | TOK_ID { 
        if(DEBUGY)printf("id %s = %f\n", $1, get_var($1).float_value); 
        $$ = get_var($1).float_value;
    }

IntExpr:
    IntExpr TOK_ADD IntExpr  {
        if(DEBUGY)printf("adding %d and %d\n", $1, $3); 
        $$ = $1 + $3;
    }
    | IntExpr TOK_SUB IntExpr  {
        if(DEBUGY)printf("subtracting %d and %d\n", $1, $3); 
        $$ = $1 - $3;
    }
    | IntExpr TOK_MUL IntExpr    {
        if(DEBUGY)printf("multiplying %d and %d\n", $1, $3); 
        $$ = $1 * $3;
    }
    | IntExpr TOK_DIV IntExpr  {
        if(DEBUGY)printf("dividing %d and %d\n", $1, $3); 
        $$ = $1 / $3;
    }
    | TOK_INT {
        if(DEBUGY)printf("int %d\n", $1); 
        $$ = $1;
    }
    | TOK_ID { 
        if(DEBUGY)printf("id %s = %d\n", $1,get_var($1).int_value);
        $$ = get_var($1).int_value;
    }
    

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
