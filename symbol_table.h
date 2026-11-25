
#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define MAX_SYMBOLS 100
#define MAX_SCOPES 50

typedef enum {
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_CHAR,
    TYPE_STRING
} DataType;

typedef struct {
    double value;
    DataType type;
} ExprValue;

typedef struct {
    char name[100];
    DataType type;
    double value;
    int initialized;
    int scope_level;
} Symbol;

extern Symbol symbol_table[MAX_SYMBOLS];
extern int symbol_count;
extern int semantic_error;

void init_symbol_table(void);

void enter_scope(void);
void exit_scope(void);

int add_symbol(const char *name, DataType type, double value, int initialized);

int update_symbol(const char *name, double value);

int get_symbol(const char *name, Symbol *result);

int check_type_compatibility(DataType target, DataType source);

void print_symbol_table(void);

const char *get_type_name(DataType type);

#endif
