FUNCTION zfmfi_exec_compensa_upd_doc.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_COMPENSA_UPD_DOC) TYPE  ZSFI_COMPENSA_UPD_DOC
*"  EXPORTING
*"     VALUE(ES_COMPENSA_UPD_DOC) TYPE  ZSFI_COMPENSA_UPD_DOC
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  DATA lt_change TYPE fdm_t_accchg.

  DATA: lv_newdata TYPE newdata.

  CLEAR: lt_change[].

  IF is_compensa_upd_doc-tipo = 'A'.

    lv_newdata = 'ASSOCIADO-APP143'.

    SELECT SINGLE
      anfbn
      FROM bseg
      INTO @DATA(lv_anfbn)
      WHERE bukrs = @is_compensa_upd_doc-bukrs
        AND belnr = @is_compensa_upd_doc-belnr
        AND gjahr = @is_compensa_upd_doc-gjahr
        AND buzei = @is_compensa_upd_doc-buzei.

    IF lv_anfbn IS NOT INITIAL.

      APPEND INITIAL LINE TO lt_change ASSIGNING FIELD-SYMBOL(<fs_chg>).
      <fs_chg>-fdname = 'DTWS1'.
      <fs_chg>-newval = '04'.

    ENDIF.

    es_compensa_upd_doc = is_compensa_upd_doc.

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_buzei              = es_compensa_upd_doc-buzei
        i_bukrs              = es_compensa_upd_doc-bukrs
        i_belnr              = es_compensa_upd_doc-belnr
        i_gjahr              = es_compensa_upd_doc-gjahr
      TABLES
        t_accchg             = lt_change
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.

    IF sy-subrc <> 0.
      es_compensa_upd_doc-subrc = sy-subrc.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

      IF es_compensa_upd_doc-anfbn IS NOT INITIAL.

        CALL FUNCTION 'ZFMFI_BATCH_COMPENSAR'
          EXPORTING
            iv_kunnr    = es_compensa_upd_doc-kunnr
            iv_waers    = 'BRL'
            iv_budat    = sy-datum
            iv_bukrs    = es_compensa_upd_doc-bukrs
            iv_anfbn    = es_compensa_upd_doc-anfbn
          IMPORTING
            ev_erro     = es_compensa_upd_doc-error
            ev_doc_est  = es_compensa_upd_doc-doc_est
            ev_item_est = es_compensa_upd_doc-item_est
            ev_ano_est  = es_compensa_upd_doc-ano_est
          CHANGING
            ct_msg      = et_return.
      ENDIF.
    ENDIF.
  ELSE.
    lv_newdata = 'APP143-PGFORN'.
  ENDIF.

  CLEAR: lt_change[].

  APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
  <fs_chg>-fdname = 'XREF1_HD'.
  <fs_chg>-newval = lv_newdata.

  CALL FUNCTION 'FI_DOCUMENT_CHANGE'
    EXPORTING
      i_buzei              = es_compensa_upd_doc-buzei_cre
      i_bukrs              = es_compensa_upd_doc-bukrs_cre
      i_belnr              = es_compensa_upd_doc-belnr_cre
      i_gjahr              = es_compensa_upd_doc-gjahr_cre
    TABLES
      t_accchg             = lt_change
    EXCEPTIONS
      no_reference         = 1
      no_document          = 2
      many_documents       = 3
      wrong_input          = 4
      overwrite_creditcard = 5
      OTHERS               = 6.

  IF sy-subrc <> 0.
    es_compensa_upd_doc-subrc = sy-subrc.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  ENDIF.

ENDFUNCTION.
