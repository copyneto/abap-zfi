FUNCTION zfmfi_liquidacao.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_APP) TYPE  ZI_FI_PROVISAO_CLI OPTIONAL
*"  CHANGING
*"     VALUE(CT_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  TYPES:
    BEGIN OF ty_bseg,
      gsber   TYPE bseg-gsber,
      sgtxt   TYPE bseg-sgtxt,
      kostl   TYPE bseg-kostl,
      segment TYPE bseg-segment,
      prctr   TYPE bseg-prctr,
    END OF ty_bseg.

  CONSTANTS: lc_moeda    TYPE waers VALUE 'BRL',
             lc_fi       TYPE ztca_param_par-modulo VALUE 'FI-AR',
             lc_chave1   TYPE ztca_param_par-chave1 VALUE 'BOTAOLIQUIDACAO',
             lc_tpdoc    TYPE ztca_param_par-chave2 VALUE 'TIPODOC',
             lc_chave2   TYPE ztca_param_par-chave2 VALUE 'CONTARAZAO',
             lc_conta40  TYPE ztca_param_par-chave3 VALUE 'CHAVE40',
             lc_conta50  TYPE ztca_param_par-chave3 VALUE 'CHAVE50',
             lc_chave1_2 TYPE ztca_param_par-chave1 VALUE 'BOTAOLIQUIDACAO2',
             lc_tpdoc_2  TYPE ztca_param_par-chave2 VALUE 'TIPODOC2',
             lc_chave2_2 TYPE ztca_param_par-chave2 VALUE 'CONTARAZAO2'.

  DATA: lt_currency TYPE TABLE OF bapiaccr09,
        lt_return   TYPE TABLE OF bapiret2,
        lt_gl       TYPE TABLE OF bapiacgl09,
        lt_ext2     TYPE          tt_bapiparex.

  DATA: ls_header TYPE bapiache09,
        ls_bseg   TYPE ty_bseg.

  DATA: lv_tpdoc     TYPE blart,
        lv_conta40   TYPE hkont,
        lv_conta50   TYPE hkont,
        lv_conta40_2 TYPE hkont,
        lv_conta50_2 TYPE hkont,
        lv_item      TYPE posnr_acc,
        lv_key       TYPE bapiache09-obj_key.

  FIELD-SYMBOLS: <fs_ret> LIKE LINE OF ct_return,
                 <fs_ext> LIKE LINE OF lt_ext2.

  DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 24.07.2023

  TRY.
      CALL METHOD lo_param->m_get_single
        EXPORTING
          iv_modulo = lc_fi
          iv_chave1 = lc_chave1
          iv_chave2 = lc_tpdoc
        IMPORTING
          ev_param  = lv_tpdoc.

      CALL METHOD lo_param->m_get_single
        EXPORTING
          iv_modulo = lc_fi
          iv_chave1 = lc_chave1
          iv_chave2 = lc_chave2
          iv_chave3 = lc_conta40
        IMPORTING
          ev_param  = lv_conta40.

      CALL METHOD lo_param->m_get_single
        EXPORTING
          iv_modulo = lc_fi
          iv_chave1 = lc_chave1
          iv_chave2 = lc_chave2
          iv_chave3 = lc_conta50
        IMPORTING
          ev_param  = lv_conta50.

    CATCH zcxca_tabela_parametros.

      RETURN.

  ENDTRY.

  SELECT SINGLE
    gsber, sgtxt, kostl, segment
    FROM bseg
    INTO @ls_bseg
    WHERE belnr = @is_app-numdoc
      AND bukrs = @is_app-empresa
      AND gjahr = @is_app-exercprov
      AND kostl NE @space.

  IF sy-subrc <> 0 .

    SELECT SINGLE
    region, kostl
    FROM ztfi_cad_cc
    INTO @DATA(ls_cad)
    WHERE region = @is_app-regvendas
      AND bukrs  = @is_app-empresa.

    SELECT SINGLE gsber, prctr
        FROM csks
        INTO @DATA(ls_csks)
      WHERE kokrs EQ 'AC3C'
        AND kostl EQ @ls_cad-kostl
        AND datbi GE @sy-datum.

    SELECT SINGLE segment FROM cepc
      INTO @DATA(lv_segment)
     WHERE prctr EQ @ls_csks-prctr
       AND datbi GE @sy-datum
       AND kokrs EQ 'AC3C'.

    ls_bseg-kostl   = ls_cad-kostl.
    ls_bseg-gsber   = ls_csks-gsber.
    ls_bseg-prctr   = ls_csks-prctr.
    ls_bseg-segment = lv_segment.

  ENDIF.

  SELECT SINGLE
    belnr, bktxt,
    xref1_hd, xref2_hd
    FROM bkpf
    INTO @DATA(ls_bkpf)
    WHERE bukrs = @is_app-empresa
      AND belnr = @is_app-numdoc
      AND gjahr = @is_app-exercicio.

  SELECT SINGLE
    belnr,
    zuonr,
    sgtxt
    FROM bseg
    INTO @DATA(ls_bseg_aux)
    WHERE bukrs = @is_app-empresa
      AND belnr = @is_app-numdoc
      AND gjahr = @is_app-exercicio
      AND buzei = @is_app-item.

  "Lancamento sem provisão
  IF is_app-montprov IS INITIAL.

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_ret>-type       = 'E'.
    <fs_ret>-number     = '043'.

    EXIT.

*    TRY.
*        CALL METHOD lo_param->m_get_single
*          EXPORTING
*            iv_modulo = lc_fi
*            iv_chave1 = lc_chave1_2
*            iv_chave2 = lc_tpdoc_2
*          IMPORTING
*            ev_param  = lv_tpdoc.
*
*        CALL METHOD lo_param->m_get_single
*          EXPORTING
*            iv_modulo = lc_fi
*            iv_chave1 = lc_chave1_2
*            iv_chave2 = lc_chave2_2
*            iv_chave3 = lc_conta40
*          IMPORTING
*            ev_param  = lv_conta40_2.
*
*        CALL METHOD lo_param->m_get_single
*          EXPORTING
*            iv_modulo = lc_fi
*            iv_chave1 = lc_chave1_2
*            iv_chave2 = lc_chave2_2
*            iv_chave3 = lc_conta50
*          IMPORTING
*            ev_param  = lv_conta50_2.
*
*      CATCH zcxca_tabela_parametros.
*
*        RETURN.
*
*    ENDTRY.
*
*    ls_header-doc_date    = sy-datum.
**    ls_header-pstng_date  = sy-datum.
*    ls_header-pstng_date  = is_app-venc_liqui.
*    ls_header-doc_type    = lv_tpdoc.
*    ls_header-comp_code   = is_app-empresa.
*    ls_header-fis_period  = sy-datum+4(2).
*    ls_header-username    = sy-uname.
*    ls_header-header_txt  = ls_bkpf-bktxt.
*    ls_header-ref_doc_no  = is_app-referencia.
*
***********************************************************************
** Item 1
***********************************************************************
*
*    ADD 1 TO lv_item.
*    APPEND INITIAL LINE TO lt_gl ASSIGNING FIELD-SYMBOL(<fs_gl2>).
*
*    <fs_gl2>-itemno_acc = lv_item.
*
*    <fs_gl2>-gl_account = lv_conta40_2.
*    <fs_gl2>-bus_area   = ls_bseg-gsber.
*    <fs_gl2>-item_text  = ls_bseg-sgtxt.
*
*    IF lv_conta40_2(1) = '1' OR lv_conta40_2(1) = '2'.
*      CLEAR:<fs_gl2>-costcenter.
*    ELSE.
*      <fs_gl2>-costcenter = ls_bseg-kostl.
*    ENDIF.
*
*    <fs_gl2>-segment    = ls_bseg-segment.
*    <fs_gl2>-alloc_nmbr = ls_bseg_aux-zuonr.
*    <fs_gl2>-item_text  = ls_bseg_aux-sgtxt.
*
*    APPEND INITIAL LINE TO lt_currency ASSIGNING FIELD-SYMBOL(<fs_curr2>).
*
*    <fs_curr2>-itemno_acc   = lv_item.
*    <fs_curr2>-currency_iso = lc_moeda.
*    <fs_curr2>-amt_doccur   = is_app-montprov.
*
*    APPEND INITIAL LINE TO lt_ext2 ASSIGNING <fs_ext>.
*    <fs_ext>-structure  = 'XREF1_HD'.
*    <fs_ext>-valuepart1 = lv_item.
*    <fs_ext>-valuepart2 = ls_bkpf-xref1_hd.
*
*    APPEND INITIAL LINE TO lt_ext2 ASSIGNING <fs_ext>.
*    <fs_ext>-structure  = 'XREF2_HD'.
*    <fs_ext>-valuepart1 = lv_item.
*    <fs_ext>-valuepart2 = ls_bkpf-xref2_hd.
*
***********************************************************************
** Item 2
***********************************************************************
*
*    ADD 1 TO lv_item.
*    APPEND INITIAL LINE TO lt_gl ASSIGNING <fs_gl2>.
*
*    <fs_gl2>-itemno_acc = lv_item.
*
*    <fs_gl2>-gl_account = lv_conta50_2.
*    <fs_gl2>-bus_area   = ls_bseg-gsber.
*    <fs_gl2>-item_text  = ls_bseg-sgtxt.
*
*    IF lv_conta50_2(1) = '1' OR lv_conta50_2(1) = '2'.
*      CLEAR:<fs_gl2>-costcenter.
*    ELSE.
*      <fs_gl2>-costcenter = ls_bseg-kostl.
*    ENDIF.
*
*    <fs_gl2>-segment    = ls_bseg-segment.
*    <fs_gl2>-alloc_nmbr = ls_bseg_aux-zuonr.
*    <fs_gl2>-item_text  = ls_bseg_aux-sgtxt.
*
*    APPEND INITIAL LINE TO lt_currency ASSIGNING <fs_curr2>.
*
*    <fs_curr2>-itemno_acc   = lv_item.
*    <fs_curr2>-currency_iso = lc_moeda.
*    <fs_curr2>-amt_doccur   = is_app-montprov * -1.

  ELSE.

    "Lancamento normal
    ls_header-doc_date    = sy-datum.
*    ls_header-pstng_date  = sy-datum.
    ls_header-pstng_date  = is_app-venc_liqui.
    ls_header-doc_type    = lv_tpdoc.
    ls_header-comp_code   = is_app-empresa.
    ls_header-fis_period  = sy-datum+4(2).
    ls_header-username    = sy-uname.
    ls_header-header_txt  = ls_bkpf-bktxt.
    ls_header-ref_doc_no  = is_app-referencia.

**********************************************************************
* Item 1
**********************************************************************

    ADD 1 TO lv_item.
    APPEND INITIAL LINE TO lt_gl ASSIGNING FIELD-SYMBOL(<fs_gl>).

    <fs_gl>-itemno_acc = lv_item.

    <fs_gl>-gl_account = lv_conta40.
    <fs_gl>-bus_area   = ls_bseg-gsber.
    <fs_gl>-item_text  = ls_bseg-sgtxt.

    IF lv_conta40(1) = '1' OR lv_conta40(1) = '2'.
      CLEAR:<fs_gl>-costcenter.
    ELSE.
      <fs_gl>-costcenter = ls_bseg-kostl.
    ENDIF.

    <fs_gl>-segment    = ls_bseg-segment.
    <fs_gl>-alloc_nmbr = ls_bseg_aux-zuonr.
    <fs_gl>-item_text  = ls_bseg_aux-sgtxt.

    APPEND INITIAL LINE TO lt_currency ASSIGNING FIELD-SYMBOL(<fs_curr>).

    <fs_curr>-itemno_acc   = lv_item.
    <fs_curr>-currency_iso = lc_moeda.
    <fs_curr>-amt_doccur   = is_app-montprov.

    APPEND INITIAL LINE TO lt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XREF1_HD'.
    <fs_ext>-valuepart1 = lv_item.
    <fs_ext>-valuepart2 = ls_bkpf-xref1_hd.

    APPEND INITIAL LINE TO lt_ext2 ASSIGNING <fs_ext>.
    <fs_ext>-structure  = 'XREF2_HD'.
    <fs_ext>-valuepart1 = lv_item.
    <fs_ext>-valuepart2 = ls_bkpf-xref2_hd.


**********************************************************************
* Item 2
**********************************************************************

    ADD 1 TO lv_item.
    APPEND INITIAL LINE TO lt_gl ASSIGNING <fs_gl>.

    <fs_gl>-itemno_acc = lv_item.

    <fs_gl>-gl_account = lv_conta50.
    <fs_gl>-bus_area   = ls_bseg-gsber.
    <fs_gl>-item_text  = ls_bseg-sgtxt.

    IF lv_conta50(1) = '1' OR lv_conta50(1) = '2'.
      CLEAR:<fs_gl>-costcenter.
    ELSE.
      <fs_gl>-costcenter = ls_bseg-kostl.
    ENDIF.

    <fs_gl>-segment    = ls_bseg-segment.
    <fs_gl>-alloc_nmbr = ls_bseg_aux-zuonr.
    <fs_gl>-item_text  = ls_bseg_aux-sgtxt.

    APPEND INITIAL LINE TO lt_currency ASSIGNING <fs_curr>.

    <fs_curr>-itemno_acc   = lv_item.
    <fs_curr>-currency_iso = lc_moeda.
    <fs_curr>-amt_doccur   = is_app-montprov * -1.

  ENDIF.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = ls_header
    IMPORTING
      obj_key        = lv_key
    TABLES
      accountgl      = lt_gl
      currencyamount = lt_currency
      extension2     = lt_ext2
      return         = lt_return.

  IF NOT line_exists( lt_return[ type = 'E' ] ).

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_ret>-type       = 'I'.
    <fs_ret>-number     = '013'.

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_ret>-type       = 'S'.
    <fs_ret>-number     = '015'.
    <fs_ret>-message_v1 = lv_key(10).
    <fs_ret>-message_v2 = lv_key+10(4).
    <fs_ret>-message_v3 = lv_key+14(4).

    UPDATE ztfi_cont_cont
     SET doc_liquidacao   = lv_key(10)
         exerc_liquidacao = lv_key+14(4)
         mont_liquidacao  = is_app-montprov
         status_provisao  = '3'
   WHERE contrato    = is_app-numcontrato
     AND aditivo     = is_app-numaditivo
     AND kunnr       = is_app-cliente
     AND bukrs       = is_app-empresa
     AND belnr       = is_app-numdoc
     AND gjahr       = is_app-exercicio
     AND numero_item = is_app-item   .

    COMMIT WORK AND WAIT.

  ELSE.

    APPEND LINES OF lt_return TO ct_return.

  ENDIF.

ENDFUNCTION.
