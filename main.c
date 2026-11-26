
#include <stdio.h>
#include "symbol_table.h"
#include "ast.h"

int yyparse(void);

extern Stmt *syntax_tree;

int main(void) {
    init_symbol_table();

    printf("================================\n");
    printf("       SYNTRIX COMPILER\n");
    printf("================================\n");

    printf("Enter your Syntrix code:\n\n");

    int result = yyparse();

    if (result == 0) {
        execute_program(syntax_tree);
    }

    if (result == 0 && semantic_error == 0) {
        printf("\nSyntax and semantic analysis successful!\n");
    } else {
        printf("\nCompilation failed!\n");
    }

    print_symbol_table();

    return 0;
}
