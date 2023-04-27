FUNCTION zfmfi_sol_correcao.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      IT_ITENS STRUCTURE  ZSFI_ITENS_CORRECAO
*"----------------------------------------------------------------------
  CLEAR gt_itens.

  LOOP AT it_itens ASSIGNING FIELD-SYMBOL(<fs_i_item>).
    APPEND INITIAL LINE TO gt_itens ASSIGNING FIELD-SYMBOL(<fs_item>).
    MOVE-CORRESPONDING <fs_i_item> TO <fs_item>-include.

  ENDLOOP.

  go_process = NEW zclfi_process_fbl5h(  ).

  CALL SCREEN 9001 STARTING AT 1 1
                     ENDING   AT 140 10.



ENDFUNCTION.
