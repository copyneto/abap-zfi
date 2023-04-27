FUNCTION zfmfi_dda_reprocessa.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IT_PROCESS) TYPE  ZTT_J1B_ERROR_DDA OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  NEW zclfi_dda_xblnr( )->reprocess_dda_ff5(
    EXPORTING
      it_cds_rep = it_process
    IMPORTING
      et_return  = et_return
  ).

**
**  DATA: lv_documento TYPE xblnr1,
**        lv_msg       TYPE string.
**  DATA: lr_xblnr TYPE RANGE OF bkpf-xblnr.
**
**  CONSTANTS: BEGIN OF lc_fieldname,
**               barcode TYPE fieldname VALUE 'GLO_REF1',
**               e       TYPE status2_br  VALUE 'E',
**               b       TYPE err_br VALUE 'B',
**               v       TYPE err_br VALUE 'V',
**               a       TYPE dzlspr VALUE 'A',
**               k       TYPE koart  VALUE 'K',
**               zlsch_b TYPE fieldname VALUE 'ZLSCH',
**               zuonr   TYPE fieldname VALUE 'ZUONR',
**               dda     TYPE char4 VALUE 'DDA_',
**               message TYPE char255 VALUE 'Divergence in reference',
**               msgid   TYPE bapiret2-id VALUE 'ZFI_SOLUCAO_DDA',
**             END OF lc_fieldname.
**
**
**  LOOP AT it_process ASSIGNING FIELD-SYMBOL(<fs_process>).
**
**    CLEAR: lv_documento, lr_xblnr.
**
**    lv_documento = <fs_process>-reference_no.
**    IF lv_documento CO '0123456789'.
**    ELSE.
**      REPLACE '/' IN lv_documento WITH '-'.
**    ENDIF.
**
**    APPEND VALUE #( sign = 'I'
**                    option = 'EQ'
**                    low = lv_documento ) TO lr_xblnr.
**
**    APPEND VALUE #( sign = 'I'
**                    option = 'CP'
**                    low = '*' && lv_documento ) TO lr_xblnr.
**
**    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**      EXPORTING
**        input  = lv_documento
**      IMPORTING
**        output = lv_documento.
**
**    APPEND VALUE #( sign = 'I'
**                    option = 'EQ'
**                    low = lv_documento ) TO lr_xblnr.
**
**
**    SELECT SINGLE lifnr, bukrs, belnr, gjahr
**      FROM bsik_view
**      WHERE bukrs = @<fs_process>-bukrs
**         AND gjahr = @<fs_process>-gjahr
**         AND xblnr IN @lr_xblnr
**      INTO @DATA(ls_documentp).
**
**    "encontrou documento
**    IF sy-subrc = 0.
**
**      DATA(lv_data_resul) = lc_fieldname-dda && <fs_process>-issue_date+6(2) &&
**                                             '.' && <fs_process>-issue_date+4(2) &&
**                                             '.' && <fs_process>-issue_date(4).
**
**      DATA(lt_accchg) = VALUE fdm_t_accchg(
**                ( fdname = lc_fieldname-zlsch_b
**                  newval = lc_fieldname-b )
**                ( fdname = 'ZFBDT'
**                  newval = <fs_process>-due_date )
**                ( fdname = lc_fieldname-zuonr
**                  newval = lv_data_resul  )
**                ( fdname = 'ZBD1T'
**                  newval = 0 ) ).
**
**      IF lt_accchg IS NOT INITIAL.
**
**        CALL FUNCTION 'FI_DOCUMENT_CHANGE'
**          EXPORTING
**            i_lifnr              = ls_documentp-lifnr
**            i_bukrs              = ls_documentp-bukrs
**            i_belnr              = ls_documentp-belnr
**            i_gjahr              = ls_documentp-gjahr
**          TABLES
**            t_accchg             = lt_accchg
**          EXCEPTIONS
**            no_reference         = 1
**            no_document          = 2
**            many_documents       = 3
**            wrong_input          = 4
**            overwrite_creditcard = 5
**            OTHERS               = 6.
**
**        IF sy-subrc EQ 0.
**
**          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
**            EXPORTING
**              wait = abap_true.
**
**          "Documento &1 processado com sucesso.
**          MESSAGE s010(zfi_solucao_dda) INTO lv_msg.
**          APPEND VALUE #( id         = lc_fieldname-msgid
**                          type       = 'S'
**                          number     = '009'
**                          message_v1 = lv_documento ) TO et_return .
**
**
**        ENDIF.
**
**
**      ELSE.
**        "Erro documento nao encontrado
**
**      ENDIF."encontrou documento
**
**    ENDIF.
**
**
**  ENDLOOP.


ENDFUNCTION.
