***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: WEVO - Processo Reversa do E-Commerce                  *
*** AUTOR    : Alysson Anjos – META                                   *
*** FUNCIONAL: Raphael Rocha – META                                   *
*** DATA     : 22/11/2021                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR        | DESCRIÇÃO                              *
***-------------------------------------------------------------------*
***           |              |                                        *
***********************************************************************
FUNCTION zfmfi_contab_reversa.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_CENARIO) TYPE  ZE_COD_CENARIO
*"     VALUE(IV_BUKRS) TYPE  BUKRS
*"     VALUE(IV_BSTKD) TYPE  BSTKD
*"     VALUE(IV_BUPLA) TYPE  BUPLA
*"     VALUE(IV_ZLSCH) TYPE  ZE_ZLSCH_ECOMERC
*"     VALUE(IV_TIPO_CENARIO) TYPE  ZE_TP_CENARIO OPTIONAL
*"     VALUE(IV_ORDEM) TYPE  ZE_COD_ORDEM OPTIONAL
*"     VALUE(IV_PAGAMENTO) TYPE  ZE_COD_PAGMNT OPTIONAL
*"     VALUE(IV_RESSARCIMENTO) TYPE  ZE_COD_RESSARCMNT OPTIONAL
*"     VALUE(IV_MERCADORIA) TYPE  ZE_COD_MERCADORIA OPTIONAL
*"     VALUE(IV_ORDEM_VENDA) TYPE  VBELN_VA OPTIONAL
*"     VALUE(IV_LIFNR) TYPE  LIFNR OPTIONAL
*"     VALUE(IV_VOUCHER) TYPE  ZE_VOUCHER OPTIONAL
*"     VALUE(IV_ZVOU) TYPE  ZE_ZVOU OPTIONAL
*"     VALUE(IV_VLR_RESTITUIR) TYPE  ZE_VLR_RESTITUIR OPTIONAL
*"     VALUE(IV_ID_PEDIDO) TYPE  ZE_PEDIDO_VTEX OPTIONAL
*"     VALUE(IV_DIAS) TYPE  ZE_DIAS_REVERS DEFAULT '5'
*"     VALUE(IV_ADM) TYPE  ZE_NROADM OPTIONAL
*"     VALUE(IV_NSU) TYPE  ZE_NSUTID OPTIONAL
*"     VALUE(IV_DT_VENDA) TYPE  ZE_DATVEN OPTIONAL
*"     VALUE(IV_ENCERRAR) TYPE  FLAG DEFAULT SPACE
*"     VALUE(IV_LCTO_PENDENTE) TYPE  FLAG DEFAULT 'X'
*"     VALUE(IV_TX_PERC) TYPE  ZE_PERCT_ESTORNO OPTIONAL
*"     VALUE(IV_ID_SALES_FORCE) TYPE  ZE_SALES_FORCE OPTIONAL
*"     VALUE(IV_RESERVADO_1) TYPE  ZE_CAMPO_RESERVADO1 OPTIONAL
*"     VALUE(IV_RESERVADO_2) TYPE  ZE_CAMPO_RESERVADO2 OPTIONAL
*"     VALUE(IV_RESERVADO_3) TYPE  ZE_CAMPO_RESERVADO3 OPTIONAL
*"     VALUE(IV_RESERVADO_4) TYPE  ZE_CAMPO_RESERVADO4 OPTIONAL
*"     VALUE(IV_RESERVADO_5) TYPE  ZE_CAMPO_RESERVADO5 OPTIONAL
*"     VALUE(IV_RESERVADO_6) TYPE  ZE_CAMPO_RESERVADO6 OPTIONAL
*"     VALUE(IV_RESERVADO_7) TYPE  ZE_CAMPO_RESERVADO7 OPTIONAL
*"     VALUE(IV_RESERVADO_8) TYPE  ZE_CAMPO_RESERVADO8 OPTIONAL
*"     VALUE(IV_RESERVADO_9) TYPE  ZE_CAMPO_RESERVADO9 OPTIONAL
*"     VALUE(IV_RESERVADO_10) TYPE  ZE_CAMPO_RESERVADO10 OPTIONAL
*"  EXPORTING
*"     VALUE(EV_SUBRC) TYPE  SY-SUBRC
*"     VALUE(EV_MSG) TYPE  BAPI_MSG
*"     VALUE(EV_BELNR) TYPE  BSEG-BELNR
*"     VALUE(EV_GJAHR) TYPE  BSEG-GJAHR
*"     VALUE(EV_BUKRS) TYPE  BSEG-BUKRS
*"     VALUE(EV_BELNR_F) TYPE  BSEG-BELNR
*"     VALUE(EV_GJAHR_F) TYPE  BSEG-GJAHR
*"     VALUE(EV_BUKRS_F) TYPE  BSEG-BUKRS
*"----------------------------------------------------------------------
  DATA: lt_accountgl      TYPE STANDARD TABLE OF bapiacgl09,
        lt_accountpayable TYPE STANDARD TABLE OF bapiacap09,
        lt_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
        lt_extension1     TYPE STANDARD TABLE OF bapiacextc,
        lt_extension2     TYPE STANDARD TABLE OF bapiparex,
        lt_return         TYPE STANDARD TABLE OF bapiret2.

  DATA: ls_documentheader TYPE bapiache09,
        ls_accountgl      TYPE bapiacgl09,
        ls_accountpayable TYPE bapiacap09,
        ls_currencyamount TYPE bapiaccr09,
        ls_extension1     TYPE bapiacextc,
        ls_extension2     TYPE bapiparex,
        ls_config         TYPE ztfi_ecm_config,
        ls_paramtr        TYPE ztfi_ecm_paramtr,
        ls_paramtr_r      TYPE ztfi_ecm_paramtr,
        ls_adm_tax        TYPE ztfi_ecm_adm_tax,
        ls_cont_log       TYPE ztfi_cont_revers,
        ls_cont_log_in    TYPE ztfi_cont_revers.

  DATA: lv_descricao  TYPE ze_descricao,
        lv_obj_type   TYPE bapiache09-obj_type,
        lv_obj_key    TYPE bapiache09-obj_key,
        lv_obj_sys    TYPE bapiache09-obj_sys,
        lv_cprog      TYPE sy-cprog,
        lv_bline_date TYPE acpi_zfbdt,
        lv_dia_sem    TYPE p,
        lv_field      TYPE fieldname,
        lv_variavel   TYPE fieldname,
        lv_off        TYPE i,
        lv_ini        TYPE i,
        lv_ini_t      TYPE i,
        lv_tam        TYPE i,
        lv_tam_t      TYPE i,
        lv_vlr        TYPE ze_valor_comp,
        lv_tax        TYPE ze_valor_comp,
        lv_lancar     TYPE flag,
        lv_text_aux   TYPE c LENGTH 100,
        lv_timestamp  TYPE timestamp,
        lv_data       TYPE sy-datum,
        lv_uzeit      TYPE sy-uzeit.

  FIELD-SYMBOLS: <fs_fld> TYPE any.

  CONSTANTS: lc_seprd       TYPE char1     VALUE '-',
             lc_space       TYPE char1     VALUE '',
             lc_sts_err     TYPE char1     VALUE '4',
             lc_sts_incpl   TYPE char1     VALUE '2',
             lc_sts_cmplt   TYPE char1     VALUE '1',
             lc_bcn_header  TYPE bktxt     VALUE 'CAIXA',
             lc_accnt_gl    TYPE char2     VALUE 'GL',
             lc_accnt_pa    TYPE char2     VALUE 'PA',
             lc_tplanc_glcc TYPE char4     VALUE 'GLCC',
             lc_item_1      TYPE posnr_acc VALUE '0000000001',
             lc_item_2      TYPE posnr_acc VALUE '0000000002',
             lc_bsc_tax     TYPE char1     VALUE 'S',
             lc_tim_zone    TYPE char6     VALUE 'BRAZIL',
             lc_lcn_npen    TYPE char1     VALUE 'N',
             lc_struct      TYPE te_struc  VALUE 'XREF1_HD',
             lc_struct_2    TYPE te_struc  VALUE 'XREF2_HD',
             lc_str_bupla   TYPE te_struc  VALUE 'BUPLA',
             lc_cprog       TYPE sy-cprog  VALUE '/YTC/CONR329',
             lc_msg_error   TYPE sy-msgty  VALUE 'E'.

  IF iv_voucher IS NOT INITIAL.
    REPLACE ALL OCCURRENCES OF lc_seprd IN iv_voucher WITH lc_space.
  ENDIF.

  IF iv_dias IS INITIAL.
    iv_dias = 5.
  ENDIF.

  ls_cont_log_in-cod_cenario       = iv_cenario.
  ls_cont_log_in-bukrs             = iv_bukrs.
  ls_cont_log_in-bstkd             = iv_bstkd.
  ls_cont_log_in-bupla             = iv_bupla.
  ls_cont_log_in-user_i            = sy-uname.
  ls_cont_log_in-id_pedido         = iv_id_pedido.
  ls_cont_log_in-cod_tipo_cenario  = iv_tipo_cenario.
  ls_cont_log_in-cod_ordem         = iv_ordem.
  ls_cont_log_in-cod_pgto          = iv_pagamento.
  ls_cont_log_in-cod_ressarcimento = iv_ressarcimento.
  ls_cont_log_in-cod_mercadoria    = iv_mercadoria.
  ls_cont_log_in-vbeln             = iv_ordem_venda.
  ls_cont_log_in-lifnr             = iv_lifnr.
  ls_cont_log_in-voucher           = iv_voucher.
  ls_cont_log_in-adm               = iv_adm.
  ls_cont_log_in-nsu               = iv_nsu.
  ls_cont_log_in-dt_venda          = iv_dt_venda.

  DATA(lo_ecom) = NEW zclfi_ecom( ).

  " Verifica duplicidade de lançamento
  lo_ecom->check_duplicidade( EXPORTING is_cont_log = ls_cont_log_in
                              IMPORTING es_dpl_log  = ls_cont_log ).

  IF ls_cont_log IS NOT INITIAL.
    ls_cont_log-status = lc_sts_err.
    ls_cont_log-data_i = sy-datum.
    ls_cont_log-hora_i = sy-uzeit.
    ls_cont_log-user_i = sy-uname.
    MESSAGE e001(zfi_wevo) INTO ev_msg.
    ev_subrc      = lc_sts_err.

    lo_ecom->atualizar_duplicidade( EXPORTING is_cont_log = ls_cont_log ).
  ENDIF.

  IF ls_cont_log IS NOT INITIAL.
    RETURN.
  ENDIF.

  " Valida se Cenário enviado existe
  lo_ecom->get_cenario_rev( EXPORTING iv_cod_cenario = iv_cenario
                            IMPORTING ev_descricao   = lv_descricao ).

  IF lv_descricao IS INITIAL.
    ev_subrc = lc_sts_err.
    MESSAGE e002(zfi_wevo) INTO ev_msg.
  ENDIF.

  IF ev_subrc IS NOT INITIAL.
    RETURN.
  ENDIF.

  " Valida se Tipo do Cenário enviado existe
  IF iv_tipo_cenario IS NOT INITIAL.

    CLEAR lv_descricao.
    lo_ecom->get_tipo_cenario_rev( EXPORTING iv_tp_cenario = iv_tipo_cenario
                                   IMPORTING ev_descricao  = lv_descricao ).

    IF lv_descricao IS INITIAL.
      ev_subrc = lc_sts_err.
      MESSAGE e003(zfi_wevo) INTO ev_msg.
    ENDIF.

    IF ev_subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

  ENDIF.

  " Valida se Tipo da ordem enviado existe
  IF iv_ordem IS NOT INITIAL.

    CLEAR lv_descricao.
    lo_ecom->get_ordem_rev( EXPORTING iv_ordem     = iv_ordem
                            IMPORTING ev_descricao = lv_descricao ).

    IF lv_descricao IS INITIAL.
      ev_subrc = lc_sts_err.
      MESSAGE e004(zfi_wevo) INTO ev_msg.
    ENDIF.

    IF ev_subrc IS NOT INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  " Valida se Pagamento enviado existe
  IF iv_pagamento IS NOT INITIAL.

    CLEAR lv_descricao.
    lo_ecom->get_pagamento_rev( EXPORTING iv_pagamento = iv_pagamento
                                IMPORTING ev_descricao = lv_descricao ).

    IF lv_descricao IS INITIAL.
      ev_subrc = lc_sts_err.
      MESSAGE e005(zfi_wevo) INTO ev_msg.
    ENDIF.

    IF ev_subrc IS NOT INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  " Valida se Ressarcimento enviado existe
  IF iv_ressarcimento IS NOT INITIAL.

    CLEAR lv_descricao.
    lo_ecom->get_ressarcimento_rev( EXPORTING iv_ressarcimento = iv_ressarcimento
                                    IMPORTING ev_descricao     = lv_descricao ).

    IF lv_descricao IS INITIAL.
      ev_subrc = lc_sts_err.
      MESSAGE e006(zfi_wevo) INTO ev_msg.
    ENDIF.

    IF ev_subrc IS NOT INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  " Valida se Mercadoria enviado existe
  IF iv_mercadoria IS NOT INITIAL.

    CLEAR lv_descricao.
    lo_ecom->get_mercadoria_rev( EXPORTING iv_mercadoria = iv_mercadoria
                                 IMPORTING ev_descricao  = lv_descricao ).

    IF lv_descricao IS INITIAL.
      ev_subrc = lc_sts_err.
      MESSAGE e007(zfi_wevo) INTO ev_msg.
    ENDIF.

    IF ev_subrc IS NOT INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  lo_ecom->get_config_cenarios( EXPORTING iv_cenario       = iv_cenario
                                          iv_tipo_cenario  = iv_tipo_cenario
                                          iv_ordem         = iv_ordem
                                          iv_pagamento     = iv_pagamento
                                          iv_ressarcimento = iv_ressarcimento
                                          iv_mercadoria    = iv_mercadoria
                                          iv_bukrs         = iv_bukrs
                                          iv_bupla         = iv_bupla
                                IMPORTING es_config        = ls_config
                                          es_parametro     = ls_paramtr
                                          ev_subrc         = ev_subrc
                                          ev_msg           = ev_msg ).

  IF ev_subrc IS NOT INITIAL.
    RETURN.
  ENDIF.

*****************************************************************
  " Document Header
*****************************************************************
  ls_documentheader-username   = sy-uname.
  ls_documentheader-header_txt = lc_bcn_header.
  ls_documentheader-comp_code  = iv_bukrs.
  ls_documentheader-doc_date   = sy-datum.
  ls_documentheader-pstng_date = sy-datum.
  ls_documentheader-fisc_year  = sy-datum(4).
  ls_documentheader-fis_period = sy-datum+4(2).
  ls_documentheader-doc_type   = ls_paramtr-doc_type.

  " REF_DOC_NO(pode existir conteúdo dinamico).
  FIND '<' IN ls_paramtr-ref_doc_no MATCH OFFSET lv_off.
  IF sy-subrc EQ 0.

    lv_ini   = lv_off + 1.
    lv_ini_t = lv_off.

    CLEAR lv_off.

    FIND '>' IN ls_paramtr-ref_doc_no MATCH OFFSET lv_off.
    IF sy-subrc EQ 0.

      lv_tam   = lv_off - 1.
      lv_tam_t = lv_off + 1.

      lv_field    = ls_paramtr-ref_doc_no+lv_ini(lv_tam).
      lv_variavel = ls_paramtr-ref_doc_no+lv_ini_t(lv_tam_t).

      ASSIGN (lv_field) TO <fs_fld>.
      IF sy-subrc IS INITIAL.
        REPLACE lv_variavel IN ls_paramtr-ref_doc_no WITH <fs_fld>.
        ls_documentheader-ref_doc_no = ls_paramtr-ref_doc_no.
      ELSE.
        UNASSIGN <fs_fld>.
      ENDIF.

    ELSE.

      ls_documentheader-ref_doc_no = ls_paramtr-ref_doc_no.

    ENDIF.

  ELSE.

    ls_documentheader-ref_doc_no = ls_paramtr-ref_doc_no.

  ENDIF.


*****************************************************************
  " Account GL - LINHA 0000000001
*****************************************************************
  IF ls_paramtr-tipolancto1(2) EQ lc_accnt_gl.

    "Account GL - Débito
    ls_accountgl-itemno_acc = lc_item_1.
    ls_accountgl-gl_account = ls_paramtr-saknr1.
    ls_accountgl-comp_code  = iv_bukrs.
    ls_accountgl-bus_area   = ls_config-gsber.
    ls_accountgl-profit_ctr = ls_config-prctr.

    IF ls_paramtr-tipolancto1 EQ lc_tplanc_glcc.
      ls_accountgl-costcenter = ls_config-kostl.
    ENDIF.

    " ITEM_TEXT(pode existir conteúdo dinamico).
    CLEAR: lv_off,
           lv_field,
           lv_variavel.

    lv_text_aux = ls_paramtr-text1.

    DO.
      FIND '<' IN lv_text_aux MATCH OFFSET lv_off.

      IF sy-subrc EQ 0.

        lv_ini   = lv_off + 1.
        lv_ini_t = lv_off.

        CLEAR lv_off.

        FIND '>' IN lv_text_aux MATCH OFFSET lv_off.
        IF sy-subrc EQ 0.

          lv_tam   = lv_off - lv_ini.
          lv_tam_t = ( lv_off - lv_ini_t ) + 1.

          lv_field    = lv_text_aux+lv_ini(lv_tam).
          lv_variavel = lv_text_aux+lv_ini_t(lv_tam_t).

          ASSIGN (lv_field) TO <fs_fld>.
          IF sy-subrc IS INITIAL.
            REPLACE lv_variavel IN lv_text_aux WITH <fs_fld>.
          ENDIF.

          ls_accountgl-item_text = lv_text_aux.

        ELSE.

          ls_accountgl-item_text = lv_text_aux.
          EXIT.

        ENDIF.

      ELSE.

        ls_accountgl-item_text = lv_text_aux.
        EXIT.

      ENDIF.
    ENDDO.

    " ALLOC_NMBR(pode existir conteúdo dinamico).
    CLEAR: lv_off,
           lv_field,
           lv_variavel.

    FIND '<' IN ls_paramtr-alloc_nmbr1 MATCH OFFSET lv_off.
    IF sy-subrc EQ 0.

      lv_ini   = lv_off + 1.
      lv_ini_t = lv_off.

      CLEAR lv_off.

      FIND '>' IN ls_paramtr-alloc_nmbr1 MATCH OFFSET lv_off.
      IF sy-subrc EQ 0.

        lv_tam   = lv_off - lv_ini.
        lv_tam_t = ( lv_off - lv_ini_t ) + 1.

        lv_field    = ls_paramtr-alloc_nmbr1+lv_ini(lv_tam).
        lv_variavel = ls_paramtr-alloc_nmbr1+lv_ini_t(lv_tam_t).

        ASSIGN (lv_field) TO <fs_fld>.
        IF sy-subrc IS INITIAL.
          REPLACE lv_variavel IN ls_paramtr-alloc_nmbr1 WITH <fs_fld>.
        ENDIF.

        ls_accountgl-alloc_nmbr = ls_paramtr-alloc_nmbr1.

      ELSE.

        ls_accountgl-alloc_nmbr = ls_paramtr-alloc_nmbr1.

      ENDIF.

    ELSE.

      ls_accountgl-alloc_nmbr = ls_paramtr-alloc_nmbr1.

    ENDIF.

    APPEND ls_accountgl TO lt_accountgl.
    CLEAR ls_accountgl.

  ENDIF.

*****************************************************************
  " Account GL - LINHA 0000000002
*****************************************************************
  IF ls_paramtr-tipolancto2(2) EQ lc_accnt_gl.
    ls_accountgl-itemno_acc = lc_item_2.
    ls_accountgl-gl_account = ls_paramtr-saknr2.
    ls_accountgl-comp_code  = iv_bukrs.
    ls_accountgl-bus_area   = ls_config-gsber.
    ls_accountgl-profit_ctr = ls_config-prctr.

    IF ls_paramtr-tipolancto2 EQ lc_tplanc_glcc.
      ls_accountgl-costcenter = ls_config-kostl.
    ENDIF.

    " ITEM_TEXT(pode existir conteúdo dinamico).
    CLEAR: lv_off,
           lv_field,
           lv_variavel.

    CLEAR lv_text_aux.
    lv_text_aux = ls_paramtr-text2.

    DO.
      FIND '<' IN lv_text_aux MATCH OFFSET lv_off.
      IF sy-subrc EQ 0.

        lv_ini   = lv_off + 1.
        lv_ini_t = lv_off.

        CLEAR lv_off.

        FIND '>' IN lv_text_aux MATCH OFFSET lv_off.
        IF sy-subrc EQ 0.

          lv_tam   = lv_off - lv_ini.
          lv_tam_t = ( lv_off - lv_ini_t ) + 1.

          lv_field    = lv_text_aux+lv_ini(lv_tam).
          lv_variavel = lv_text_aux+lv_ini_t(lv_tam_t).

          ASSIGN (lv_field) TO <fs_fld>.
          IF sy-subrc IS INITIAL.
            REPLACE lv_variavel IN lv_text_aux WITH <fs_fld>.
          ENDIF.

          ls_accountgl-item_text = lv_text_aux.

        ELSE.

          ls_accountgl-item_text = lv_text_aux.
          EXIT.

        ENDIF.

      ELSE.

        ls_accountgl-item_text = lv_text_aux.
        EXIT.

      ENDIF.
    ENDDO.

    " ALLOC_NMBR(pode existir conteúdo dinamico).
    CLEAR: lv_off,
           lv_field,
           lv_variavel.

    FIND '<' IN ls_paramtr-alloc_nmbr2 MATCH OFFSET lv_off.
    IF sy-subrc EQ 0.

      lv_ini   = lv_off + 1.
      lv_ini_t = lv_off.

      CLEAR lv_off.

      FIND '>' IN ls_paramtr-alloc_nmbr2 MATCH OFFSET lv_off.
      IF sy-subrc EQ 0.

        lv_tam   = lv_off - lv_ini.
        lv_tam_t = ( lv_off - lv_ini_t ) + 1.

        lv_field    = ls_paramtr-alloc_nmbr2+lv_ini(lv_tam).
        lv_variavel = ls_paramtr-alloc_nmbr2+lv_ini_t(lv_tam_t).

        ASSIGN (lv_field) TO <fs_fld>.
        IF sy-subrc IS INITIAL.
          REPLACE lv_variavel IN ls_paramtr-alloc_nmbr2 WITH <fs_fld>.
        ENDIF.

        ls_accountgl-alloc_nmbr = ls_paramtr-alloc_nmbr2.

      ELSE.

        ls_accountgl-alloc_nmbr = ls_paramtr-alloc_nmbr2.

      ENDIF.

    ELSE.

      ls_accountgl-alloc_nmbr = ls_paramtr-alloc_nmbr2.

    ENDIF.

    APPEND ls_accountgl TO lt_accountgl.
    CLEAR ls_accountgl.

  ENDIF.

*****************************************************************
  " Account Payable - LINHA 0000000001
*****************************************************************
  IF ls_paramtr-tipolancto1 EQ lc_accnt_pa.

    " Account Payable - Conta Razão
    ls_accountpayable-itemno_acc = lc_item_1.
    ls_accountpayable-gl_account = ls_paramtr-saknr1.
    ls_accountpayable-comp_code  = iv_bukrs.
    ls_accountpayable-bus_area   = ls_config-gsber.
    ls_accountpayable-pymt_meth  = ls_paramtr-zlsch.
    ls_accountpayable-alloc_nmbr = ls_paramtr-alloc_nmbr1.

    " ITEM_TEXT(pode existir conteúdo dinamico).
    CLEAR: lv_off,
           lv_field,
           lv_variavel.

    lv_text_aux = ls_paramtr-text1.
    DO.
      FIND '<' IN lv_text_aux MATCH OFFSET lv_off.
      IF sy-subrc EQ 0.

        lv_ini   = lv_off + 1.
        lv_ini_t = lv_off.

        CLEAR lv_off.

        FIND '>' IN lv_text_aux MATCH OFFSET lv_off.
        IF sy-subrc EQ 0.

          lv_tam   = lv_off - lv_ini.
          lv_tam_t = ( lv_off - lv_ini_t ) + 1.

          lv_field    = lv_text_aux+lv_ini(lv_tam).
          lv_variavel = lv_text_aux+lv_ini_t(lv_tam_t).

          ASSIGN (lv_field) TO <fs_fld>.
          IF sy-subrc IS INITIAL.
            REPLACE lv_variavel IN lv_text_aux WITH <fs_fld>.
          ENDIF.
          ls_accountpayable-item_text = lv_text_aux.

        ELSE.

          ls_accountpayable-item_text = lv_text_aux.
          EXIT.

        ENDIF.

      ELSE.

        ls_accountpayable-item_text = lv_text_aux.
        EXIT.

      ENDIF.
    ENDDO.

    ls_accountpayable-profit_ctr    = ls_config-prctr.

    APPEND ls_accountpayable TO lt_accountpayable.
    CLEAR ls_accountpayable.

  ENDIF.

  IF ls_paramtr-tipolancto2 EQ lc_accnt_pa.

    " Account Payable - Cliente/Fornecedor
    lv_bline_date = sy-datum + iv_dias.

    CALL FUNCTION 'DAY_IN_WEEK'
      EXPORTING
        datum = lv_bline_date
      IMPORTING
        wotnr = lv_dia_sem.

    IF lv_dia_sem = 6.
      lv_bline_date = lv_bline_date + 2.
    ENDIF.

    IF lv_dia_sem = 7.
      lv_bline_date = lv_bline_date + 1.
    ENDIF.

    ls_accountpayable-itemno_acc = lc_item_2.
    ls_accountpayable-vendor_no  = iv_lifnr.
    ls_accountpayable-comp_code  = iv_bukrs.
    ls_accountpayable-bus_area   = ls_config-gsber.
    ls_accountpayable-pmnttrms   = ls_config-zterm.
    ls_accountpayable-bline_date = lv_bline_date.
    ls_accountpayable-pymt_meth  = ls_paramtr-zlsch.
    ls_accountpayable-alloc_nmbr = ls_paramtr-alloc_nmbr2.

    "ITEM_TEXT(pode existir conteúdo dinamico).
    CLEAR: lv_off,
           lv_field,
           lv_variavel.

    lv_text_aux = ls_paramtr-text2.
    DO.
      FIND '<' IN lv_text_aux MATCH OFFSET lv_off.
      IF sy-subrc EQ 0.

        lv_ini   = lv_off + 1.
        lv_ini_t = lv_off.

        CLEAR lv_off.

        FIND '>' IN lv_text_aux MATCH OFFSET lv_off.
        IF sy-subrc EQ 0.

          lv_tam   = lv_off - lv_ini.
          lv_tam_t = ( lv_off - lv_ini_t ) + 1.

          lv_field    = lv_text_aux+lv_ini(lv_tam).
          lv_variavel = lv_text_aux+lv_ini_t(lv_tam_t).

          ASSIGN (lv_field) TO <fs_fld>.
          IF sy-subrc IS INITIAL.
            REPLACE lv_variavel IN lv_text_aux WITH <fs_fld>.
          ENDIF.
          ls_accountpayable-item_text = lv_text_aux.

        ELSE.

          ls_accountpayable-item_text = lv_text_aux.
          EXIT.

        ENDIF.

      ELSE.

        ls_accountpayable-item_text = lv_text_aux.
        EXIT.

      ENDIF.
    ENDDO.

    ls_accountpayable-profit_ctr    = ls_config-prctr.

    APPEND ls_accountpayable TO lt_accountpayable.
    CLEAR ls_accountpayable.

  ENDIF.

*****************************************************************
  " Currency Amount
*****************************************************************
  IF ls_paramtr-busca_taxa = lc_bsc_tax.

    lo_ecom->get_vlr_taxa( EXPORTING iv_adm     = iv_adm
                                     iv_bukrs   = ls_config-bukrs
                                     iv_dtvenda = iv_dt_venda
                                     iv_nsu     = iv_nsu
                                     iv_werks   = ls_config-werks
                           IMPORTING ev_vlr     = lv_tax
                                     ev_lancar  = lv_lancar
                                     es_adm_tax = ls_adm_tax ).

    lv_tax = abs( lv_tax ).

    IF ls_adm_tax-tx_parcial = lc_bsc_tax
   AND ls_paramtr-tx_parcial = lc_bsc_tax.
      IF iv_tx_perc IS INITIAL
      OR iv_tx_perc > 1.
        iv_tx_perc = 1.
      ENDIF.

      lv_tax = lv_tax * iv_tx_perc.
    ENDIF.

    IF lv_lancar EQ abap_true." Fazer lançamento

      IF lv_tax = 0. "Grava LOG e não faz lançaemnto

        CLEAR lv_lancar.

        GET TIME STAMP FIELD lv_timestamp.

        CONVERT TIME STAMP lv_timestamp TIME ZONE lc_tim_zone
                                        INTO DATE lv_data
                                             TIME lv_uzeit.

        " Preencher LOG estrutura de LOG.
        ls_cont_log-cod_cenario       = iv_cenario.
        ls_cont_log-bukrs             = iv_bukrs.
        ls_cont_log-bstkd             = iv_bstkd.
        ls_cont_log-bupla             = iv_bupla.
        ls_cont_log-zlsch             = iv_zlsch.
        ls_cont_log-data_i            = lv_data.
        ls_cont_log-hora_i            = lv_uzeit.
        ls_cont_log-user_i            = sy-uname.
        ls_cont_log-gsber             = ls_config-gsber.
        ls_cont_log-cod_tipo_cenario  = iv_tipo_cenario.
        ls_cont_log-cod_ordem         = iv_ordem.
        ls_cont_log-cod_pgto          = iv_pagamento.
        ls_cont_log-cod_ressarcimento = iv_ressarcimento.
        ls_cont_log-cod_mercadoria    = iv_mercadoria.
        ls_cont_log-vbeln             = iv_ordem_venda.
        ls_cont_log-lifnr             = iv_lifnr.
        ls_cont_log-voucher           = iv_voucher.

        IF lv_tax > 0.
          ls_cont_log-zvou          = 0.
          ls_cont_log-vlr_restituir = 0.
        ELSE.
          ls_cont_log-zvou          = iv_zvou.
          ls_cont_log-vlr_restituir = iv_vlr_restituir.
        ENDIF.

        ls_cont_log-id_pedido      = iv_id_pedido.
        ls_cont_log-adm            = iv_adm.
        ls_cont_log-nsu            = iv_nsu.
        ls_cont_log-dt_venda       = iv_dt_venda.
        ls_cont_log-belnr          = ev_belnr.
        ls_cont_log-gjahr          = ev_gjahr.
        ls_cont_log-nome_ident     = ls_paramtr-nome_ident.
        ls_cont_log-vlr_tax        = lv_tax.
        ls_cont_log-status         = lc_sts_incpl.
        ls_cont_log-tx_perc        = iv_tx_perc.
        ls_cont_log-id_sales_force = iv_id_sales_force.
        ls_cont_log-reservado_1    = iv_reservado_1.
        ls_cont_log-reservado_2    = iv_reservado_2.
        ls_cont_log-reservado_3    = iv_reservado_3.
        ls_cont_log-reservado_4    = iv_reservado_4.
        ls_cont_log-reservado_5    = iv_reservado_5.
        ls_cont_log-reservado_6    = iv_reservado_6.
        ls_cont_log-reservado_7    = iv_reservado_7.
        ls_cont_log-reservado_8    = iv_reservado_8.
        ls_cont_log-reservado_9    = iv_reservado_9.
        ls_cont_log-reservado_10   = iv_reservado_10.

        IF iv_lcto_pendente NE lc_lcn_npen.

          lo_ecom->insert_log( EXPORTING is_log   = ls_cont_log
                               IMPORTING ev_subrc = ev_subrc
                                         ev_msg   = ev_msg ).

          IF ev_subrc IS INITIAL.

            lo_ecom->atualizar_lcto_pendentes( ).

            ev_subrc = lc_sts_err.
            MESSAGE e008(zfi_wevo) INTO ev_msg.

          ELSE.

            ev_subrc = lc_sts_err.
            MESSAGE e009(zfi_wevo) INTO ev_msg.

          ENDIF.

        ELSE.

          ev_subrc = lc_sts_err.

        ENDIF.
      ENDIF.

    ELSE.

      IF iv_lcto_pendente EQ abap_true.

        lo_ecom->atualizar_lcto_pendentes( ).

      ENDIF.

      ev_subrc = lc_sts_err.
      MESSAGE e010(zfi_wevo) INTO ev_msg.

    ENDIF.

  ELSE.

    ev_subrc  = 0.
    lv_lancar = abap_true.

  ENDIF.

  IF ev_subrc IS NOT INITIAL.
    RETURN.
  ENDIF.

  IF lv_tax IS NOT INITIAL.
    lv_vlr = lv_tax.
  ELSE.
    IF iv_voucher IS INITIAL.
      lv_vlr = iv_vlr_restituir.
    ELSE.
      lv_vlr = iv_zvou.
    ENDIF.
  ENDIF.

  " Currency Amount - Conta Razão
  ls_currencyamount-itemno_acc   = lc_item_1.
  ls_currencyamount-currency_iso = ls_config-waers.
  ls_currencyamount-amt_doccur   = lv_vlr.
  ls_currencyamount-disc_base    = 0.
  APPEND ls_currencyamount TO lt_currencyamount.
  CLEAR ls_currencyamount.

  " Currency Amount - Conta Cliente

  ls_currencyamount-itemno_acc   = lc_item_2.
  ls_currencyamount-currency_iso = ls_config-waers.
  IF lv_tax IS INITIAL.
    ls_currencyamount-amt_doccur = lv_vlr * -1.
    ls_currencyamount-disc_base  = lv_vlr * -1.
  ELSE.
    ls_currencyamount-amt_doccur = lv_vlr * -1.
    ls_currencyamount-disc_base  = 0.
  ENDIF.

  APPEND ls_currencyamount TO lt_currencyamount.
  CLEAR ls_currencyamount.

*****************************************************************
  " Extension 2
*****************************************************************
  " Preencher o campo XREF1_HD - Linha 0000000001
  ls_extension2-structure  = lc_struct.
  ls_extension2-valuepart1 = lc_item_1.

  " REFKEY1(pode existir conteúdo dinamico).
  CLEAR: lv_off,
         lv_field,
         lv_variavel.

  FIND '<' IN ls_paramtr-refkey1 MATCH OFFSET lv_off.
  IF sy-subrc EQ 0.

    lv_ini   = lv_off + 1.
    lv_ini_t = lv_off.

    CLEAR lv_off.

    FIND '>' IN ls_paramtr-refkey1 MATCH OFFSET lv_off.
    IF sy-subrc EQ 0.

      lv_tam   = lv_off - lv_ini.
      lv_tam_t = ( lv_off - lv_ini_t ) + 1.

      lv_field    = ls_paramtr-refkey1+lv_ini(lv_tam).
      lv_variavel = ls_paramtr-refkey1+lv_ini_t(lv_tam_t).

      ASSIGN (lv_field) TO <fs_fld>.
      IF sy-subrc IS INITIAL.
        REPLACE lv_variavel IN ls_paramtr-refkey1 WITH <fs_fld>.
      ENDIF.

      ls_extension2-valuepart2 = ls_paramtr-refkey1.

    ELSE.
      ls_extension2-valuepart2 = ls_paramtr-refkey1.
    ENDIF.
  ELSE.
    ls_extension2-valuepart2 = ls_paramtr-refkey1.
  ENDIF.

  APPEND ls_extension2 TO lt_extension2.
  CLEAR ls_extension2.

  " Preencher o campo XREF1_HD - - Linha 0000000002
  ls_extension2-structure  = lc_struct.
  ls_extension2-valuepart1 = lc_item_2.
  ls_extension2-valuepart2 = ls_paramtr-refkey1.
  APPEND ls_extension2 TO lt_extension2.
  CLEAR ls_extension2.

  " Preencher o campo BUPLA - - Linha 0000000001
  ls_extension2-structure  = lc_str_bupla.
  ls_extension2-valuepart1 = lc_item_1.
  ls_extension2-valuepart2 = iv_bupla.
  APPEND ls_extension2 TO lt_extension2.
  CLEAR ls_extension2.

  " Preencher o campo BUPLA - - Linha 0000000002
  ls_extension2-structure  = lc_str_bupla.
  ls_extension2-valuepart1 = lc_item_2.
  ls_extension2-valuepart2 = iv_bupla.
  APPEND ls_extension2 TO lt_extension2.
  CLEAR ls_extension2.

*****************************************************************
  " Extension 1
*****************************************************************
  ls_extension1-field1 = lc_struct_2.
  ls_extension1-field2 = lc_item_1.

  " REFKEY1(pode existir conteúdo dinamico).
  CLEAR: lv_off,
         lv_field,
         lv_variavel.

  FIND '<' IN ls_paramtr-refkey2 MATCH OFFSET lv_off.
  IF sy-subrc EQ 0.

    lv_ini   = lv_off + 1.
    lv_ini_t = lv_off.

    CLEAR lv_off.

    FIND '>' IN ls_paramtr-refkey2 MATCH OFFSET lv_off.
    IF sy-subrc EQ 0.

      lv_tam   = lv_off - lv_ini.
      lv_tam_t = ( lv_off - lv_ini_t ) + 1.

      lv_field    = ls_paramtr-refkey2+lv_ini(lv_tam).
      lv_variavel = ls_paramtr-refkey2+lv_ini_t(lv_tam_t).

      ASSIGN (lv_field) TO <fs_fld>.
      IF sy-subrc IS INITIAL.
        REPLACE lv_variavel IN ls_paramtr-refkey2 WITH <fs_fld>.
      ENDIF.

      ls_extension1-field3 = ls_paramtr-refkey2.

    ELSE.
      ls_extension1-field3 = ls_paramtr-refkey2.
    ENDIF.
  ELSE.
    ls_extension1-field3 = ls_paramtr-refkey2.
  ENDIF.

  APPEND ls_extension1 TO lt_extension1.

  " Preencher o campo XREF1_HD - - Linha 0000000002
  ls_extension1-field1 = lc_struct.
  ls_extension1-field2 = lc_item_2.
  ls_extension1-field3 = ls_paramtr-refkey1.
  APPEND ls_extension1 TO lt_extension1.

  " Passar na BADI para preencher o campo XREF1_HD, utilizando a implementação ja existente da PCI.
  lv_cprog = sy-cprog.
  sy-cprog = lc_cprog.

  " Vcto + 3dias, se cair no fim de semana, joga pra segunda.
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = ls_documentheader
    IMPORTING
      obj_type       = lv_obj_type
      obj_key        = lv_obj_key
      obj_sys        = lv_obj_sys
    TABLES
      accountgl      = lt_accountgl
      accountpayable = lt_accountpayable
      currencyamount = lt_currencyamount
      extension1     = lt_extension1
      return         = lt_return
      extension2     = lt_extension2.

  SORT lt_return BY type.

  READ TABLE lt_return ASSIGNING FIELD-SYMBOL(<fs_return>)
                                     WITH KEY type = lc_msg_error
                                     BINARY SEARCH.
  IF sy-subrc NE 0.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    ev_subrc = 0.
    MESSAGE s011(zfi_wevo) INTO ev_msg.
    ev_bukrs = lv_obj_key+10(4).
    ev_belnr = lv_obj_key(10).
    ev_gjahr = lv_obj_key+14(4).

    GET TIME STAMP FIELD lv_timestamp.
    CONVERT TIME STAMP lv_timestamp TIME ZONE lc_tim_zone
                                    INTO DATE lv_data
                                         TIME lv_uzeit.

    " Preencher LOG estrutura de LOG.
    ls_cont_log-cod_cenario       = iv_cenario.
    ls_cont_log-bukrs             = iv_bukrs.
    ls_cont_log-bstkd             = iv_bstkd.
    ls_cont_log-bupla             = iv_bupla.
    ls_cont_log-zlsch             = iv_zlsch.
    ls_cont_log-data_i            = lv_data.
    ls_cont_log-hora_i            = lv_uzeit.
    ls_cont_log-user_i            = sy-uname.
    ls_cont_log-gsber             = ls_config-gsber.
    ls_cont_log-cod_tipo_cenario  = iv_tipo_cenario.
    ls_cont_log-cod_ordem         = iv_ordem.
    ls_cont_log-cod_pgto          = iv_pagamento.
    ls_cont_log-cod_ressarcimento = iv_ressarcimento.
    ls_cont_log-cod_mercadoria    = iv_mercadoria.
    ls_cont_log-vbeln             = iv_ordem_venda.
    ls_cont_log-lifnr             = iv_lifnr.
    ls_cont_log-voucher           = iv_voucher.

    IF lv_tax > 0.
      ls_cont_log-zvou          = 0.
      ls_cont_log-vlr_restituir = 0.
    ELSE.
      ls_cont_log-zvou          = iv_zvou.
      ls_cont_log-vlr_restituir = iv_vlr_restituir.
    ENDIF.

    ls_cont_log-id_pedido      = iv_id_pedido.
    ls_cont_log-adm            = iv_adm.
    ls_cont_log-nsu            = iv_nsu.
    ls_cont_log-dt_venda       = iv_dt_venda.
    ls_cont_log-belnr          = ev_belnr.
    ls_cont_log-gjahr          = ev_gjahr.
    ls_cont_log-nome_ident     = ls_paramtr-nome_ident.
    ls_cont_log-vlr_tax        = lv_tax.
    ls_cont_log-status         = lc_sts_cmplt.
    ls_cont_log-bukrs_d        = ev_bukrs.
    ls_cont_log-tx_perc        = iv_tx_perc.
    ls_cont_log-id_sales_force = iv_id_sales_force.
    ls_cont_log-reservado_1    = iv_reservado_1.
    ls_cont_log-reservado_2    = iv_reservado_2.
    ls_cont_log-reservado_3    = iv_reservado_3.
    ls_cont_log-reservado_4    = iv_reservado_4.
    ls_cont_log-reservado_5    = iv_reservado_5.
    ls_cont_log-reservado_6    = iv_reservado_6.
    ls_cont_log-reservado_7    = iv_reservado_7.
    ls_cont_log-reservado_8    = iv_reservado_8.
    ls_cont_log-reservado_9    = iv_reservado_9.
    ls_cont_log-reservado_10   = iv_reservado_10.

    lo_ecom->insert_log( EXPORTING is_log   = ls_cont_log
                         IMPORTING ev_subrc = ev_subrc
                                   ev_msg   = ev_msg ).

    " Atualizar ZTFI_WEVO_CONTAB - PROC_SUCC
    IF ev_subrc NE 0.

      ev_subrc = lc_sts_err.
      MESSAGE e012(zfi_wevo) INTO ev_msg.

    ELSE.

      IF ls_paramtr-nome_ident_f IS NOT INITIAL
     AND iv_encerrar         IS INITIAL.

        lo_ecom->get_config_cenario_filha( EXPORTING iv_nome_mae  = ls_paramtr-nome_ident_f
                                           IMPORTING es_parametro = ls_paramtr_r ).

        IF ls_paramtr_r IS NOT INITIAL.

          WAIT UP TO 2 SECONDS.

          CALL FUNCTION 'ZFMFI_CONTAB_REVERSA'
            EXPORTING
              iv_cenario        = ls_paramtr_r-cod_cenario
              iv_bukrs          = iv_bukrs
              iv_bstkd          = iv_bstkd
              iv_bupla          = iv_bupla
              iv_zlsch          = iv_zlsch
              iv_tipo_cenario   = ls_paramtr_r-cod_tipo_cenario
              iv_ordem          = ls_paramtr_r-cod_ordem
              iv_pagamento      = ls_paramtr_r-cod_pgto
              iv_ressarcimento  = ls_paramtr_r-cod_ressarcimento
              iv_mercadoria     = ls_paramtr_r-cod_mercadoria
              iv_ordem_venda    = iv_ordem_venda
              iv_lifnr          = iv_lifnr
              iv_voucher        = iv_voucher
              iv_zvou           = iv_zvou
              iv_vlr_restituir  = iv_vlr_restituir
              iv_id_pedido      = iv_id_pedido
              iv_adm            = iv_adm
              iv_nsu            = iv_nsu
              iv_dt_venda       = iv_dt_venda
              iv_encerrar       = abap_true
              iv_tx_perc        = iv_tx_perc
              iv_id_sales_force = iv_id_sales_force
              iv_reservado_1    = iv_reservado_1
              iv_reservado_2    = iv_reservado_2
              iv_reservado_3    = iv_reservado_3
              iv_reservado_4    = iv_reservado_4
              iv_reservado_5    = iv_reservado_5
              iv_reservado_6    = iv_reservado_6
              iv_reservado_7    = iv_reservado_7
              iv_reservado_8    = iv_reservado_8
              iv_reservado_9    = iv_reservado_9
              iv_reservado_10   = iv_reservado_10
            IMPORTING
              ev_subrc          = ev_subrc
              ev_msg            = ev_msg
              ev_belnr          = ev_belnr_f
              ev_gjahr          = ev_gjahr_f
              ev_bukrs          = ev_bukrs_f.

        ENDIF.

      ENDIF.

    ENDIF.

    IF iv_lcto_pendente EQ abap_true.
      lo_ecom->atualizar_lcto_pendentes( ).
    ENDIF.

  ELSE.

    ev_subrc = lc_sts_err.
    ev_msg   = <fs_return>-message.

  ENDIF.

  sy-cprog = lv_cprog.

ENDFUNCTION.                                             "#EC CI_VALPAR
