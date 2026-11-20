
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
%}

%union {
    double num;
    char *str;
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

%type <num> expression

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
    | data_type ID ASSIGN expression SEMICOLON
    ;

data_type:
      INT
    | FLOAT
    | CHAR
    | STRING
    ;

assignment:
    ID ASSIGN expression SEMICOLON
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
    LBRACE statements RBRACE
    ;

expression:
      expression PLUS expression       { $$ = $1 + $3; }
    | expression MINUS expression      { $$ = $1 - $3; }
    | expression MULTIPLY expression   { $$ = $1 * $3; }
    | expression DIVIDE expression     { $$ = $1 / $3; }
    | expression EQ expression         { $$ = ($1 == $3); }
    | expression NE expression         { $$ = ($1 != $3); }
    | expression GT expression         { $$ = ($1 > $3); }
    | expression LT expression         { $$ = ($1 < $3); }
    | expression GE expression         { $$ = ($1 >= $3); }
    | expression LE expression         { $$ = ($1 <= $3); }
    | LPAREN expression RPAREN         { $$ = $2; }
    | NUMBER                           { $$ = $1; }
    | FLOAT_NUM                        { $$ = $1; }
    | ID                               { $$ = 0; }
    ;

%%

void yyerror(const char *s) {
    printf("Syntax Error: %s\n", s);
}
