#include <iostream>

double calculate_pi_recursive(int limit, double curr = 1.0, double sign = 1.0) {
    return (curr > limit) ? 0.0 : sign / (2 * curr - 1) + calculate_pi_recursive(limit, curr + 1.0, -sign);
}

int main() {
    
    std::cout <<4*calculate_pi_recursive(12413) << std::endl;
    
    return 0;
}
