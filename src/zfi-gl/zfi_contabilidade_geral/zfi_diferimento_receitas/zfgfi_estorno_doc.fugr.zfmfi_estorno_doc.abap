FUNCTION zfmfi_estorno_doc.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_EMPRESA) TYPE  BUKRS
*"     VALUE(IV_DOC) TYPE  BELNR_D
*"     VALUE(IV_ANO) TYPE  GJAHR
*"     VALUE(IV_DTESTORNO) TYPE  DATUM
*"     VALUE(IV_PERIODO) TYPE  MONAT
*"     VALUE(IV_COD) TYPE  STGRD
*"  CHANGING
*"     VALUE(CV_DOC_REV) TYPE  BELNR_D
*"     VALUE(CV_ANO_REV) TYPE  GJAHR
*"     VALUE(CT_MENSAGENS) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  DATA ls_return TYPE bapiret2.

  CALL FUNCTION 'TR_SE_FI_DOCUMENT_REVERSAL'
    EXPORTING
      i_bukrs              = iv_empresa
      i_docnrfi            = iv_doc
      i_gjahr              = iv_ano
      i_budat              = iv_dtestorno
      i_period             = iv_periodo
      i_fi_reversal_reason = iv_cod
    IMPORTING
      e_reversal_docnrfi   = cv_doc_rev
      e_reversal_gjahr     = cv_ano_rev
    EXCEPTIONS
      error_occured        = 1
      OTHERS               = 2.

  IF sy-subrc <> 0.
    ls_return-id = sy-msgid.
    ls_return-type = sy-msgty.
    ls_return-id = sy-msgid.
    ls_return-message_v1 = sy-msgv1.
    ls_return-message_v2 = sy-msgv2.
    ls_return-message_v3 = sy-msgv3.
    ls_return-message_v4 = sy-msgv4.

    APPEND ls_return TO ct_mensagens.
  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      IMPORTING
        return = ls_return.

    IF ls_return-type = 'E'.
*        RAISE EXCEPTION TYPE /iwbep/cx_mgw_tech_exception.
      APPEND ls_return TO ct_mensagens.
  ENDIF.
  ENDIF.

ENDFUNCTION.
