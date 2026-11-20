
#include <stdio.h>

int yyparse(void);

int main() {
    printf("================================\n");
    printf("       SYNTRIX COMPILER\n");
    printf("================================\n");

    printf("Enter your Syntrix code:\n\n");

    if (yyparse() == 0) {
        printf("\nSyntax analysis successful!\n");
    } else {
        printf("\nSyntax analysis failed!\n");
    }

    return 0;
}
