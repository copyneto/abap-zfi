*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
    CONSTANTS: BEGIN OF gc_value,
                 memory        TYPE char5    VALUE 'ZMASS',
                 zfi_contab_fp TYPE symsgid  VALUE 'ZFI_CONTAB_FP',
                 number        TYPE symsgno  VALUE '002',
                 type          TYPE char1    VALUE 'I',
               END OF gc_value,

               BEGIN OF gc_filtros,
                 Id             TYPE char50 VALUE 'Id',
                 Identificacao  TYPE char50 VALUE 'Identificacao' ##NO_TEXT,
                 StatusCode     TYPE char50 VALUE 'StatusCode',
                 Empresa        TYPE char50 VALUE 'Empresa' ##NO_TEXT,
                 DataDocumento  TYPE char50 VALUE 'DataDocumento',
                 DataLancamento TYPE char50 VALUE 'DataLancamento',
                 TipoDocumento  TYPE char50 VALUE 'TipoDocumento',
                 Referencia     TYPE char50 VALUE 'Referencia' ##NO_TEXT,
                 TextCab        TYPE char50 VALUE 'TextCab',
                 TextStatus     TYPE char50 VALUE 'TextStatus',
               END OF gc_filtros.
