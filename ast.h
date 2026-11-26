
#ifndef AST_H
#define AST_H

#include "symbol_table.h"

typedef enum {
    EXPR_NUMBER,
    EXPR_FLOAT,
    EXPR_VARIABLE,
    EXPR_BINARY
} ExprKind;

typedef struct Expr {
    ExprKind kind;
    double value;
    DataType type;
    char *name;
    int operation;
    struct Expr *left;
    struct Expr *right;
} Expr;

typedef enum {
    STMT_DECLARATION,
    STMT_ASSIGNMENT,
    STMT_PRINT_EXPR,
    STMT_PRINT_STRING,
    STMT_IF,
    STMT_WHILE,
    STMT_BLOCK
} StmtKind;

typedef struct Stmt {
    StmtKind kind;
    char *name;
    char *string_value;
    DataType data_type;
    Expr *expression;
    Expr *condition;
    struct Stmt *body;
    struct Stmt *else_body;
    struct Stmt *next;
} Stmt;

Expr *create_number(double value, ExprKind kind);
Expr *create_variable(char *name);
Expr *create_binary(int operation, Expr *left, Expr *right);

Stmt *create_statement(StmtKind kind);
void append_statement(Stmt **list, Stmt *statement);

void execute_program(Stmt *program);

#endif
