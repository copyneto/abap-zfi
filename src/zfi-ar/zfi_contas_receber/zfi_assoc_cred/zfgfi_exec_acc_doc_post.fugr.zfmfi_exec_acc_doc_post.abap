FUNCTION zfmfi_exec_acc_doc_post.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_DOCHEADER) TYPE  BAPIACHE09
*"     VALUE(IT_ACCOUNTGL) TYPE  BAPIACGL09_TAB OPTIONAL
*"     VALUE(IT_ACCOUNTRECEIVABLE) TYPE  BAPIACAR09_TAB OPTIONAL
*"     VALUE(IT_ACCOUNTPAYABLE) TYPE  BAPIACAP09_TAB OPTIONAL
*"     VALUE(IT_CURRENCYAMOUNT) TYPE  BAPIACCR09_TAB OPTIONAL
*"     VALUE(IT_EXTENSION2) TYPE  BAPIAPOPAREX_TAB OPTIONAL
*"  EXPORTING
*"     VALUE(EV_TYPE) TYPE  BAPIACHE09-OBJ_TYPE
*"     VALUE(EV_KEY) TYPE  BAPIACHE09-OBJ_KEY
*"     VALUE(EV_SYS) TYPE  BAPIACHE09-OBJ_SYS
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

    DATA(lt_accountgl)          = it_accountgl[].
    DATA(lt_accountreceivable)  = it_accountreceivable[].
    DATA(lt_accountpayable)     = it_accountpayable[].
    DATA(lt_currencyamount)     = it_currencyamount[].
    DATA(lt_extension2)         = it_extension2[].

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader    = is_docheader
      IMPORTING
        obj_type          = ev_type
        obj_key           = ev_key
        obj_sys           = ev_sys
      TABLES
        accountgl         = lt_accountgl
        accountreceivable = lt_accountreceivable
        accountpayable    = lt_accountpayable
        currencyamount    = lt_currencyamount
        extension2        = lt_extension2
        return            = et_return.

      IF NOT line_exists( et_return[ type = 'E ' ] )."#EC CI_STDSEQ
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      ENDIF.


ENDFUNCTION.
