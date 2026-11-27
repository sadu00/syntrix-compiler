
#include <stdio.h>
#include <string.h>
#include "symbol_table.h"

extern int yylineno;

Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;
int semantic_error = 0;

int current_scope = 0;

void init_symbol_table(void) {
    symbol_count = 0;
    semantic_error = 0;
    current_scope = 0;
}

void enter_scope(void) {
    if (current_scope < MAX_SCOPES - 1) {
        current_scope++;
    } else {
        printf("Semantic Error at line %d: Maximum scope limit reached.\n",
               yylineno);
        semantic_error = 1;
    }
}

void exit_scope(void) {
    if (current_scope > 0) {
        int i = 0;

        while (i < symbol_count) {
            if (symbol_table[i].scope_level == current_scope) {
                for (int j = i; j < symbol_count - 1; j++) {
                    symbol_table[j] = symbol_table[j + 1];
                }
                symbol_count--;
            } else {
                i++;
            }
        }

        current_scope--;
    }
}

const char *get_type_name(DataType type) {
    switch (type) {
        case TYPE_INT: return "int";
        case TYPE_FLOAT: return "float";
        case TYPE_BOOL: return "bool";
        case TYPE_CHAR: return "char";
        case TYPE_STRING: return "string";
        default: return "unknown";
    }
}

int get_symbol(const char *name, Symbol *result) {
    for (int i = symbol_count - 1; i >= 0; i--) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            if (result != NULL) {
                *result = symbol_table[i];
            }
            return 1;
        }
    }

    return 0;
}

int check_type_compatibility(DataType target, DataType source) {
    if (target == source) {
        return 1;
    }

    if (target == TYPE_FLOAT && source == TYPE_INT) {
        return 1;
    }

    return 0;
}

int add_symbol(const char *name, DataType type,
               double value, int initialized) {

    for (int i = symbol_count - 1; i >= 0; i--) {
        if (symbol_table[i].scope_level < current_scope) {
            break;
        }

        if (symbol_table[i].scope_level == current_scope &&
            strcmp(symbol_table[i].name, name) == 0) {

            printf("Semantic Error at line %d: Variable '%s' already declared in this scope.\n",
                   yylineno, name);
            semantic_error = 1;
            return 0;
        }
    }

    if (symbol_count >= MAX_SYMBOLS) {
        printf("Semantic Error at line %d: Symbol table is full.\n",
               yylineno);
        semantic_error = 1;
        return 0;
    }

    strcpy(symbol_table[symbol_count].name, name);
    symbol_table[symbol_count].type = type;
    symbol_table[symbol_count].value = value;
    symbol_table[symbol_count].initialized = initialized;
    symbol_table[symbol_count].scope_level = current_scope;

    symbol_count++;
    return 1;
}

int update_symbol(const char *name, double value) {
    for (int i = symbol_count - 1; i >= 0; i--) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            symbol_table[i].value = value;
            symbol_table[i].initialized = 1;
            return 1;
        }
    }

    printf("Semantic Error at line %d: Variable '%s' is not declared.\n",
           yylineno, name);
    semantic_error = 1;
    return 0;
}

void print_symbol_table(void) {
    printf("\n========== SYMBOL TABLE ==========\n");
    printf("%-15s %-12s %-12s %-10s\n",
           "Name", "Data Type", "Value", "Scope");
    printf("--------------------------------------------------\n");

    for (int i = 0; i < symbol_count; i++) {
        printf("%-15s %-12s ",
               symbol_table[i].name,
               get_type_name(symbol_table[i].type));

        if (symbol_table[i].initialized) {
            printf("%-12g ", symbol_table[i].value);
        } else {
            printf("%-12s ", "Not set");
        }

        printf("%-10d\n", symbol_table[i].scope_level);
    }

    printf("==================================================\n");
}
