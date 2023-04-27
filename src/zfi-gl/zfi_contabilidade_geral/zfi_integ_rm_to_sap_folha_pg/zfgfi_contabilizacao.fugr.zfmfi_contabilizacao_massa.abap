FUNCTION zfmfi_contabilizacao_massa.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_SIMULAR) TYPE  CHAR1 OPTIONAL
*"----------------------------------------------------------------------
  CONSTANTS: gc_memory TYPE char5 VALUE 'ZMASS'.

  DATA: lt_header_aux TYPE TABLE OF zi_fi_contab_cab  WITH DEFAULT KEY,
        lt_item_aux   TYPE TABLE OF zi_fi_contab_item WITH DEFAULT KEY.

  COMMIT WORK.

  IMPORT lt_header_aux TO lt_header_aux
         lt_item_aux   TO lt_item_aux FROM DATABASE indx(zw) ID gc_memory.

  DELETE FROM DATABASE indx(zw) ID gc_memory.

  IF lt_header_aux IS NOT INITIAL.

    DATA(lo_contab) = NEW zclfi_exec_contabilizacao( it_header = lt_header_aux
                                                     it_item   = lt_item_aux  ).

    lo_contab->execute_bapi( iv_simular ).

  ENDIF.

ENDFUNCTION.
