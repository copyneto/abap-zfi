FUNCTION zfmfi_provisao.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_APP) TYPE  ZI_FI_PROVISAO_CLI
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

  DATA: ls_header  TYPE bapiache09,
        ls_concern TYPE bapi0017-op_concern,
        ls_run     TYPE bapi0017-testrun,
        ls_bseg    TYPE ty_bseg,
        ls_doc     TYPE bseg_key.

  DATA: lt_currency TYPE TABLE OF bapiaccr09,
        lt_return   TYPE TABLE OF bapiret2,
        lt_gl       TYPE TABLE OF bapiacgl09,
        lt_data     TYPE TABLE OF bapi_copa_data,
        lt_list     TYPE TABLE OF bapi_copa_field.

  DATA lv_key       TYPE bapiache09-obj_key.
  DATA lv_item      TYPE posnr_acc.
  DATA lv_conta40   TYPE hkont.
  DATA lv_conta50   TYPE hkont.
  DATA lv_tpdoc     TYPE blart.

  DATA lt_change TYPE fdm_t_accchg.

  DATA: ls_provisao       TYPE zi_fi_reversao_provisao_pdc,
        ls_provisao_popup TYPE zi_fi_reversao_provisao_popup.

  FIELD-SYMBOLS: <fs_ret> LIKE LINE OF ct_return.

  CONSTANTS: lc_moeda   TYPE waers VALUE 'BRL',
             lc_fi      TYPE ztca_param_par-modulo VALUE 'FI-AR',
             lc_chave1  TYPE ztca_param_par-chave1 VALUE 'BOTAOPROVISAO',
             lc_tpdoc   TYPE ztca_param_par-chave2 VALUE 'TIPODOC',
             lc_chave2  TYPE ztca_param_par-chave2 VALUE 'CONTARAZAO',
             lc_conta40 TYPE ztca_param_par-chave3 VALUE 'CHAVE40',
             lc_conta50 TYPE ztca_param_par-chave3 VALUE 'CHAVE50'.

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
    gsber, sgtxt, kostl, segment, prctr
    FROM bseg
    INTO @ls_bseg
    WHERE belnr = @is_app-numdoc
      AND bukrs = @is_app-empresa
      AND gjahr = @is_app-exercicio
      AND kostl NE @space.

  IF ls_bseg-kostl IS INITIAL.

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
    sgtxt
    FROM bseg
    INTO @ls_bseg-sgtxt
    WHERE belnr = @is_app-numdoc
      AND bukrs = @is_app-empresa
      AND gjahr = @is_app-exercicio
      AND buzei = @is_app-item.

  SELECT SINGLE
    xblnr, bktxt, xref1_hd, xref2_hd
    FROM bkpf
    INTO @DATA(ls_bkpf)
    WHERE belnr = @is_app-numdoc
      AND bukrs = @is_app-empresa
      AND gjahr = @is_app-exercicio.

  ls_header-doc_date    = sy-datum.
*  ls_header-pstng_date  = sy-datum.
  ls_header-pstng_date  = is_app-venc_prov.
  ls_header-doc_type    = lv_tpdoc.
  ls_header-comp_code   = is_app-empresa.
  ls_header-fis_period  = sy-datum+4(2).
  ls_header-ref_doc_no  = ls_bkpf-xblnr.
  ls_header-header_txt  = ls_bkpf-bktxt.
  ls_header-username    = sy-uname.

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
  <fs_gl>-profit_ctr = ls_bseg-prctr.
  <fs_gl>-segment    = ls_bseg-segment.

  APPEND INITIAL LINE TO lt_currency ASSIGNING FIELD-SYMBOL(<fs_curr>).

  <fs_curr>-itemno_acc   = lv_item.
  <fs_curr>-amt_doccur   = is_app-montante.
  <fs_curr>-currency_iso = lc_moeda.

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
  <fs_gl>-profit_ctr = ls_bseg-prctr.
  <fs_gl>-segment    = ls_bseg-segment.

  APPEND INITIAL LINE TO lt_currency ASSIGNING <fs_curr>.

  <fs_curr>-itemno_acc   = lv_item.
  <fs_curr>-amt_doccur   = is_app-montante * -1.
  <fs_curr>-currency_iso = lc_moeda.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = ls_header
    IMPORTING
      obj_key        = lv_key
    TABLES
      accountgl      = lt_gl
      currencyamount = lt_currency
      return         = lt_return.

  IF lv_key NE '$' AND lv_key IS NOT INITIAL.

    ls_doc-belnr  = lv_key(10).
    ls_doc-bukrs  = lv_key+10(4).
    ls_doc-gjahr  = lv_key+14(4).

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_ret>-type       = 'I'.
    <fs_ret>-number     = '013'.

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_ret>-type       = 'S'.
    <fs_ret>-number     = '017'.
    <fs_ret>-message_v1 = lv_key(10).
    <fs_ret>-message_v2 = lv_key+10(4).
    <fs_ret>-message_v3 = lv_key+14(4).

    REFRESH lt_return.

    SELECT * FROM zi_fi_get_prov_data_aux
      INTO TABLE @DATA(lt_prov)
      WHERE belnr = @is_app-numdoc
        AND bukrs = @is_app-empresa
        AND gjahr = @is_app-exercicio.

    LOOP AT lt_prov ASSIGNING FIELD-SYMBOL(<fs_prov>).

      ls_provisao-companycode                        = <fs_prov>-bukrs.
      ls_provisao-documentdate                       = sy-datum.
      ls_provisao-customer                           = <fs_prov>-kndnr.
      ls_provisao-reference2indocumentheader+2(2)    = <fs_prov>-vtweg.
      ls_provisao-accountingdocumentheadertext       = <fs_prov>-bzirk.
      ls_provisao-profitcenter                       = <fs_prov>-wwmt1_aux.
      ls_provisao-plant                              = <fs_prov>-werks.
      ls_provisao-balancetransactioncurrency         = lc_moeda.
      ls_provisao-amountinbalancetransaccrcy         = is_app-montante.

      IF ls_provisao-profitcenter IS NOT INITIAL.
        EXIT.
      ENDIF.

    ENDLOOP.

    SELECT
        bzirk, canal,
        setor, vkorg
      FROM ztfi_cont_cont
      INTO @DATA(ls_cont)
      UP TO 1 ROWS
      WHERE contrato    = @is_app-numcontrato
        AND aditivo     = @is_app-numaditivo
        AND kunnr       = @is_app-cliente
        AND bukrs       = @is_app-empresa
        AND gjahr       = @is_app-exercicio
        AND numero_item = @is_app-item
        AND belnr       = @is_app-numdoc.
    ENDSELECT.

    IF ls_cont-bzirk IS INITIAL
    OR ls_cont-canal IS INITIAL
    OR ls_cont-setor IS INITIAL
    OR ls_cont-vkorg IS INITIAL.

      UPDATE ztfi_cont_cont
         SET doc_provisao   = @ls_doc-belnr,
             exerc_provisao = @ls_doc-gjahr,
             mont_provisao  = @is_app-montante
       WHERE contrato       = @is_app-numcontrato
         AND aditivo        = @is_app-numaditivo
         AND kunnr          = @is_app-cliente
         AND bukrs          = @is_app-empresa
         AND gjahr          = @is_app-exercicio
         AND numero_item    = @is_app-item
         AND belnr          = @is_app-numdoc.

      IF sy-subrc = 0.

        COMMIT WORK AND WAIT.

      ENDIF.

    ELSE.

      NEW zclfi_reversao_provisao_events(  )->create_copa_post_cost(
        EXPORTING
          is_reversao       = ls_provisao
          is_reversao_popup = ls_provisao_popup
        IMPORTING
          et_return         = lt_return ).

      APPEND LINES OF lt_return TO ct_return.

      IF NOT line_exists( lt_return[ type = 'E' ] ).

        UPDATE ztfi_cont_cont
           SET doc_provisao   = ls_doc-belnr
               exerc_provisao = ls_doc-gjahr
               mont_provisao  = is_app-montante
         WHERE contrato       = is_app-numcontrato
           AND aditivo        = is_app-numaditivo.

        COMMIT WORK AND WAIT.

      ENDIF.

    ENDIF.

  ELSE.

    APPEND INITIAL LINE TO ct_return ASSIGNING <fs_ret>.
    <fs_ret>-id         = 'ZFI_CONTRATO_CLIENTE'.
    <fs_ret>-type       = 'E'.
    <fs_ret>-number     = '016'.

    APPEND LINES OF lt_return TO ct_return.

    APPEND INITIAL LINE TO lt_change ASSIGNING FIELD-SYMBOL(<fs_chg>).
    <fs_chg>-fdname = 'XREF1_HD'.
    <fs_chg>-newval = ls_bkpf-xref1_hd.

    APPEND INITIAL LINE TO lt_change ASSIGNING <fs_chg>.
    <fs_chg>-fdname = 'XREF2_HD'.
    <fs_chg>-newval = ls_bkpf-xref2_hd.

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_bukrs              = ls_doc-bukrs
        i_belnr              = ls_doc-belnr
        i_gjahr              = ls_doc-gjahr
      TABLES
        t_accchg             = lt_change
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.
    IF sy-subrc IS NOT INITIAL.
      DATA(lv_erro) = abap_true.
    ENDIF.

    UPDATE ztfi_cont_cont
       SET doc_provisao   = ls_doc-belnr
           exerc_provisao = ls_doc-gjahr
           mont_provisao  = is_app-montante
     WHERE contrato = is_app-numcontrato
       AND aditivo  = is_app-numaditivo.


    COMMIT WORK AND WAIT.

  ENDIF.

  LOOP AT ct_return ASSIGNING <fs_ret>.
    IF <fs_ret>-type EQ 'A' OR <fs_ret>-type EQ 'X'.
      <fs_ret>-type = 'W'.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
