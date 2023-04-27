FUNCTION zfmfi_contab_crescimento.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_KEY) TYPE  ZSFI_CONTAB_KEY OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------

*  DATA(lo_contab) = NEW zclfi_contrato_contabilizar( ).
*
*  lo_contab->execute( EXPORTING is_key    = is_key
*                      IMPORTING et_return = et_return ).

  DATA(lo_contab) = NEW zclfi_cresci_contabiliza( ).

  lo_contab->process_contab(
    EXPORTING
      is_contrato    = is_key
    IMPORTING
      ex_msg         = et_return
    EXCEPTIONS
      not_found_log  = 1
      not_found_item = 2
      OTHERS         = 3
  ).
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFUNCTION.
