#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
        while (current != NULL) {
            printf("%s, %f, %d\n", current->name, current->value, current->type);
            current = current->next;
        }
    }
int main()
{
    declare_var("x", "int");
    declare_var("y", "float");
    declare_var("z", "int");
    declare_var("x", "int"); // Duplicate declaration
    print_list();
    assign_var("x", 5);
    assign_var("y", 3.14);
    assign_var("z", 10);

    printf("Value of x: %f\n", get_var("x")); // Expected output: 5.000000
    printf("Value of y: %f\n", get_var("y")); // Expected output: 3.140000
    printf("Value of z: %f\n", get_var("z")); // Expected output: 10.000000

    printf("Type of x: %d\n", get_type("x")); // Expected output: 0 (int)
    printf("Type of y: %d\n", get_type("y")); // Expected output: 1 (float)
    printf("Type of z: %d\n", get_type("z")); // Expected output: 0 (int)

    print_list();
    /*
    Expected output:
    name, value, type
    z, 10.000000, 0
    y, 3.140000, 1
    x, 5.000000, 0
    */

    return 0;
}
