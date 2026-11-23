
#include <stdio.h>
#include <string.h>
#include "symbol_table.h"

Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;
int semantic_error = 0;

void init_symbol_table(void) {
    symbol_count = 0;
    semantic_error = 0;
}

const char *get_type_name(DataType type) {
    switch (type) {
        case TYPE_INT:
            return "int";

        case TYPE_FLOAT:
            return "float";

        case TYPE_CHAR:
            return "char";

        case TYPE_STRING:
            return "string";

        default:
            return "unknown";
    }
}

int get_symbol(const char *name, Symbol *result) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            if (result != NULL) {
                *result = symbol_table[i];
            }
            return 1;
        }
    }

    return 0;
}

int add_symbol(const char *name, DataType type,
               double value, int initialized) {

    if (get_symbol(name, NULL)) {
        printf("Semantic Error: Variable '%s' already declared.\n", name);
        semantic_error = 1;
        return 0;
    }

    if (symbol_count >= MAX_SYMBOLS) {
        printf("Semantic Error: Symbol table is full.\n");
        semantic_error = 1;
        return 0;
    }

    strcpy(symbol_table[symbol_count].name, name);
    symbol_table[symbol_count].type = type;
    symbol_table[symbol_count].value = value;
    symbol_table[symbol_count].initialized = initialized;

    symbol_count++;

    return 1;
}

int update_symbol(const char *name, double value) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            symbol_table[i].value = value;
            symbol_table[i].initialized = 1;
            return 1;
        }
    }

    printf("Semantic Error: Variable '%s' is not declared.\n", name);
    semantic_error = 1;
    return 0;
}

void print_symbol_table(void) {
    printf("\n========== SYMBOL TABLE ==========\n");

    printf("%-15s %-12s %-12s\n", "Name", "Data Type", "Value");

    printf("----------------------------------\n");

    for (int i = 0; i < symbol_count; i++) {
        printf("%-15s %-12s ",
               symbol_table[i].name,
               get_type_name(symbol_table[i].type));

        if (symbol_table[i].initialized) {
            printf("%-12g\n", symbol_table[i].value);
        } else {
            printf("%-12s\n", "Not set");
        }
    }

    printf("==================================\n");
}
