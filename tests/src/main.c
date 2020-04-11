#include "hw_macros.h"

#define LIMIT 20
//#define LIMIT 11

//unsigned int __mulsi3 (unsigned int a, unsigned int b) {
//        unsigned int r = 0;
//
//        while (a) {
//        if (a & 1)
//                r += b;
//                a >>= 1;
//                b <<= 1;
//        }
//        return r;
//}

int main() {
        int i,j;

        int primes[LIMIT+1];

        //populating array with naturals LIMITs
        for(i = 2; i<=LIMIT; i++)
                primes[i] = i;

        i = 2;
        while ((i*i) <= LIMIT) {
                if (primes[i] != 0) {
                        for(j=2; j<LIMIT; j++) {
                                if (primes[i]*j > LIMIT)
                                        break;
                                else
                                primes[primes[i]*j]=0;
                        }
                }
                i++;
        }

        int count = 0;
        for(i = 2; i <= LIMIT; i++) {
                if (primes[i]!=0) {
                        //MEM(0x450 + (count * 4)) = primes[i];
                        MEM(0x450) = primes[i];
                        for (j = 0; j < 100000; j++){asm("");}
                        //for (j = 0; j < 120; j++){asm("");}
                        count++;
                
                }
        }

    return 0;
}

