FUNCTION zfmfi_conciliacao_manual_dda.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_CONCILIACAO) TYPE  ZSFI_CONCILIACAO_MANUAL
*"     VALUE(IV_XBLNR) TYPE  XBLNR OPTIONAL
*"     VALUE(IV_FISCALYEAR) TYPE  GJAHR OPTIONAL
*"     VALUE(IV_DOCNUMER) TYPE  BELNR_R OPTIONAL
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
    FREE MEMORY ID 'ZFI_REF'.

************************************************************
* Declarações
************************************************************
  CONSTANTS:
    lc_msgid TYPE bapiret2-id VALUE 'ZFI_SOLUCAO_DDA',

    BEGIN OF lc_fieldname,
      barcode        TYPE fieldname VALUE 'GLO_REF1',
      juros          TYPE fieldname VALUE 'PENFC',
*      desconto TYPE fieldname VALUE 'SKNTO',
      desconto       TYPE fieldname VALUE 'WSKTO',
      conta          TYPE fieldname VALUE 'SAKNR',
      bloqueio_pagto TYPE fieldname VALUE 'ZLSPR',
      data_diverg    TYPE fieldname VALUE 'ZFBDT',
      zlsch_b        TYPE fieldname VALUE 'ZLSCH',
      zuonr          TYPE fieldname VALUE 'ZUONR',
      xblnr          TYPE fieldname VALUE 'XBLNR',
      dda            TYPE char4     VALUE 'DDA_',
      kp             TYPE blart     VALUE 'KP',
      v31            TYPE bschl VALUE '31',
      v34            TYPE bschl VALUE '34',
      v40            TYPE bschl  VALUE '40',
      k              TYPE char1 VALUE 'K',
    END OF lc_fieldname,

    BEGIN OF lc_err_reason,
      cnpj       TYPE err_br VALUE 'C',
      vencimento TYPE err_br VALUE 'D',
      montante   TYPE err_br VALUE 'A',
      fatura     TYPE err_br VALUE 'V',
      b          TYPE err_br VALUE 'B',
    END OF lc_err_reason.

  DATA: ls_dda_old TYPE j1b_error_dda,
        ls_dda_mod TYPE j1b_error_dda,
        ls_ref_mod TYPE j1b_error_dda,
        lv_zuonr   TYPE dzuonr.

  DATA: lt_documents TYPE zctgmm_lancam_comp_documents.


*  IF is_conciliacao-duedateconverted IS NOT INITIAL.
*    lv_zuonr = lc_fieldname-dda && is_conciliacao-duedateconverted+6(2) && '.' && is_conciliacao-duedateconverted+4(2) && '.' && is_conciliacao-duedateconverted(4).
*  ENDIF.
*
*
*      DATA(lt_accchg) = VALUE fdm_t_accchg( ( fdname = lc_fieldname-barcode
*                                              newval = is_conciliacao-barcode ) ).

************************************************************
* Associação de código de barras com diferença de valor
************************************************************

      " Seleciona configuração de conta para a empresa
      SELECT SINGLE
          valortolerancia,
          contalow,
          contahig,
          datatolerancia,
          paymentmethod,
          documenttype
      FROM zi_fi_conta_dda
      WHERE companycode EQ @is_conciliacao-bukrs
      INTO @DATA(ls_conta_dda).
      IF sy-subrc NE 0.

        " ERRO - Conta não configurada para empresa
        MESSAGE e002(zfi_solucao_dda) WITH is_conciliacao-bukrs INTO DATA(lv_msg).
        et_return[] = VALUE bapiret2_tab( ( id         = lc_msgid
                                          type       = 'E'
                                          number     = '002'
                                          message_v1 = is_conciliacao-bukrs ) ).
        RETURN.

      ENDIF.

      select single *
      from zi_fi_cockpit_dda
      where ReferenceNo = @iv_xblnr
        AND StatusCheck EQ 'E'
      into @data(ls_fi_cockpit_dda).

      IF sy-subrc NE 0.

        " ERRO - Conta não configurada para empresa
        MESSAGE e002(zfi_solucao_dda) WITH is_conciliacao-bukrs INTO lv_msg.
        et_return[] = VALUE bapiret2_tab( ( id         = lc_msgid
                                          type       = 'E'
                                          number     = '002'
                                          message_v1 = is_conciliacao-bukrs ) ).
        RETURN.

      ENDIF.

      DATA(lv_diferenca) = CONV wrbtr( ls_fi_cockpit_dda-Amount - is_conciliacao-montante_fatura ).
      IF lv_diferenca GT 0.

        IF lv_diferenca LE ls_conta_dda-valortolerancia.

          data(lt_accchg) = VALUE fdm_t_accchg( ( fdname = lc_fieldname-conta
                                               newval = ls_conta_dda-contahig )
*                                             ( fdname = lc_fieldname-juros
*                                               newval = lv_diferenca )
                                             ( fdname = lc_fieldname-bloqueio_pagto
                                               newval = space )
                                            ).

* LSCHEPP - Lançamento Documento Compensação Juros - 02.08.2022 Início
          "Montando o cabeçalho do documento
          DATA(ls_header) = VALUE zclfi_dda_lancam_compensacao=>ty_s_header_data( bukrs = is_conciliacao-bukrs
                                                                                  waers = is_conciliacao-waers
                                                                                  bldat = sy-datum
                                                                                  budat = sy-datum
                                                                                  blart = lc_fieldname-kp "is_conciliacao-blart
                                                                                  bktxt = is_conciliacao-bktxt "sgtxt
                                                                                  monat = sy-datum+4(2)
                                                                                  xblnr = is_conciliacao-xblnr
                                                                                   ).

          SELECT SINGLE bupla
            FROM bseg
            INTO @DATA(lv_bupla)
            WHERE bukrs = @is_conciliacao-bukrs
              AND belnr = @is_conciliacao-belnr
              AND gjahr = @is_conciliacao-gjahr
              AND buzei = @is_conciliacao-buzei.

          SELECT bukrs, belnr, buzei, gjahr, hkont, kostl, netdt, sgtxt, bschl
            FROM bseg
            INTO TABLE @DATA(lt_bseg)
            WHERE bukrs = @is_conciliacao-bukrs
              AND belnr = @is_conciliacao-belnr
              AND gjahr = @is_conciliacao-gjahr.
          IF sy-subrc EQ 0.
            READ TABLE lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>) WITH KEY hkont(1) = '4'.
            IF sy-subrc EQ 0.
              DATA(lv_kostl) = <fs_bseg>-kostl.
            ENDIF.
            LOOP AT lt_bseg ASSIGNING <fs_bseg>.
              CHECK <fs_bseg>-netdt is not INITIAL.
              data(lv_netdt) = <fs_bseg>-netdt.
            ENDLOOP.
          ENDIF.

*          "Monta o item do documento

          DATA(lt_item) = VALUE zclfi_dda_lancam_compensacao=>ty_t_item_data( ( buzei = 001
                                                                                bschl = lc_fieldname-v34
                                                                                bupla = lv_bupla
                                                                                zfbdt = is_conciliacao-duedateconverted
                                                                                hkont = is_conciliacao-lifnr
                                                                                wrbtr = is_conciliacao-montante_dda
                                                                                zlsch = is_conciliacao-zlsch
                                                                                sgtxt = VALUE #( lt_bseg[ bschl = lc_fieldname-v31 ]-sgtxt OPTIONAL )
                                                                                zuonr = COND #( WHEN lv_zuonr IS NOT INITIAL THEN lv_zuonr )
          ) ).

          APPEND INITIAL LINE TO lt_item ASSIGNING FIELD-SYMBOL(<fs_s_item>).
          <fs_s_item>-buzei = 002.
          <fs_s_item>-bupla = lv_bupla.
          <fs_s_item>-bschl = lc_fieldname-v40.
          <fs_s_item>-hkont = ls_conta_dda-contalow.
          <fs_s_item>-wrbtr = lv_diferenca.
          <fs_s_item>-zlsch = is_conciliacao-zlsch.
          <fs_s_item>-sgtxt = |{ TEXT-004 } { is_conciliacao-xblnr }|.
          <fs_s_item>-kostl = lv_kostl.

          lt_documents = VALUE zclfi_dda_lancam_compensacao=>ty_t_documents( ( bukrs = is_conciliacao-bukrs
                                                                               koart = lc_fieldname-k
                                                                               hkont = is_conciliacao-lifnr
                                                                               belnr = is_conciliacao-belnr
                                                                               gjahr = is_conciliacao-gjahr
                                                                               buzei = is_conciliacao-buzei ) ).
          "Transferência c/compensação
          DATA(lo_lancam_compensacao) = NEW zclfi_dda_lancam_compensacao( 'UMBUCHNG' ).

          "Passando as informações para processamento
          lo_lancam_compensacao->set_header_data( ls_header ).
          lo_lancam_compensacao->set_item_data( lt_item ).
          lo_lancam_compensacao->set_documents( lt_documents ).

          DATA(lt_blntab) = lo_lancam_compensacao->clear_documents(  ).
          TRY.
              DATA(ls_blntab) = lt_blntab[ 1 ].
              DATA(lv_belnr) = ls_blntab-belnr.
              DATA(lv_gjahr) = ls_blntab-gjahr.
              DATA(lv_bukrs) = ls_blntab-bukrs.
            CATCH cx_sy_itab_line_not_found.
          ENDTRY.
* LSCHEPP - Lançamento Documento Compensação Juros - 02.08.2022 Fim

        ELSE.


          " ERRO - Valor de diferença excede o valor de tolerância
          MESSAGE e001(zfi_solucao_dda) INTO lv_msg.
          et_return[] = VALUE bapiret2_tab( ( id         = lc_msgid
                                              type       = 'E'
                                              number     = '001' ) ).
          RETURN.
        ENDIF.

      ENDIF.

      IF lv_diferenca LT 0.

        IF abs( lv_diferenca ) LE ls_conta_dda-valortolerancia.

          lt_accchg = VALUE fdm_t_accchg( BASE lt_accchg
                                             ( fdname = lc_fieldname-conta
                                               newval = ls_conta_dda-contalow )
                                             ( fdname = lc_fieldname-desconto
                                               newval = abs( lv_diferenca ) )
                                             ( fdname = lc_fieldname-bloqueio_pagto
                                               newval = space )
                                            ).

        ELSE.


          " ERRO - Valor de diferença excede o valor de tolerância
          MESSAGE e001(zfi_solucao_dda) INTO lv_msg.
          et_return[] = VALUE bapiret2_tab( ( id         = lc_msgid
                                            type       = 'E'
                                            number     = '001' ) ).
          RETURN.
        ENDIF.

      ENDIF.

*  IF iv_xblnr IS NOT INITIAL.

************************************************************
* Atualiza log de erro DDA  Referencia
************************************************************

  lt_accchg = VALUE fdm_t_accchg( BASE lt_accchg
                              ( fdname = lc_fieldname-data_diverg
                                newval = is_conciliacao-duedateconverted )
                              ( fdname = lc_fieldname-zlsch_b
                                newval = lc_err_reason-b )
                              ( fdname = 'ZBD1T'
                                newval = 0 )
                              ( fdname = lc_fieldname-zuonr
                                newval = |DDA_{ ls_fi_cockpit_dda-DueDateConverted+6(2) }.{ ls_fi_cockpit_dda-DueDateConverted+4(2) }.{ ls_fi_cockpit_dda-DueDateConverted(4) }|  )
                              ( fdname = lc_fieldname-barcode
                                newval = ls_fi_cockpit_dda-Barcode  )  ).

  if ls_fi_cockpit_dda-ErrReason = 'V'.
    delete lt_accchg where  fdname = 'ZBD1T'.
    delete lt_accchg where  fdname = lc_fieldname-data_diverg.
  endif.

  IF lv_belnr IS INITIAL AND
     lv_gjahr IS INITIAL AND
     lv_bukrs IS INITIAL.
    lv_belnr = is_conciliacao-belnr.
    lv_gjahr = is_conciliacao-gjahr.
    lv_bukrs = is_conciliacao-bukrs.
  ENDIF.

************************************************************
* Atualiza fatura com o código de barras do boleto DDA
* e diferença de valores desconto ou juros
************************************************************
  CALL FUNCTION 'FI_DOCUMENT_CHANGE'
    EXPORTING
*     i_kunnr              = space
      i_lifnr              = is_conciliacao-lifnr
*     i_hkont              = space
*     i_buzei              = is_conciliacao-buzei
      i_bukrs              = lv_bukrs
      i_belnr              = lv_belnr
      i_gjahr              = lv_gjahr
    TABLES
      t_accchg             = lt_accchg
    EXCEPTIONS
      no_reference         = 1
      no_document          = 2
      many_documents       = 3
      wrong_input          = 4
      overwrite_creditcard = 5
      OTHERS               = 6.

  IF sy-subrc NE 0.

    et_return[] = VALUE bapiret2_tab( ( id         = sy-msgid
                                        type       = sy-msgty
                                        number     = sy-msgno
                                        message_v1 = sy-msgv1
                                        message_v2 = sy-msgv2
                                        message_v3 = sy-msgv3
                                        message_v4 = sy-msgv4 ) ).

  ENDIF.


  SORT et_return BY type.

  READ TABLE et_return WITH KEY type = 'E'
    TRANSPORTING NO FIELDS BINARY SEARCH.

  IF sy-subrc NE 0.

************************************************************
* Atualiza log de erro DDA para log conciliado
************************************************************
    SELECT
        mandt,
        id,
        status_check,
        lifnr,
        reference_no,
        doc_num,
        miro_invoice,
        bukrs,
        gjahr,
        cnpj,
        due_date,
        amount,
        barcode,
        rec_num,
        partner,
        issue_date,
        posting_date,
        err_reason,
        msg
    FROM j1b_error_dda
    WHERE id EQ '@0A@'
        AND status_check EQ 'E'
        AND reference_no eq @ls_fi_cockpit_dda-ReferenceNo
        INTO @ls_dda_old UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc EQ 0.

      ls_dda_mod = ls_dda_old.
      ls_dda_mod-id = '@08@'.
      ls_dda_mod-status_check = 'S'.
      ls_dda_mod-reference_no = iv_xblnr.

      CLEAR ls_dda_mod-err_reason.
      ls_dda_mod-msg = SWITCH #( is_conciliacao-err_reason
                                 WHEN lc_err_reason-montante
                                    THEN TEXT-002
                                    ELSE TEXT-001 ).

      MODIFY j1b_error_dda FROM ls_dda_mod.
      DELETE j1b_error_dda FROM ls_dda_old.

      IF lv_belnr IS NOT INITIAL AND
      lv_diferenca GT 0.

        MODIFY ztfi_ddaerror_cp FROM @( VALUE #(
          gjahr    = ls_dda_mod-gjahr
          bukrs    = ls_dda_mod-bukrs
          belnr    = COND #( WHEN ls_dda_mod-doc_num IS INITIAL THEN is_conciliacao-belnr ELSE ls_dda_mod-doc_num )
          doc_comp = lv_belnr
        ) ).

      ENDIF.

    ENDIF.

    " SUCESSO - Conciliação executada com sucesso
    MESSAGE s004(zfi_solucao_dda) INTO lv_msg.
    et_return[] = VALUE bapiret2_tab( ( id         = lc_msgid
                                        type       = 'S'
                                        number     = '004' ) ).

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  ENDIF.

ENDFUNCTION.
