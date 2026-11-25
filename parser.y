
%code requires {
    #include "symbol_table.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include "symbol_table.h"

int yylex(void);
void yyerror(const char *s);

extern int yylineno;
%}

%union {
    double num;
    char *str;
    DataType type;
    ExprValue expr;
}

%token INT FLOAT CHAR STRING
%token IF ELSE WHILE FOR RETURN PRINT

%token <num> NUMBER FLOAT_NUM
%token <str> ID STRING_LITERAL

%token EQ NE GE LE GT LT
%token ASSIGN PLUS MINUS MULTIPLY DIVIDE
%token SEMICOLON COMMA
%token LPAREN RPAREN LBRACE RBRACE
%token INVALID

%type <expr> expression
%type <type> data_type

%left EQ NE GT LT GE LE
%left PLUS MINUS
%left MULTIPLY DIVIDE

%start program

%%

program:
    statements
    ;

statements:
      statements statement
    | statement
    ;

statement:
      declaration
    | assignment
    | print_statement
    | if_statement
    | while_statement
    | return_statement
    | block
    ;

declaration:
    data_type ID SEMICOLON
    {
        if (!semantic_error) {
            add_symbol($2, $1, 0, 0);
        }
        free($2);
    }
    | data_type ID ASSIGN expression SEMICOLON
    {
        if (!semantic_error) {
            if (check_type_compatibility($1, $4.type)) {
                add_symbol($2, $1, $4.value, 1);
            } else {
                printf("Semantic Error at line %d: Cannot assign %s value to %s variable '%s'.\n",
                       yylineno,
                       get_type_name($4.type),
                       get_type_name($1), $2);
                semantic_error = 1;
            }
        }
        free($2);
    }
    ;

data_type:
      INT       { $$ = TYPE_INT; }
    | FLOAT     { $$ = TYPE_FLOAT; }
    | CHAR      { $$ = TYPE_CHAR; }
    | STRING    { $$ = TYPE_STRING; }
    ;

assignment:
    ID ASSIGN expression SEMICOLON
    {
        Symbol sym;

        if (!semantic_error) {
            if (get_symbol($1, &sym)) {
                if (check_type_compatibility(sym.type, $3.type)) {
                    update_symbol($1, $3.value);
                } else {
                    printf("Semantic Error at line %d: Type mismatch for variable '%s'.\n",
                           yylineno, $1);
                    semantic_error = 1;
                }
            } else {
                printf("Semantic Error at line %d: Variable '%s' is not declared.\n",
                       yylineno, $1);
                semantic_error = 1;
            }
        }

        free($1);
    }
    ;

print_statement:
      PRINT LPAREN expression RPAREN SEMICOLON
    | PRINT LPAREN STRING_LITERAL RPAREN SEMICOLON
    ;

if_statement:
      IF LPAREN expression RPAREN block
    | IF LPAREN expression RPAREN block ELSE block
    ;

while_statement:
    WHILE LPAREN expression RPAREN block
    ;

return_statement:
    RETURN expression SEMICOLON
    ;

block:
    LBRACE { enter_scope(); } statements RBRACE
    {
        exit_scope();
    }
    ;

expression:
      expression PLUS expression
        {
            $$.value = $1.value + $3.value;
            $$.type = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT)
                      ? TYPE_FLOAT : TYPE_INT;
        }
    | expression MINUS expression
        {
            $$.value = $1.value - $3.value;
            $$.type = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT)
                      ? TYPE_FLOAT : TYPE_INT;
        }
    | expression MULTIPLY expression
        {
            $$.value = $1.value * $3.value;
            $$.type = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT)
                      ? TYPE_FLOAT : TYPE_INT;
        }
    | expression DIVIDE expression
        {
            if ($3.value == 0) {
                printf("Semantic Error at line %d: Division by zero.\n",
                       yylineno);
                semantic_error = 1;
                $$.value = 0;
            } else {
                $$.value = $1.value / $3.value;
            }

            $$.type = ($1.type == TYPE_FLOAT || $3.type == TYPE_FLOAT)
                      ? TYPE_FLOAT : TYPE_INT;
        }
    | expression EQ expression
        {
            $$.value = ($1.value == $3.value);
            $$.type = TYPE_INT;
        }
    | expression NE expression
        {
            $$.value = ($1.value != $3.value);
            $$.type = TYPE_INT;
        }
    | expression GT expression
        {
            $$.value = ($1.value > $3.value);
            $$.type = TYPE_INT;
        }
    | expression LT expression
        {
            $$.value = ($1.value < $3.value);
            $$.type = TYPE_INT;
        }
    | expression GE expression
        {
            $$.value = ($1.value >= $3.value);
            $$.type = TYPE_INT;
        }
    | expression LE expression
        {
            $$.value = ($1.value <= $3.value);
            $$.type = TYPE_INT;
        }
    | LPAREN expression RPAREN
        {
            $$ = $2;
        }
    | NUMBER
        {
            $$.value = $1;
            $$.type = TYPE_INT;
        }
    | FLOAT_NUM
        {
            $$.value = $1;
            $$.type = TYPE_FLOAT;
        }
    | ID
        {
            Symbol sym;

            if (get_symbol($1, &sym)) {
                if (sym.initialized) {
                    $$.value = sym.value;
                    $$.type = sym.type;
                } else {
                    printf("Semantic Error at line %d: Variable '%s' is not initialized.\n",
                           yylineno, $1);
                    semantic_error = 1;
                    $$.value = 0;
                    $$.type = sym.type;
                }
            } else {
                printf("Semantic Error at line %d: Variable '%s' is not declared.\n",
                       yylineno, $1);
                semantic_error = 1;
                $$.value = 0;
                $$.type = TYPE_INT;
            }

            free($1);
        }
    ;

%%

void yyerror(const char *s) {
    printf("Syntax Error at line %d: %s\n", yylineno, s);
}
