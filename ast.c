
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

static ExprValue evaluate_expression(Expr *expr) {
    ExprValue result = {0, TYPE_INT};

    if (expr == NULL) return result;

    Symbol sym;

    switch (expr->kind) {
        case EXPR_NUMBER:
        case EXPR_FLOAT:
            result.value = expr->value;
            result.type = expr->type;
            break;

        case EXPR_VARIABLE:
            if (get_symbol(expr->name, &sym) && sym.initialized) {
                result.value = sym.value;
                result.type = sym.type;
            } else {
                printf("Semantic Error: Variable '%s' is not initialized or declared.\n",
                       expr->name);
                semantic_error = 1;
            }
            break;

        case EXPR_BINARY: {
            ExprValue left = evaluate_expression(expr->left);
            ExprValue right = evaluate_expression(expr->right);

            result.type = TYPE_INT;

            switch (expr->operation) {
                case '+':
                    result.value = left.value + right.value;
                    result.type = (left.type == TYPE_FLOAT ||
                                   right.type == TYPE_FLOAT)
                                  ? TYPE_FLOAT : TYPE_INT;
                    break;

                case '-':
                    result.value = left.value - right.value;
                    result.type = (left.type == TYPE_FLOAT ||
                                   right.type == TYPE_FLOAT)
                                  ? TYPE_FLOAT : TYPE_INT;
                    break;

                case '*':
                    result.value = left.value * right.value;
                    result.type = (left.type == TYPE_FLOAT ||
                                   right.type == TYPE_FLOAT)
                                  ? TYPE_FLOAT : TYPE_INT;
                    break;

                case '/':
                    if (right.value == 0) {
                        printf("Semantic Error: Division by zero.\n");
                        semantic_error = 1;
                    } else {
                        result.value = left.value / right.value;
                        result.type = (left.type == TYPE_FLOAT ||
                                       right.type == TYPE_FLOAT)
                                      ? TYPE_FLOAT : TYPE_INT;
                    }
                    break;

                case '>':
                    result.value = left.value > right.value;
                    break;

                case '<':
                    result.value = left.value < right.value;
                    break;

                case 'G':
                    result.value = left.value >= right.value;
                    break;

                case 'L':
                    result.value = left.value <= right.value;
                    break;

                case 'E':
                    result.value = left.value == right.value;
                    break;

                case 'N':
                    result.value = left.value != right.value;
                    break;
            }
            break;
        }
    }

    return result;
}

void execute_program(Stmt *program) {
    Stmt *current = program;

    while (current != NULL && !semantic_error) {
        Symbol sym;

        switch (current->kind) {
            case STMT_DECLARATION: {
                double value = 0;
                int initialized = current->expression != NULL;

                if (initialized) {
                    ExprValue result =
                        evaluate_expression(current->expression);

                    if (!check_type_compatibility(current->data_type,
                                                  result.type)) {
                        printf("Semantic Error: Type mismatch in declaration of '%s'.\n",
                               current->name);
                        semantic_error = 1;
                        break;
                    }

                    value = result.value;
                }

                if (!semantic_error) {
                    add_symbol(current->name,
                               current->data_type,
                               value,
                               initialized);
                }
                break;
            }

            case STMT_ASSIGNMENT: {
                ExprValue result =
                    evaluate_expression(current->expression);

                if (get_symbol(current->name, &sym)) {
                    if (check_type_compatibility(sym.type, result.type)) {
                        update_symbol(current->name, result.value);
                    } else {
                        printf("Semantic Error: Type mismatch for variable '%s'.\n",
                               current->name);
                        semantic_error = 1;
                    }
                } else {
                    printf("Semantic Error: Variable '%s' is not declared.\n",
                           current->name);
                    semantic_error = 1;
                }
                break;
            }

            case STMT_PRINT_EXPR: {
                ExprValue result =
                    evaluate_expression(current->expression);

                if (!semantic_error) {
                    printf("%g\n", result.value);
                }
                break;
            }

            case STMT_PRINT_STRING:
                printf("%s\n", current->string_value);
                break;

            case STMT_IF:
                if (evaluate_expression(current->condition).value != 0) {
                    execute_program(current->body);
                } else if (current->else_body != NULL) {
                    execute_program(current->else_body);
                }
                break;

            case STMT_WHILE: {
                int iterations = 0;

                while (evaluate_expression(current->condition).value != 0
                       && !semantic_error) {

                    if (++iterations > 10000) {
                        printf("Runtime Error: Maximum loop limit reached.\n");
                        semantic_error = 1;
                        break;
                    }

                    execute_program(current->body);
                }
                break;
            }

            case STMT_BLOCK:
                enter_scope();
                execute_program(current->body);
                exit_scope();
                break;
        }

        current = current->next;
    }
}

Expr *create_number(double value, ExprKind kind) {
    Expr *expr = calloc(1, sizeof(Expr));

    if (!expr) exit(1);

    expr->kind = kind;
    expr->value = value;
    expr->type = (kind == EXPR_FLOAT) ? TYPE_FLOAT : TYPE_INT;

    return expr;
}

Expr *create_variable(char *name) {
    Expr *expr = calloc(1, sizeof(Expr));

    if (!expr) exit(1);

    expr->kind = EXPR_VARIABLE;
    expr->name = name;

    return expr;
}

Expr *create_binary(int operation, Expr *left, Expr *right) {
    Expr *expr = calloc(1, sizeof(Expr));

    if (!expr) exit(1);

    expr->kind = EXPR_BINARY;
    expr->operation = operation;
    expr->left = left;
    expr->right = right;

    return expr;
}

Stmt *create_statement(StmtKind kind) {
    Stmt *stmt = calloc(1, sizeof(Stmt));

    if (!stmt) exit(1);

    stmt->kind = kind;

    return stmt;
}

void append_statement(Stmt **list, Stmt *statement) {
    if (*list == NULL) {
        *list = statement;
        return;
    }

    Stmt *current = *list;

    while (current->next != NULL) {
        current = current->next;
    }

    current->next = statement;
}
