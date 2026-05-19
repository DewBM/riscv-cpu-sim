ENTRY(_start)
PHDRS {
    all PT_LOAD FLAGS(7);  /* Read(4) | Write(2) | Execute(1) = 7 */
}
SECTIONS {
    . = 0x10000;
    .text : { *(.text) *(.text.*) } :all
}
