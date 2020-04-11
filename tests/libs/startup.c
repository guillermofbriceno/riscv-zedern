#include "startup.h"

__attribute__((section(".vector_table"))) const vector_table_t vectors[] = {
        {.stack_top = &_stack_ptr},
        ResetHandler
};

void ResetHandler(void) {
        int *src, *dest;

        //src = (int*)((char*)&_etext + 1);
        src = &_etext;

        for (dest = &_data; dest < &_edata;) {
                *dest++ = *src++;
        }

        for (dest = &_bss; dest < &_ebss;) {
                *dest++ = 0;
        }

        main();
}

void DefaultHandler(void) {
        while (1) {}
}
