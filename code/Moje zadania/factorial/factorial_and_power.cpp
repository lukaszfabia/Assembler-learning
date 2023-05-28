#include <iostream>


using namespace std;
int factorial(int x){
    int sum=1;
    for (int i=1; i<=x; i++){
        sum*=i;
    }
    return sum;
}
int power(int x, int n){
    int sum=1;
    for (int i=1; i<=n; i++){
        sum*=x;
    }
    return sum;
}

int main() {
    bool contiune_loop=false;
    int which, x, n;
    while (!contiune_loop){
        cout<<"Co chcesz policzyc silnia(0), potega(1): ";
        cin>>which;
        if (which==0){
            cout<<"Podaj liczbe z ktorej chcesz policzyc silnie: ";
            cin>>x;

            cout<<"Wynik: "<<factorial(x)<<endl;
        }else if (which==1){
            cout<<"Podaj podstawe i wykladnik: ";
            cin>>x>>n;
            cout<<"Wynik: "<<power(x, n)<<endl;
        }else{
            cout<<"nie poprawna komenda"<<endl;
        }

        cout<<"Kontynuowac nie(0), tak(1): ";
        cin>>which;
        if (which==0){
            contiune_loop=true;
        }

    }
    return 0;
}
