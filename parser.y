
%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

int yylex(void);
void yyerror(const char *s);

extern int yylineno;

Stmt *syntax_tree = NULL;
%}

%code requires {
    #include "ast.h"
}

%union {
    double num;
    char *str;
    DataType type;
    Expr *expr;
    Stmt *stmt;
}

%token INT FLOAT BOOL CHAR STRING
%token TRUE FALSE
%token IF ELSE WHILE FOR RETURN PRINT

%token <num> NUMBER FLOAT_NUM
%token <str> ID STRING_LITERAL

%token EQ NE GE LE GT LT
%token AND OR NOT
%token ASSIGN PLUS MINUS MULTIPLY DIVIDE MODULO

%token SEMICOLON COMMA
%token LPAREN RPAREN
%token LBRACE RBRACE
%token INVALID

%type <type> data_type
%type <expr> expression
%type <stmt> program statements statement block
%type <stmt> declaration assignment print_statement
%type <stmt> if_statement while_statement for_statement
%type <stmt> for_init for_update

%left OR
%left AND
%right NOT
%nonassoc EQ NE GT LT GE LE
%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program:
    statements
    {
        syntax_tree = $1;
    }
    ;

statements:
    statements statement
    {
        $$ = $1;
        append_statement(&$$, $2);
    }
    |
    statement
    {
        $$ = NULL;
        append_statement(&$$, $1);
    }
    ;

statement:
    declaration
    {
        $$ = $1;
    }
    |
    assignment
    {
        $$ = $1;
    }
    |
    print_statement
    {
        $$ = $1;
    }
    |
    if_statement
    {
        $$ = $1;
    }
    |
    while_statement
    {
        $$ = $1;
    }
    |
    for_statement
    {
        $$ = $1;
    }
    |
    block
    {
        $$ = $1;
    }
    ;

data_type:
    INT
    {
        $$ = TYPE_INT;
    }
    |
    FLOAT
    {
        $$ = TYPE_FLOAT;
    }
    |
    BOOL
    {
        $$ = TYPE_BOOL;
    }
    |
    CHAR
    {
        $$ = TYPE_CHAR;
    }
    |
    STRING
    {
        $$ = TYPE_STRING;
    }
    ;

declaration:
    data_type ID SEMICOLON
    {
        $$ = create_statement(STMT_DECLARATION);
        $$->name = $2;
        $$->data_type = $1;
    }
    ;

assignment:
    ID ASSIGN expression SEMICOLON
    {
        $$ = create_statement(STMT_ASSIGNMENT);
        $$->name = $1;
        $$->expression = $3;
    }
    ;

print_statement:
    PRINT expression SEMICOLON
    {
        $$ = create_statement(STMT_PRINT_EXPR);
        $$->expression = $2;
    }
    |
    PRINT LPAREN STRING_LITERAL RPAREN SEMICOLON
    {
        $$ = create_statement(STMT_PRINT_STRING);
        $$->string_value = $3;
    }
    ;

if_statement:
    IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
    {
        $$ = create_statement(STMT_IF);
        $$->condition = $3;
        $$->body = $5;
    }
    |
    IF LPAREN expression RPAREN statement ELSE statement
    {
        $$ = create_statement(STMT_IF);
        $$->condition = $3;
        $$->body = $5;
        $$->else_body = $7;
    }
    ;

while_statement:
    WHILE LPAREN expression RPAREN statement
    {
        $$ = create_statement(STMT_WHILE);
        $$->condition = $3;
        $$->body = $5;
    }
    ;

for_init:
    ID ASSIGN expression
    {
        $$ = create_statement(STMT_ASSIGNMENT);
        $$->name = $1;
        $$->expression = $3;
    }
    ;

for_update:
    ID ASSIGN expression
    {
        $$ = create_statement(STMT_ASSIGNMENT);
        $$->name = $1;
        $$->expression = $3;
    }
    ;

for_statement:
    FOR LPAREN for_init SEMICOLON expression SEMICOLON for_update RPAREN statement
    {
        $$ = create_statement(STMT_FOR);
        $$->init = $3;
        $$->condition = $5;
        $$->update = $7;
        $$->body = $9;
    }
    ;

block:
    LBRACE statements RBRACE
    {
        $$ = create_statement(STMT_BLOCK);
        $$->body = $2;
    }
    ;

expression:
    NUMBER
    {
        $$ = create_number($1, EXPR_NUMBER);
    }
    |
    FLOAT_NUM
    {
        $$ = create_number($1, EXPR_FLOAT);
    }
    |
    TRUE
    {
        $$ = create_boolean(1);
    }
    |
    FALSE
    {
        $$ = create_boolean(0);
    }
    |
    ID
    {
        $$ = create_variable($1);
    }
    |
    LPAREN expression RPAREN
    {
        $$ = $2;
    }
    |
    expression PLUS expression
    {
        $$ = create_binary('+', $1, $3);
    }
    |
    expression MINUS expression
    {
        $$ = create_binary('-', $1, $3);
    }
    |
    expression MULTIPLY expression
    {
        $$ = create_binary('*', $1, $3);
    }
    |
    expression DIVIDE expression
    {
        $$ = create_binary('/', $1, $3);
    }
    |
    expression MODULO expression
    {
        $$ = create_binary('%', $1, $3);
    }
    |
    expression GT expression
    {
        $$ = create_binary('>', $1, $3);
    }
    |
    expression LT expression
    {
        $$ = create_binary('<', $1, $3);
    }
    |
    expression GE expression
    {
        $$ = create_binary('G', $1, $3);
    }
    |
    expression LE expression
    {
        $$ = create_binary('L', $1, $3);
    }
    |
    expression EQ expression
    {
        $$ = create_binary('E', $1, $3);
    }
    |
    expression NE expression
    {
        $$ = create_binary('N', $1, $3);
    }
    |
    expression AND expression
    {
        $$ = create_binary('&', $1, $3);
    }
    |
    expression OR expression
    {
        $$ = create_binary('|', $1, $3);
    }
    |
    NOT expression
    {
        $$ = create_unary('!', $2);
    }
    ;

%%

void yyerror(const char *s)
{
    printf("Syntax Error at line %d: %s\n", yylineno, s);
}
