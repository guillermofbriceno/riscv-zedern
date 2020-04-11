OUTPUT_ARCH("riscv")

MEMORY {
    /*
     * FLASH (rx) : ORIGIN = 0x1fc, LENGTH = 0x4000
     * RAM (rwx) : ORIGIN = 0x2000000, LENGTH = 0x1000
    */

     FLASH (rx) : ORIGIN = 0x000, LENGTH = 0x400
     RAM (rwx) : ORIGIN = 0x404, LENGTH = 0x400

}

SECTIONS {
        PROVIDE( _stack_ptr = ORIGIN(RAM) + LENGTH(RAM) );

        .text : {
                _text = .;
                KEEP(*(.vector_table))
                /**(.text.ResetHandler)*/
                *(.text*)
                *(.rodata*)
                _etext = .;
        } > FLASH

        .data : ALIGN(4) {
                _data = .;
                *(.data*)
                _edata = .;
        } > RAM AT > FLASH

        .bss : {
                _bss = .;
                *(.bss*)
                *(COMMON)
                _ebss = .;
        } > RAM
}
