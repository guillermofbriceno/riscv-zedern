#include "hw_macros.h"

const char x[] = {"Hello World!"};
//volatile unsigned int test = 8;
//volatile unsigned int test2 = 87;

int main() {
        //test = test + 1;
        for (int i = 0; i < 12; i++) {
                MEM(0x450 + i) = x[i] + 1;
        }
        //MEM(0xf3) = x[3];
        
        return 0;
}
