#include <stdio.h>


int main() {
    int number;
    printf("%s", "Podaj liczbe: ");
    scanf("%d", &number);
    int i = 0;
    while (number != 0) {
        number = number / 10;
        printf("*");
        i++;
    }
    return 0;
}
