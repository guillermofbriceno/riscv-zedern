#include "hw_macros.h"

#define LIMIT 100
//const char x[] = {"Hello World!"};

int main()
{
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
                        for (int j = 0; j < 5000; j++){asm("");}
                        count++;
                
                }
        }

    return 0;
}

