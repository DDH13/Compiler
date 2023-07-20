%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    extern FILE* yyin;
    extern int yylex();
    int DEBUGY = 1;
    extern int yylineno;
%}
%locations

%token TOK_ADD TOK_SUB TOK_MUL TOK_DIV TOK_EQ TOK_SEMI TOK_FLOAT TOK_INT TOK_PRINTVAR TOK_TYPE TOK_MAIN TOK_ID TOK_LBRACE TOK_RBRACE

%code requires{
    //To store the value of a variable either int or float
    typedef union Val {
        int int_value;
        float float_value;
    } Val;

    //To store the value of a variable and its type
    typedef struct Num{
        int type;  //0 for int, 1 for float
        Val value;
    } Num;

}
%union {
    char id[50];
    Num number;
}

%type <id> TOK_ID TOK_TYPE
%type <number> Expr TOK_INT TOK_FLOAT

%left TOK_ADD TOK_SUB
%left TOK_MUL TOK_DIV

%{
    // a linked list of variable names and values
    typedef struct var {
        char* name;
        Num number;
        struct var* next;
    } var;

    //HEAD pointer for the linked list of variables
    var* head = NULL;

    //a function to declare a variable
    void declare_var(char* name, char* type) {

        //check if the variable is already declared 
        var* current = head;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                printf("Line %d: %s is already declared\n", yylineno, name);
                exit(1);
            }
            current = current->next;
        }

        //allocate memory for the new variable
        var* temp = malloc(sizeof(var));
        temp->name = malloc(strlen(name) + 1);
        strcpy(temp->name, name);
        if (strcmp(type, "int") == 0) {
            temp->number.type = 0;
        }
        else if (strcmp(type, "float") == 0) {
            temp->number.type = 1;
        }
        else {
            printf("Line %d: Type Error\n", yylineno);
            exit(1);
        }
        temp->next = NULL;

        //add the new variable to the list
        if (head == NULL) {
            head = temp;
        }
        else {
            var* current = head;
            while (current->next != NULL) {
                current = current->next;
            }
            current->next = temp;
        }



    }
    
    // a function to assign a value to a declared variable
    int assign_var(char* name, Val value) {
        var* current = head;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                if (current->number.type == 0) {
                    current->number.value.int_value = value.int_value;
                }
                else if (current->number.type == 1) {
                    current->number.value.float_value = value.float_value;
                }
                return 0;
            }
            current = current->next;
        }
        printf("Line %d: %s is used but not declared\n", yylineno, name);
        exit(1);
    }

    // a function to get the value of a variable
    Num get_var(char* name) {
        var* current = head;
        Num tempstruct;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                tempstruct.type = current->number.type;
                tempstruct.value = current->number.value;
                return tempstruct;
            }
            current = current->next;
        }
        printf("Line %d: %s is used but not declared\n", yylineno, name);
        exit(1);
    }

    // a function to check if a variable is an int or a float
    int get_type(char* name) {
        var* current = head;
        while (current != NULL) {
            if (strcmp(current->name, name) == 0) {
                return current->number.type;
            }
            current = current->next;
        }
        printf("Line %d: %s is used but not declared\n", yylineno, name);
        exit(1);
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
            if (current->number.type == 0) {
                printf("%s\t%d\t%d\n", current->name, current->number.value.int_value, current->number.type);
            }
            else {
                printf("%s\t%.2f\t%d\n", current->name, current->number.value.float_value, current->number.type);
            }
            current = current->next;
        }
    }

    Num add(Num a,Num b){
        Num temp;
        if(a.type==0 && b.type==0){
            temp.type=0;
            if(DEBUGY)printf("adding %d and %d\n", a.value.int_value, b.value.int_value);
            temp.value.int_value=a.value.int_value+b.value.int_value;
        }
        else if(a.type==1 && b.type==1){
            temp.type=1;
            if(DEBUGY)printf("adding %f and %f\n", a.value.float_value, b.value.float_value);
            temp.value.float_value=a.value.float_value+b.value.float_value;
        }
        else{
            printf("Line %d: Type Error\n", yylineno);
            exit(1);
        }
        return temp;
    }
    Num subtract(Num a,Num b){
        Num temp;
        if(a.type==0 && b.type==0){
            temp.type=0;
            if(DEBUGY)printf("subtracting %d and %d\n", a.value.int_value, b.value.int_value);
            temp.value.int_value=a.value.int_value-b.value.int_value;
        }
        else if(a.type==1 && b.type==1){
            temp.type=1;
            if(DEBUGY)printf("subtracting %f and %f\n", a.value.float_value, b.value.float_value);
            temp.value.float_value=a.value.float_value-b.value.float_value;
        }
        else{
            printf("Line %d: Type Error\n", yylineno);
            exit(1);
        }
        return temp;
    }
    Num divide(Num a,Num b){
        Num temp;
        if(a.type==0 && b.type==0){
            temp.type=0;
            if(DEBUGY)printf("dividing %d and %d\n", a.value.int_value, b.value.int_value);
            temp.value.int_value=a.value.int_value/b.value.int_value;
        }
        else if(a.type==1 && b.type==1){
            temp.type=1;
            if(DEBUGY)printf("dividing %f and %f\n", a.value.float_value, b.value.float_value);
            temp.value.float_value=a.value.float_value/b.value.float_value;
        }
        else{
            printf("Line %d: Type Error\n", yylineno);
            exit(1);
        }
        return temp;
    }
    Num multiply(Num a,Num b){
        Num temp;
        if(a.type==0 && b.type==0){
            temp.type=0;
            if(DEBUGY)printf("multiplying %d and %d\n", a.value.int_value, b.value.int_value);
            temp.value.int_value=a.value.int_value*b.value.int_value;
        }
        else if(a.type==1 && b.type==1){
            temp.type=1;
            if(DEBUGY)printf("multiplying %f and %f\n", a.value.float_value, b.value.float_value);
            temp.value.float_value=a.value.float_value*b.value.float_value;
        }
        else{
            printf("Line %d: Type Error\n", yylineno);
            exit(1);
        }
        return temp;
    }
    void print_num(Num a){
        if(a.type==0){
            printf("%d\n", a.value.int_value);
        }
        else if(a.type==1){
            printf("%f\n", a.value.float_value);
        }
    }

%}

%%
Program: TOK_MAIN TOK_LBRACE Stmts TOK_RBRACE
Stmts: Stmt Stmts | Stmt
Stmt:  
    DclStmt 
    | PrintStmt 
    | AssignStmt 
    | Expr TOK_SEMI

DclStmt: TOK_TYPE TOK_ID TOK_SEMI {
    if(DEBUGY)printf("declaring %s as %s\n", $2, $1); 
    declare_var($2, $1); 
    if(DEBUGY)print_list();
    }
AssignStmt: TOK_ID TOK_EQ Expr TOK_SEMI {
        if (get_type($1) == 0 && $3.type == 0) {
            if(DEBUGY)printf("assigning %d to %s\n", $3.value.int_value, $1);
        }
        else if (get_type($1) == 1 && $3.type == 1) {
            if(DEBUGY)printf("assigning %f to %s\n", $3.value.float_value, $1);
        }
        else{
            printf("Line %d: Type Error\n", yylineno);
            exit(1);
        }
        assign_var($1, $3.value);
        if(DEBUGY)print_list();
    }

PrintStmt: TOK_PRINTVAR TOK_ID TOK_SEMI {print_num(get_var($2));}
    | TOK_PRINTVAR Expr TOK_SEMI {print_num($2);}

Expr:
    Expr TOK_ADD Expr  {$$ = add($1,$3);}
    | Expr TOK_SUB Expr {$$ = subtract($1,$3);}
    | Expr TOK_MUL Expr {$$ = multiply($1,$3);}
    | Expr TOK_DIV Expr {$$ = divide($1,$3);}

    | TOK_INT {
        if(DEBUGY)printf("int %d\n", $1.value.int_value); 
        $$ = $1;
    }
    | TOK_FLOAT {
        if(DEBUGY)printf("float %f\n", $1.value.float_value);
        $$ = $1;
    }
    | TOK_ID { 
        Num temp;
        if (get_type($1) == 0) {
            temp.type = 0;
            temp.value.int_value = get_var($1).value.int_value;
            if(DEBUGY)printf("id %s = %d\n", $1,temp.value.int_value);
            $$ = temp;
        }
        else if (get_type($1) == 1) {
            temp.type = 1;
            temp.value.float_value = get_var($1).value.float_value;
            if(DEBUGY)printf("id %s = %f\n", $1,temp.value.float_value);
            $$ = temp;
        }
    }

%%
int yyerror(char *s) {
    fprintf(stderr, "Line: %d\t %s\n",yylineno,s);
    return 0;
}

int main() {
    // Set the input file as the input source for the parser
    yyset_in(stdin);

    //print file contents
    if (DEBUGY) {
        printf("File contents:\n");
        char c;
        while ((c = fgetc(yyin)) != EOF) {
            printf("%c", c);
        }
        rewind(yyin);
        printf("\n\n");
    }

    // Call the parser
    yyparse();

    //print out the list of variables
    if (DEBUGY) {printf("\nFinal symbol table\n");print_list();}


    return 0;
}


