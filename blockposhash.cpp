/*
 *  Copyright (c) 2023 M4ximumpizza - All Rights Reserved.
 */

#include <iostream>
#include <string>
#include <sstream>

unsigned long hash(unsigned long a, unsigned long b) {
    a ^= b + (a << 6) + (a >> 2) + 0x9e3779b9;
    return a;
}

unsigned long hash_blockpos(int x, int y, int z) {
    unsigned long seed = hash(0, x);
    seed = hash(seed, y);
    seed = hash(seed, z);
    return seed;
}

int main(int argc, char* argv[]) {
    std::string line;
    while(std::getline(std::cin, line)) {
        std::stringstream str(line);
        int x,y,z;
        str >> x;
        str >> y;
        str >> z;
        printf("%d\t%d\t%d\t%lu\n",x,y,z,hash_blockpos(x,y,z));
    }
    return EXIT_SUCCESS;
}