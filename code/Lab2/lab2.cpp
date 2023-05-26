#include <iostream>


using namespace std;

int main() {
    bool is_end = false;
    double a, b, c, d;
    int continuing, which;
    while (!is_end) {
        cout<<"Podaj liczby b,c,d: ";
        cin >> b >> c >> d; // wczytanie zmiennych
        cout<<"Z ktorego wyrazenia to policzyc: ";
        cin >> which; // ktore wyrazenie ma byc liczone
        if (which == 1) {
            a = (c - b) / d;
        } else if (which == 2) {
            a = (c - d) * b;
        } else if (which == 3) {
            a = b * c - 2 * d;
        }
        cout<<"Wartosc: "<<a<<endl; // wypisz wynik
        cout<<"Czy kontynuowac: ";
        cin >> continuing; // czy kontynuowac
        if (continuing==0) {
            is_end = true;
        } // 48 15 -7
    }
    return 0;
}
