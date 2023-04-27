class ZCLFI_ECOM definition
  public
  final
  create public .

public section.

  methods CHECK_DUPLICIDADE
    importing
      !IS_CONT_LOG type ZTFI_CONT_REVERS
    exporting
      !ES_DPL_LOG type ZTFI_CONT_REVERS .
  methods ATUALIZAR_DUPLICIDADE
    importing
      !IS_CONT_LOG type ZTFI_CONT_REVERS .
  methods GET_CENARIO_REV
    importing
      !IV_COD_CENARIO type ZE_COD_CENARIO
    exporting
      !EV_DESCRICAO type ZE_DESCRICAO .
  methods GET_TIPO_CENARIO_REV
    importing
      !IV_TP_CENARIO type ZE_TP_CENARIO
    exporting
      !EV_DESCRICAO type ZE_DESCRICAO .
  methods GET_ORDEM_REV
    importing
      !IV_ORDEM type ZE_COD_ORDEM
    exporting
      !EV_DESCRICAO type ZE_DESCRICAO .
  methods GET_PAGAMENTO_REV
    importing
      !IV_PAGAMENTO type ZE_COD_PAGMNT
    exporting
      !EV_DESCRICAO type ZE_DESCRICAO .
  methods GET_RESSARCIMENTO_REV
    importing
      !IV_RESSARCIMENTO type ZE_COD_RESSARCMNT
    exporting
      !EV_DESCRICAO type ZE_DESCRICAO .
  methods GET_MERCADORIA_REV
    importing
      !IV_MERCADORIA type ZE_COD_MERCADORIA
    exporting
      !EV_DESCRICAO type ZE_DESCRICAO .
  methods GET_CONFIG_CENARIOS
    importing
      !IV_CENARIO type ZE_COD_CENARIO
      !IV_TIPO_CENARIO type ZE_TP_CENARIO
      !IV_ORDEM type ZE_COD_ORDEM
      !IV_PAGAMENTO type ZE_COD_PAGMNT
      !IV_RESSARCIMENTO type ZE_COD_RESSARCMNT
      !IV_MERCADORIA type ZE_COD_MERCADORIA
      !IV_BUKRS type BUKRS
      !IV_BUPLA type BUPLA
    exporting
      !ES_CONFIG type ZTFI_ECM_CONFIG
      !ES_PARAMETRO type ZTFI_ECM_PARAMTR
      !EV_SUBRC type SY-SUBRC
      !EV_MSG type BAPI_MSG .
  methods GET_VLR_TAXA
    importing
      !IV_NSU type ZE_NSUTID
      !IV_ADM type ZE_NROADM
      !IV_DTVENDA type ZE_DATVEN
      !IV_BUKRS type BUKRS
      !IV_WERKS type BUPLA
    exporting
      !EV_VLR type ZE_VALOR_COMP
      !EV_LANCAR type FLAG
      !ES_ADM_TAX type ZTFI_ECM_ADM_TAX .
  methods INSERT_LOG
    importing
      !IS_LOG type ZTFI_CONT_REVERS
    exporting
      !EV_SUBRC type SY-SUBRC
      !EV_MSG type BAPI_MSG .
  methods ATUALIZAR_LCTO_PENDENTES .
  methods GET_CONFIG_CENARIO_FILHA
    importing
      !IV_NOME_MAE type ZE_NOME_IDENT
    exporting
      !ES_PARAMETRO type ZTFI_ECM_PARAMTR .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCLFI_ECOM IMPLEMENTATION.


  METHOD atualizar_duplicidade.

    MODIFY ztfi_cont_revers FROM is_cont_log.       "#EC CI_IMUD_NESTED

  ENDMETHOD.


  METHOD atualizar_lcto_pendentes.

    DATA: lt_cont_log  TYPE STANDARD TABLE OF ztfi_cont_revers,
          lt_cont_proc TYPE STANDARD TABLE OF ztfi_cont_revers.

    DATA: lv_dataini TYPE sy-datum,
          lv_subrc   TYPE sy-subrc,
          lv_msg     TYPE bapi_msg,
          lv_belnr   TYPE bseg-belnr,
          lv_gjahr   TYPE bseg-gjahr,
          lv_bukrs   TYPE bseg-bukrs.

    CONSTANTS: lc_status_pd TYPE ze_status_tax VALUE '2',
               lc_lanc_pd   TYPE char1         VALUE 'N'.

    lv_dataini = sy-datum - 45.

    SELECT *                                         "#EC CI_SEL_NESTED
      INTO TABLE lt_cont_log
      FROM ztfi_cont_revers
     WHERE data_i > lv_dataini.

    IF sy-subrc IS INITIAL.

      DATA(lt_cont_log_aux) = lt_cont_log[].
      FREE: lt_cont_log[].

      SORT lt_cont_log_aux BY status.

      LOOP AT lt_cont_log_aux ASSIGNING FIELD-SYMBOL(<fs_aux>).
        IF <fs_aux>-status EQ lc_status_pd.
          APPEND <fs_aux> TO lt_cont_log.
        ENDIF.
      ENDLOOP.

      FREE: lt_cont_log_aux[].

      SORT lt_cont_log BY data_i ASCENDING
                          hora_i ASCENDING.

      LOOP AT lt_cont_log ASSIGNING FIELD-SYMBOL(<fs_cont_log>).

        CLEAR: lv_subrc,
               lv_msg,
               lv_belnr,
               lv_gjahr,
               lv_bukrs.

        WAIT UP TO 1 SECONDS.

        CALL FUNCTION 'ZFMFI_CONTAB_REVERSA_PEND'
          EXPORTING
            iv_cenario        = <fs_cont_log>-cod_cenario
            iv_bukrs          = <fs_cont_log>-bukrs
            iv_bstkd          = <fs_cont_log>-bstkd
            iv_bupla          = <fs_cont_log>-bupla
            iv_zlsch          = <fs_cont_log>-zlsch
            iv_tipo_cenario   = <fs_cont_log>-cod_tipo_cenario
            iv_ordem          = <fs_cont_log>-cod_ordem
            iv_pagamento      = <fs_cont_log>-cod_pgto
            iv_ressarcimento  = <fs_cont_log>-cod_ressarcimento
            iv_mercadoria     = <fs_cont_log>-cod_mercadoria
            iv_ordem_venda    = <fs_cont_log>-vbeln
            iv_lifnr          = <fs_cont_log>-lifnr
            iv_voucher        = <fs_cont_log>-voucher
            iv_zvou           = <fs_cont_log>-zvou
            iv_vlr_restituir  = <fs_cont_log>-vlr_restituir
            iv_id_pedido      = <fs_cont_log>-id_pedido
            iv_adm            = <fs_cont_log>-adm
            iv_nsu            = <fs_cont_log>-nsu
            iv_dt_venda       = <fs_cont_log>-dt_venda
            iv_encerrar       = abap_true
            iv_lcto_pendente  = lc_lanc_pd
            iv_tx_perc        = <fs_cont_log>-tx_perc
            iv_id_sales_force = <fs_cont_log>-id_sales_force
            iv_reservado_1    = <fs_cont_log>-reservado_1
            iv_reservado_2    = <fs_cont_log>-reservado_2
            iv_reservado_3    = <fs_cont_log>-reservado_3
            iv_reservado_4    = <fs_cont_log>-reservado_4
            iv_reservado_5    = <fs_cont_log>-reservado_5
            iv_reservado_6    = <fs_cont_log>-reservado_6
            iv_reservado_7    = <fs_cont_log>-reservado_7
            iv_reservado_8    = <fs_cont_log>-reservado_8
            iv_reservado_9    = <fs_cont_log>-reservado_9
            iv_reservado_10   = <fs_cont_log>-reservado_10
          IMPORTING
            ev_subrc          = lv_subrc
            ev_msg            = lv_msg
            ev_belnr          = lv_belnr
            ev_gjahr          = lv_gjahr
            ev_bukrs          = lv_bukrs.

        IF lv_subrc IS INITIAL.

          WAIT UP TO 1 SECONDS.

          <fs_cont_log>-status  = '1'.
          <fs_cont_log>-belnr   = lv_belnr.
          <fs_cont_log>-gjahr   = lv_gjahr.
          <fs_cont_log>-bukrs_d = lv_bukrs.

          APPEND <fs_cont_log> TO lt_cont_proc.

        ENDIF.
      ENDLOOP.

      IF lt_cont_proc[] IS NOT INITIAL.
        MODIFY ztfi_cont_revers FROM TABLE lt_cont_proc. "#EC CI_IMUD_NESTED
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_duplicidade.

    SELECT *                                         "#EC CI_SEL_NESTED
      FROM ztfi_cont_revers UP TO 1 ROWS
      INTO es_dpl_log
     WHERE cod_cenario       = is_cont_log-cod_cenario
       AND bukrs             = is_cont_log-bukrs
       AND bstkd             = is_cont_log-bstkd
       AND bupla             = is_cont_log-bupla
       AND user_i            = is_cont_log-user_i
       AND id_pedido         = is_cont_log-id_pedido
       AND cod_tipo_cenario  = is_cont_log-cod_tipo_cenario
       AND cod_ordem         = is_cont_log-cod_ordem
       AND cod_pgto          = is_cont_log-cod_pgto
       AND cod_ressarcimento = is_cont_log-cod_ressarcimento
       AND cod_mercadoria    = is_cont_log-cod_mercadoria
       AND vbeln             = is_cont_log-vbeln
       AND lifnr             = is_cont_log-lifnr
       AND voucher           = is_cont_log-voucher
       AND adm               = is_cont_log-adm
       AND nsu               = is_cont_log-nsu
       AND dt_venda          = is_cont_log-dt_venda.
    ENDSELECT.

  ENDMETHOD.


  METHOD get_cenario_rev.

    CLEAR ev_descricao.

    SELECT SINGLE descricao                          "#EC CI_SEL_NESTED
      INTO ev_descricao
      FROM ztfi_ecm_cenar
     WHERE cod_cenario EQ iv_cod_cenario.

  ENDMETHOD.


  METHOD get_config_cenarios.

    CLEAR: es_config,
           es_parametro,
           ev_subrc,
           ev_msg.

    SELECT SINGLE *                                  "#EC CI_SEL_NESTED
      INTO es_config
      FROM ztfi_ecm_config
     WHERE bukrs EQ iv_bukrs
       AND bupla EQ iv_bupla.

    IF sy-subrc IS INITIAL.

      SELECT SINGLE *                                "#EC CI_SEL_NESTED
        INTO es_parametro
        FROM ztfi_ecm_paramtr
       WHERE cod_cenario       EQ iv_cenario
         AND cod_tipo_cenario  EQ iv_tipo_cenario
         AND cod_ordem         EQ iv_ordem
         AND cod_pgto          EQ iv_pagamento
         AND cod_ressarcimento EQ iv_ressarcimento
         AND cod_mercadoria    EQ iv_mercadoria
         AND cod_chave         EQ es_config-cod_chave.

      IF sy-subrc NE 0.

        ev_subrc = 4.
        MESSAGE e013(zfi_wevo) INTO ev_msg.

      ENDIF.

    ELSE.

      ev_subrc = 4.
      MESSAGE e014(zfi_wevo) INTO ev_msg.

    ENDIF.

  ENDMETHOD.


  METHOD get_config_cenario_filha.

    CLEAR es_parametro.

    SELECT SINGLE *                                  "#EC CI_SEL_NESTED
      INTO es_parametro
      FROM ztfi_ecm_paramtr
     WHERE nome_ident = iv_nome_mae.

  ENDMETHOD.


  METHOD get_mercadoria_rev.

    CLEAR ev_descricao.

    SELECT SINGLE descricao                           "#EC CI_SEL_NESTED
      INTO ev_descricao
      FROM ztfi_ecm_mercadr
     WHERE cod_mercadoria EQ iv_mercadoria.

  ENDMETHOD.


  METHOD get_ordem_rev.

    CLEAR ev_descricao.

    SELECT SINGLE descricao                          "#EC CI_SEL_NESTED
      INTO ev_descricao
      FROM ztfi_ecm_ordemsd
     WHERE cod_ordem EQ iv_ordem.

  ENDMETHOD.


  METHOD get_pagamento_rev.

    CLEAR ev_descricao.

    SELECT SINGLE descricao                          "#EC CI_SEL_NESTED
      INTO ev_descricao
      FROM ztfi_ecm_pagamnt
     WHERE cod_pgto EQ iv_pagamento.

  ENDMETHOD.


  METHOD get_ressarcimento_rev.

    CLEAR ev_descricao.

    SELECT SINGLE descricao                          "#EC CI_SEL_NESTED
      INTO ev_descricao
      FROM ztfi_ecm_ressarc
     WHERE cod_ressarcimento EQ iv_ressarcimento.

  ENDMETHOD.


  METHOD get_tipo_cenario_rev.

    CLEAR ev_descricao.

    SELECT SINGLE descricao                          "#EC CI_SEL_NESTED
      INTO ev_descricao
      FROM ztfi_ecm_tpcenar
     WHERE cod_tipo_cenario EQ iv_tp_cenario.

  ENDMETHOD.


  METHOD get_vlr_taxa.

    CLEAR: es_adm_tax,
           ev_vlr,
           ev_lancar.

    SELECT SINGLE *                                  "#EC CI_SEL_NESTED
      INTO es_adm_tax
      FROM ztfi_ecm_adm_tax
     WHERE adm EQ iv_adm.

    IF sy-subrc EQ 0.

      ev_lancar = abap_true.

      SELECT SINGLE valcom
        INTO ev_vlr
        FROM /ytc/cont303
       WHERE bukrs  EQ iv_bukrs
         AND werks  EQ iv_werks
         AND nroadm EQ iv_adm
         AND nsutid EQ iv_nsu
         AND datven EQ iv_dtvenda.

    ENDIF.

  ENDMETHOD.


  METHOD insert_log.

*    INSERT ztfi_cont_revers FROM is_log.            "#EC CI_IMUD_NESTED
    MODIFY ztfi_cont_revers FROM is_log.            "#EC CI_IMUD_NESTED

    ev_subrc = sy-subrc.

    IF ev_subrc EQ 0.
      MESSAGE s015(zfi_wevo) INTO ev_msg.
    ELSE.
      MESSAGE e016(zfi_wevo) INTO ev_msg.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
