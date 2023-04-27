FUNCTION zfmfi_contabilizacao.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_DOCUMENTHEADER) TYPE  BAPIACHE09
*"     VALUE(IT_ACCOUNTGL) TYPE  BAPIACGL09_TAB OPTIONAL
*"     VALUE(IT_CURRENCYAMOUNT) TYPE  BAPIACCR09_TAB OPTIONAL
*"     VALUE(IT_ACCOUNTRECEIVABLE) TYPE  BAPIACAR09_TAB OPTIONAL
*"     VALUE(IT_EXTENSION2) TYPE  T_BAPIPAREX OPTIONAL
*"  TABLES
*"      T_MENSAGENS TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  DATA ls_return TYPE bapiret2.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader    = is_documentheader
    TABLES
      accountgl         = it_accountgl
      currencyamount    = it_currencyamount
      accountreceivable = it_accountreceivable
      extension2        = it_extension2
      return            = t_mensagens.

  IF NOT line_exists( t_mensagens[ type = 'E' ] ).       "#EC CI_STDSEQ

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      exporting
       WAIT = abap_true
      IMPORTING
        return = ls_return.

    IF ls_return-type = 'E'.
      APPEND ls_return TO t_mensagens.
    ENDIF.
  ENDIF.

ENDFUNCTION.
