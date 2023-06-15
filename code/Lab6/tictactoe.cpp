#include <iostream>

using namespace std;
char choiced;
string player_name;
int amount_rounds;
char grid [9] = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
int position;
// 0 jest dla czlowieka 1 dla komputera 
int results [2];

void show_stats();

void give_rounds();

void choose_char();

void human_move();

void computer_move();

void display_grid();

void game();

void run();

bool check_win();

bool is_proper(int position);

char who_won();

void clear_grid();

bool is_full();

int main(){
    run();

    return 0;
}

void run(){
    cout<<"Podaj swoj nick: ";
    cin>>player_name;
    cout<<"-----------------"<<endl;
    choose_char();
    give_rounds();
    for (int i=0; i<amount_rounds; i++){
        cout<<"Runda "<<i+1<<endl;
        clear_grid();
        game();
        show_stats();
    }
    cout<<"Koniec"<<endl;
    system("pause");
}

void display_grid(){
    cout<<endl;
    for (int i=0; i<9; i++){
        if (i!=0 && i%3==0){
            cout<<"\n";
        }
        cout<<grid[i]<<" ";
    }
    cout<<endl;
}

void choose_char(){
    while (choiced!='x' && choiced!='o'){
        cout<<"Wybierz swoj znak 'x', 'o' : ";
        cin>>choiced;
    }
    cout<<"-----------------"<<endl;
}

void human_move(){
    cout<<"\nPodaj pozycje na ktorej chcesz postawic: "<<choiced<<" :";
    cin>>position;
    while (!is_proper(position)){
        cout<<"Niepoprawna pozycja, podaj jeszcze raz: ";
        cin>>position;
    }
    
    grid[position-1]=choiced;
}

void computer_move() {
    // Sprawdź możliwość wygranej w następnym ruchu
    char computer_mark;
    if (choiced=='x'){
        computer_mark='o';
    }
    else {
        computer_mark='x';
    }

    // sprawdzenie czy mozna wygrrac 
    for (int i = 0; i < 9; i++) {
        if (grid[i] == '0' + i + 1) {
            grid[i] = computer_mark;
            if (check_win()) {
                return;
            }
            grid[i] = '0' + i + 1;
        }
    }
    
    //blokowanie gracza
    for (int i = 0; i < 9; i++) {
        if (grid[i] == '0' + i + 1) {
            grid[i] = choiced;
            if (check_win()) {
                grid[i] = computer_mark;
                return;
            }
            grid[i] = '0' + i + 1;
        }
    }

    // Spróbuj zająć środek planszy
    if (grid[4] == '5') {
        grid[4] = computer_mark;
        return;
    }

    // Spróbuj zająć jedno z rogów planszy
    for (int i : {0, 2, 6, 8}) {
        if (grid[i] == '0' + i + 1) {
            grid[i] = computer_mark;
            return;
        }
    }

    // Spróbuj zająć dowolne inne wolne pole
    for (int i = 0; i < 9; i++) {
        if (grid[i] == '0' + i + 1) {
            grid[i] = computer_mark;
            return;
        }
    }
}


void give_rounds(){
    while (amount_rounds<1 || amount_rounds>5){
        cout<<"Podaj liczbe rund: ";
        cin>>amount_rounds;
    }
}
bool check_win() {
    char xoro[2] = {'x', 'o'};
    char mark;
    for (int i = 0; i < 2; i++) {
        mark = xoro[i];

        // Sprawdź wszystkie możliwe kombinacje zwycięstwa
        if ((grid[0] == mark && grid[1] == mark && grid[2] == mark) ||
            (grid[3] == mark && grid[4] == mark && grid[5] == mark) ||
            (grid[6] == mark && grid[7] == mark && grid[8] == mark) ||
            (grid[0] == mark && grid[3] == mark && grid[6] == mark) ||
            (grid[1] == mark && grid[4] == mark && grid[7] == mark) ||
            (grid[2] == mark && grid[5] == mark && grid[8] == mark) ||
            (grid[0] == mark && grid[4] == mark && grid[8] == mark) ||
            (grid[2] == mark && grid[4] == mark && grid[6] == mark)) {
            return true; // Zwróć true, jeśli warunek jest spełniony
        }
    }

    return false; // Zwróć false, jeśli nie ma zwycięzcy
}

void game(){
    // dla remisu 19726
    display_grid();
    while (!check_win()){
        human_move();
        display_grid();

        if (is_full()) {
        cout << "Remis!" << endl;
        return;
    }

        cout<<"-----------------"<<endl;
        computer_move();
        cout<<"Komputer wykonal ruch"<<endl;
        display_grid();
    }
    cout<<"-----------------"<<endl;
    display_grid();
    if (choiced==who_won()){
        cout<<"Wyrgales"<<endl;
        results[0]++;
    }
    else{
        cout<<"Przegrales"<<endl;
        results[1]++;
    }
}

bool is_proper(int position){
    if (position>9 || position<1){
        return false;
    }

    for (int i=0; i<9; i++){
        if (grid[position-1]=='x' || grid[position-1]=='o'){
            return false;
        }
    }
    return true;
}

char who_won() {
    char xoro[2] = {'x', 'o'};
    char mark;
    for (int i = 0; i < 2; i++) {
        mark = xoro[i];

        // Sprawdź wszystkie możliwe kombinacje zwycięstwa
        if ((grid[0] == mark && grid[1] == mark && grid[2] == mark) ||
            (grid[3] == mark && grid[4] == mark && grid[5] == mark) ||
            (grid[6] == mark && grid[7] == mark && grid[8] == mark) ||
            (grid[0] == mark && grid[3] == mark && grid[6] == mark) ||
            (grid[1] == mark && grid[4] == mark && grid[7] == mark) ||
            (grid[2] == mark && grid[5] == mark && grid[8] == mark) ||
            (grid[0] == mark && grid[4] == mark && grid[8] == mark) ||
            (grid[2] == mark && grid[4] == mark && grid[6] == mark)) {
            return mark; // Zwróć true, jeśli warunek jest spełniony
        }
    }
    return 'd';
}

void show_stats(){
    cout<<player_name<<" -> "<<results[0]<<" vs computer -> "<<results[1]<<endl<<endl;
}

void clear_grid(){
    for (int i=0; i<9; i++){
        grid[i]=(char)(i+1+'0');
    }
}

bool is_full(){
    for (int i=0; i<9; i++){
        if (grid[i] == '0' + i + 1) {
            return false; // Jeśli istnieje wolne pole, zwracamy false
        }
    }
    return true;
}
