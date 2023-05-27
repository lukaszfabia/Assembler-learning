#include <iostream>


using namespace std;
bool is_prime(int n){
    if (n<2){
        return false;
    }
    for (int i = 2; i<n; i++){
        if (n%i==0){
            return false;
        }
    }
    return true;
}

int main() {
    int n;

    cin>>n; // wczytanie liczby
    if (is_prime(n)){
        cout<<"TAK\n";
    }else{
        cout<<"NIE\n";
    }
    return 0;
}