*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CONSTANTS: gc_delete          TYPE ze_log_status_contb VALUE 'D',
           gc_contab          TYPE ze_log_status_contb VALUE 'C',
           gc_erro            TYPE ze_log_status_contb VALUE 'E',
           gc_simular_process TYPE ze_log_status_contb VALUE 'X',
           gc_contab_process  TYPE ze_log_status_contb VALUE 'Z',
           gc_type_w          TYPE bapi_mtype          VALUE 'W',
           gc_type_s          TYPE bapi_mtype          VALUE 'S',
           gc_contab_fp       TYPE symsgid             VALUE 'ZFI_CONTAB_FP',
           gc_type_i          TYPE bapi_mtype          VALUE 'I',
           gc_bupla           TYPE te_struc            VALUE 'BUPLA',
           gc_number_01       TYPE symsgno             VALUE '001',
           gc_number          TYPE string              VALUE '0123456789'.
