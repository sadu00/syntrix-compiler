
#include <stdio.h>
#include "symbol_table.h"

int yyparse(void);

int main() {
    init_symbol_table();

    printf("================================\n");
    printf("       SYNTRIX COMPILER\n");
    printf("================================\n");

    printf("Enter your Syntrix code:\n\n");

    int result = yyparse();

    if (result == 0 && semantic_error == 0) {
        printf("\nSyntax and semantic analysis successful!\n");
    } else {
        printf("\nCompilation failed!\n");
    }

    print_symbol_table();

    return 0;
}
