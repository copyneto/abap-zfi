*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section
    CONSTANTS: BEGIN OF gc_value,
                 memory        TYPE char5    VALUE 'ZMASS',
                 zfi_contab_fp TYPE symsgid  VALUE 'ZFI_CONTAB_FP',
                 number        TYPE symsgno  VALUE '002',
                 type          TYPE char1 VALUE 'I',
               END OF gc_value.
