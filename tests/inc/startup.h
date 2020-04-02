#define DEFAULT __attribute__((weak, alias("Default_Handler")))

typedef void (*element_t)(void);

typedef union {
    element_t isr;
    void *stack_top;
} vector_table_t;

void DefaultHander(void);
void ResetHandler(void);

extern int _stack_ptr;
extern int _etext;
extern int _data;
extern int _edata;
extern int _bss;
extern int _ebss;

extern int main(void);
