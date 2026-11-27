
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tac.h"

static int temp_count = 0;
static int label_count = 0;

static char *new_temp(void)
{
    char buffer[30];

    sprintf(buffer, "t%d", ++temp_count);

    return strdup(buffer);
}

static char *new_label(void)
{
    char buffer[30];

    sprintf(buffer, "L%d", ++label_count);

    return strdup(buffer);
}

static const char *operator_name(int operation)
{
    switch (operation) {
        case '+': return "+";
        case '-': return "-";
        case '*': return "*";
        case '/': return "/";
        case '%': return "%";

        case '>': return ">";
        case '<': return "<";
        case 'G': return ">=";
        case 'L': return "<=";
        case 'E': return "==";
        case 'N': return "!=";

        case '&': return "&&";
        case '|': return "||";

        default: return "?";
    }
}

static char *generate_expression_tac(Expr *expression)
{
    if (expression == NULL) {
        return strdup("0");
    }

    char *left;
    char *right;
    char *result;

    switch (expression->kind) {

        case EXPR_NUMBER:
        case EXPR_FLOAT:
        {
            char buffer[50];

            sprintf(buffer, "%g", expression->value);

            return strdup(buffer);
        }

        case EXPR_BOOLEAN:
            return strdup(expression->value ? "true" : "false");

        case EXPR_VARIABLE:
            return strdup(expression->name);

        case EXPR_UNARY:
        {
            right = generate_expression_tac(expression->right);
            result = new_temp();

            printf("%s = !%s\n", result, right);

            return result;
        }

        case EXPR_BINARY:
        {
            left = generate_expression_tac(expression->left);
            right = generate_expression_tac(expression->right);

            result = new_temp();

            printf("%s = %s %s %s\n",
                   result,
                   left,
                   operator_name(expression->operation),
                   right);

            return result;
        }
    }

    return strdup("0");
}

static void generate_statement_tac(Stmt *statement);

static void generate_list_tac(Stmt *statement)
{
    while (statement != NULL) {
        generate_statement_tac(statement);
        statement = statement->next;
    }
}

static void generate_statement_tac(Stmt *statement)
{
    if (statement == NULL) {
        return;
    }

    char *value;
    char *condition;
    char *start_label;
    char *end_label;
    char *else_label;

    switch (statement->kind) {

        case STMT_DECLARATION:
            printf("declare %s %s\n",
                   get_type_name(statement->data_type),
                   statement->name);
            break;

        case STMT_ASSIGNMENT:
            value = generate_expression_tac(statement->expression);

            printf("%s = %s\n", statement->name, value);
            break;

        case STMT_PRINT_EXPR:
            value = generate_expression_tac(statement->expression);

            printf("print %s\n", value);
            break;

        case STMT_PRINT_STRING:
            printf("print %s\n", statement->string_value);
            break;

        case STMT_BLOCK:
            generate_list_tac(statement->body);
            break;

        case STMT_IF:

            condition = generate_expression_tac(statement->condition);

            if (statement->else_body == NULL) {

                end_label = new_label();

                printf("ifFalse %s goto %s\n",
                       condition, end_label);

                generate_statement_tac(statement->body);

                printf("%s:\n", end_label);

            } else {

                else_label = new_label();
                end_label = new_label();

                printf("ifFalse %s goto %s\n",
                       condition, else_label);

                generate_statement_tac(statement->body);

                printf("goto %s\n", end_label);

                printf("%s:\n", else_label);

                generate_statement_tac(statement->else_body);

                printf("%s:\n", end_label);
            }

            break;

        case STMT_WHILE:

            start_label = new_label();
            end_label = new_label();

            printf("%s:\n", start_label);

            condition = generate_expression_tac(statement->condition);

            printf("ifFalse %s goto %s\n",
                   condition, end_label);

            generate_statement_tac(statement->body);

            printf("goto %s\n", start_label);

            printf("%s:\n", end_label);

            break;

        case STMT_FOR:

            generate_statement_tac(statement->init);

            start_label = new_label();
            end_label = new_label();

            printf("%s:\n", start_label);

            condition = generate_expression_tac(statement->condition);

            printf("ifFalse %s goto %s\n",
                   condition, end_label);

            generate_statement_tac(statement->body);
            generate_statement_tac(statement->update);

            printf("goto %s\n", start_label);

            printf("%s:\n", end_label);

            break;
    }
}

void generate_tac(Stmt *program)
{
    temp_count = 0;
    label_count = 0;

    printf("\n");
    printf("========== THREE ADDRESS CODE ==========\n");

    generate_list_tac(program);

    printf("========================================\n");
}
