FUNCTION-POOL zfgfi_sol_correcao.           "MESSAGE-ID ..

* INCLUDE LZFGFI_SOL_CORRECAOD...            " Local class definition

TYPES: BEGIN OF ty_item,
         mark    TYPE s_mark,
         include TYPE zsfi_itens_correcao,
       END OF ty_item.


DATA: gt_itens TYPE STANDARD TABLE OF ty_item.
DATA: gs_item TYPE ty_item.

DATA: go_process TYPE REF TO zclfi_process_fbl5h.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TBC_SOL_CORREC' ITSELF
CONTROLS: tbc_sol_correc TYPE TABLEVIEW USING SCREEN 9001.
