#include <iostream>

using namespace std;
char choiced;
int amount_rounds;
int results_for_computer;
int result_for_human;
char gird [9] = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
void give_rounds(){
    while (amount_rounds<1 || amount_rounds>5){
        cout<<"Podaj liczbe rund: ";
        cin>>amount_rounds;
    }
}

void choose_char(){
    while (choiced!='x' || choiced!='o'){
        cout<<"Wybierz swoj znak 'x', 'o' : ";
        cin>>choiced;
    }
}

void human_move(){

}

void computer_move(){

}

void display_grid();

void game();

void run();

int main(){
    display_grid();

    return 0;
}

void run(){
    for (int i=0; i<amount_rounds; i++){
        game();
    }
}

void game(){
    choose_char();

}

void display_grid(){
    for (int i=0; i<9; i++){
        if (i!=0 && i%3==0){
            cout<<"\n";
        }
        cout<<gird[i]<<" ";
    }
}