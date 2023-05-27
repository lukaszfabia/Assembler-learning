#include <iostream>


using namespace std;

int main() {
    int n, sum=1, i=1;

    cin>>n; // wczytanie liczby
    while (i<=n){
        sum=sum*i;
        i++;
    }
    cout<<sum<<endl;
    return 0;
}