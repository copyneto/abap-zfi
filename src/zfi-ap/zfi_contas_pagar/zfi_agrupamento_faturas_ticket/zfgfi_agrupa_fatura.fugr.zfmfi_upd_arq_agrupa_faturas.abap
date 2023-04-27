FUNCTION zfmfi_upd_arq_agrupa_faturas.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IT_AGRUPA_FATURA) TYPE  ZCTGFI_AGRUPA_FATURAS
*"     VALUE(IT_AGRUPA_LINHAS) TYPE  ZCTGFI_AGRUPA_LINHAS
*"  TABLES
*"      ET_MENSAGENS TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  CONSTANTS:
    gc_msgid TYPE sy-msgid VALUE 'ZFI_AGRUPA_FATURAS'.

  IF it_agrupa_fatura IS NOT INITIAL.

    MODIFY ztfi_agrupfatura FROM TABLE it_agrupa_fatura.

  ENDIF.

  IF it_agrupa_linhas IS NOT INITIAL.

    MODIFY ztfi_agruplinhas FROM TABLE it_agrupa_linhas.

  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

  et_mensagens = VALUE #(
                  id = gc_msgid
                  type = if_xo_const_message=>success
                  number = 003 ).



ENDFUNCTION.
