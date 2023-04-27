FUNCTION zfmfi_document_change.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_BUZEI) TYPE  BUZEI
*"     VALUE(IV_BUKRS) TYPE  BUKRS
*"     VALUE(IV_BELNR) TYPE  BELNR_D
*"     VALUE(IV_GJAHR) TYPE  GJAHR
*"     VALUE(IS_ACCHG) TYPE  ACCCHG
*"  TABLES
*"      ET_RET TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  CONSTANTS:   lc_gname TYPE eqegraname VALUE 'BKPF'.

  DATA: lt_acchg TYPE TABLE OF accchg,
        lt_enq   TYPE STANDARD TABLE OF seqg3,
        lt_ret   TYPE STANDARD TABLE OF bapiret2_tab,
        lv_garg  TYPE eqegraarg.


  APPEND is_acchg TO lt_acchg.

*     Check if there is lock on document before proceeding
  CALL FUNCTION 'ENQUEUE_READ'
    EXPORTING
      gclient               = sy-mandt
      gname                 = lc_gname             " BKPF
      garg                  = lv_garg
    TABLES
      enq                   = lt_enq
    EXCEPTIONS
      communication_failure = 1
      system_failure        = 2
      OTHERS                = 3.

  IF sy-subrc EQ 0 AND lt_enq IS INITIAL.

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_buzei              = iv_buzei
*       x_lock               = abap_true
        i_bukrs              = iv_bukrs
        i_belnr              = iv_belnr
        i_gjahr              = iv_gjahr
*       i_upd_fqm            = abap_true
      TABLES
        t_accchg             = lt_acchg
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.

    IF sy-subrc NE 0.

      APPEND VALUE #(
   type       = sy-msgty
   id         = sy-msgid
   number     = sy-msgno
   message_v1 = sy-msgv1
   message_v2 = sy-msgv2
   message_v3 = sy-msgv3
   message_v4 = sy-msgv4 ) TO et_ret.

    ELSE.

      APPEND VALUE #(
             type       = 'S'
             id         = 'ZFI_BOLETO'
             number     = '016'
             message_v1 = iv_belnr
             message_v2 = iv_bukrs
             message_v3 = iv_gjahr ) TO et_ret.


      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.


    ENDIF.

  ENDIF.


ENDFUNCTION.
