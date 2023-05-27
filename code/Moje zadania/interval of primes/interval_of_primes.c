#include <stdio.h>

int is_prime(int n){
    if (n<2){
        return 0;
    }
    for (int i = 2; i<n; i++){
        if (n%i==0){
            return 0;
        }
    }
    return 1;
}

void interval(int end){
    for (int i = 0; i<=end; i++){
        if (is_prime(i)==1){
            printf("%-d ", i);
        }
    }
}
int main() {
    int end=0;
    printf("%-s", "Podaj koniec przedzialu: ");
    scanf("%d", &end);
    interval(end);
    return 0;
}


