
%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
NUMBER      {DIGIT}+
FLOATNUM    {DIGIT}+"."{DIGIT}+

%%

"int"           { return INT; }
"float"         { return FLOAT; }
"char"          { return CHAR; }
"string"        { return STRING; }

"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }
"return"        { return RETURN; }
"print"         { return PRINT; }

"=="            { return EQ; }
"!="            { return NE; }
">="            { return GE; }
"<="            { return LE; }
">"             { return GT; }
"<"             { return LT; }

"="             { return ASSIGN; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULTIPLY; }
"/"             { return DIVIDE; }

";"             { return SEMICOLON; }
","             { return COMMA; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }

{FLOATNUM}      { yylval.num = atof(yytext); return FLOAT_NUM; }
{NUMBER}        { yylval.num = atoi(yytext); return NUMBER; }
{ID}            { yylval.str = strdup(yytext); return ID; }

\"([^\"\\\n]|\\.)*\"  { yylval.str = strdup(yytext); return STRING_LITERAL; }

[ \t\r\n]+      ;

"//".*          ;

. {
    printf("Lexical Error at line %d: Invalid character '%s'\n",
           yylineno, yytext);
    return INVALID;
}

%%
