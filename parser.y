
%code requires {
    #include "ast.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

int yylex(void);
void yyerror(const char *s);

extern int yylineno;

Stmt *syntax_tree = NULL;
%}

%union {
    double num;
    char *str;
    DataType type;
    Expr *expr;
    Stmt *stmt;
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
%type <stmt> program statements statement
%type <stmt> declaration assignment print_statement
%type <stmt> if_statement while_statement for_statement block
%type <stmt> for_init for_update

%left EQ NE GT LT GE LE
%left PLUS MINUS
%left MULTIPLY DIVIDE

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start program

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
    | statement
      {
          $$ = $1;
      }
    ;

statement:
      declaration       { $$ = $1; }
    | assignment        { $$ = $1; }
    | print_statement  { $$ = $1; }
    | if_statement     { $$ = $1; }
    | while_statement  { $$ = $1; }
    | for_statement    { $$ = $1; }
    | block            { $$ = $1; }
    ;

declaration:
      data_type ID SEMICOLON
      {
          $$ = create_statement(STMT_DECLARATION);
          $$->name = $2;
          $$->data_type = $1;
      }
    | data_type ID ASSIGN expression SEMICOLON
      {
          $$ = create_statement(STMT_DECLARATION);
          $$->name = $2;
          $$->data_type = $1;
          $$->expression = $4;
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
        $$ = create_statement(STMT_ASSIGNMENT);
        $$->name = $1;
        $$->expression = $3;
    }
    ;

print_statement:
      PRINT LPAREN expression RPAREN SEMICOLON
      {
          $$ = create_statement(STMT_PRINT_EXPR);
          $$->expression = $3;
      }
    | PRINT LPAREN STRING_LITERAL RPAREN SEMICOLON
      {
          $$ = create_statement(STMT_PRINT_STRING);

          int length = strlen($3);
          $$->string_value = malloc(length - 1);

          if ($$->string_value != NULL) {
              memcpy($$->string_value, $3 + 1, length - 2);
              $$->string_value[length - 2] = '\0';
          }

          free($3);
      }
    ;

if_statement:
      IF LPAREN expression RPAREN block %prec LOWER_THAN_ELSE
      {
          $$ = create_statement(STMT_IF);
          $$->condition = $3;
          $$->body = $5;
      }
    | IF LPAREN expression RPAREN block ELSE block
      {
          $$ = create_statement(STMT_IF);
          $$->condition = $3;
          $$->body = $5;
          $$->else_body = $7;
      }
    ;

while_statement:
    WHILE LPAREN expression RPAREN block
    {
        $$ = create_statement(STMT_WHILE);
        $$->condition = $3;
        $$->body = $5;
    }
    ;

/* For loop initialization */

for_init:
      data_type ID ASSIGN expression
      {
          $$ = create_statement(STMT_DECLARATION);
          $$->name = $2;
          $$->data_type = $1;
          $$->expression = $4;
      }
    | ID ASSIGN expression
      {
          $$ = create_statement(STMT_ASSIGNMENT);
          $$->name = $1;
          $$->expression = $3;
      }
    | %empty
      {
          $$ = NULL;
      }
    ;

/* For loop update */

for_update:
      ID ASSIGN expression
      {
          $$ = create_statement(STMT_ASSIGNMENT);
          $$->name = $1;
          $$->expression = $3;
      }
    | %empty
      {
          $$ = NULL;
      }
    ;

/* For loop */

for_statement:
    FOR LPAREN for_init SEMICOLON expression SEMICOLON for_update RPAREN block
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
      expression PLUS expression
      {
          $$ = create_binary('+', $1, $3);
      }
    | expression MINUS expression
      {
          $$ = create_binary('-', $1, $3);
      }
    | expression MULTIPLY expression
      {
          $$ = create_binary('*', $1, $3);
      }
    | expression DIVIDE expression
      {
          $$ = create_binary('/', $1, $3);
      }
    | expression GT expression
      {
          $$ = create_binary('>', $1, $3);
      }
    | expression LT expression
      {
          $$ = create_binary('<', $1, $3);
      }
    | expression GE expression
      {
          $$ = create_binary('G', $1, $3);
      }
    | expression LE expression
      {
          $$ = create_binary('L', $1, $3);
      }
    | expression EQ expression
      {
          $$ = create_binary('E', $1, $3);
      }
    | expression NE expression
      {
          $$ = create_binary('N', $1, $3);
      }
    | LPAREN expression RPAREN
      {
          $$ = $2;
      }
    | NUMBER
      {
          $$ = create_number($1, EXPR_NUMBER);
      }
    | FLOAT_NUM
      {
          $$ = create_number($1, EXPR_FLOAT);
      }
    | ID
      {
          $$ = create_variable($1);
      }
    ;

%%

void yyerror(const char *s) {
    printf("Syntax Error at line %d: %s\n", yylineno, s);
}
