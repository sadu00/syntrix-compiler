
#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_SYMBOLS 100

typedef enum {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_CHAR,
    TYPE_STRING
} DataType;

typedef struct {
    char name[100];
    DataType type;
    double value;
    int initialized;
} Symbol;

extern Symbol symbol_table[MAX_SYMBOLS];
extern int symbol_count;
extern int semantic_error;

void init_symbol_table(void);

int add_symbol(const char *name, DataType type, double value, int initialized);

int update_symbol(const char *name, double value);

int get_symbol(const char *name, Symbol *result);

void print_symbol_table(void);

const char *get_type_name(DataType type);

#endif
