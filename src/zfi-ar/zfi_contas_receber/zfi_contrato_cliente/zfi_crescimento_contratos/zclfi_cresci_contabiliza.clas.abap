CLASS zclfi_cresci_contabiliza DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS gc_prm_modulo TYPE ze_param_modulo VALUE 'FI-AR' ##NO_TEXT.
    CONSTANTS gc_chv_calcres TYPE ze_param_chave VALUE 'CONTRATOS' ##NO_TEXT.
    CONSTANTS gc_chv_ctrazao TYPE ze_param_chave VALUE 'CLIENTE_FAC12' ##NO_TEXT.
    CONSTANTS gc_chv_blart TYPE ze_param_chave VALUE 'CLIENTE_FAC11' ##NO_TEXT.

    TYPES: BEGIN OF typ_contab,
             bukrs       TYPE bukrs,
             gsber       TYPE gsber,
             region      TYPE bzirk,
             kostl       TYPE kostl,
             mont_valido TYPE ze_mont_valido,
             mont_fi     TYPE ze_mont_bonus,
             mont_copa   TYPE ze_mont_bonus,
           END OF typ_contab.

    DATA gs_contrato TYPE zi_fi_contrato_cliente.
    DATA gs_cont_key TYPE zsfi_contab_key.
    DATA gt_log_calc_cresc TYPE TABLE OF zi_fi_log_calc_crescimento.
    DATA gt_cresci_item TYPE STANDARD TABLE OF ztfi_calc_cresci.
    DATA gt_msg TYPE bapiret2_tab.
    DATA gt_contab TYPE TABLE OF typ_contab.
    DATA gt_cad_cc TYPE TABLE OF ztfi_cad_cc.

    METHODS process_contab
      IMPORTING  is_contrato TYPE zsfi_contab_key
      EXPORTING  ex_msg      TYPE bapiret2_tab
      EXCEPTIONS not_found_log
                 not_found_item.


  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS set_contrato
      IMPORTING
        is_contrato TYPE zsfi_contab_key.
    METHODS get_log_calc_cresc
      EXCEPTIONS not_found_log.
    METHODS get_calc_cresci_item
      EXCEPTIONS not_found_item.
    METHODS process_data.
    METHODS process_bapi
      IMPORTING is_log_crescimento TYPE zi_fi_log_calc_crescimento.
    METHODS fill_header
      IMPORTING is_log_crescimento TYPE zi_fi_log_calc_crescimento
      EXPORTING es_header          TYPE bapiache09.
    METHODS get_config_cc.
    METHODS process_value_cont.

ENDCLASS.



CLASS ZCLFI_CRESCI_CONTABILIZA IMPLEMENTATION.


  METHOD process_contab.

    set_contrato( is_contrato ).

    get_log_calc_cresc(
      EXCEPTIONS
        not_found_log = 1
        OTHERS        = 2
    ).
    IF sy-subrc <> 0.
      RAISE not_found_log.
    ENDIF.


    get_calc_cresci_item(
      EXCEPTIONS
        not_found_item = 1
        OTHERS         = 2
    ).
    IF sy-subrc <> 0.
      RAISE not_found_item.
    ENDIF.

    get_config_cc(  ).

    process_data(  ).

    ex_msg = gt_msg.

  ENDMETHOD.


  METHOD set_contrato.

    CLEAR: gs_contrato, gs_cont_key.

    gs_cont_key = is_contrato.

    SELECT *
      FROM zi_fi_contrato_cliente
     WHERE contrato = @is_contrato-contrato
       AND aditivo  = @is_contrato-aditivo
      INTO @gs_contrato
        UP TO 1 ROWS.
    ENDSELECT.

  ENDMETHOD.


  METHOD get_log_calc_cresc.

    SELECT *
      FROM zi_fi_log_calc_crescimento
     WHERE contrato = @gs_contrato-contrato
       AND aditivo  = @gs_contrato-aditivo
**       AND belnr = @space
      INTO TABLE @gt_log_calc_cresc.

  ENDMETHOD.


  METHOD get_calc_cresci_item.

    SELECT *
        FROM ztfi_calc_cresci
        FOR ALL ENTRIES IN @gt_log_calc_cresc
        WHERE contrato = @gt_log_calc_cresc-contrato
          AND aditivo = @gt_log_calc_cresc-aditivo
          AND exerc_atual = @gt_log_calc_cresc-exercatual
          AND exerc_anter = @gt_log_calc_cresc-exercanter
          AND ciclo = @gt_log_calc_cresc-ciclo
        INTO TABLE @gt_cresci_item.

  ENDMETHOD.


  METHOD process_data.

    DATA: lt_items_process TYPE TABLE OF ztfi_calc_cresci.
    DATA: ls_contab TYPE typ_contab.
    DATA: lv_valor TYPE ztfi_calc_cresci-mont_bonus.


    LOOP AT gt_log_calc_cresc ASSIGNING FIELD-SYMBOL(<fs_calc_cresci>).

      CLEAR: gt_contab.

      "Processa somente valores positivos no total
      IF <fs_calc_cresci>-bonuscalculado = 0 AND
         <fs_calc_cresci>-montbonus = 0.


        "Erro no lançamento da contabilização
        APPEND VALUE #( id = 'ZFI_BASE_CALCULO'
                        type = 'I'
                        number = 047
                        message_v1 = <fs_calc_cresci>-peridavaliado )  TO gt_msg.
      ELSE.


        LOOP AT gt_cresci_item ASSIGNING FIELD-SYMBOL(<fs_items_proc>)
                                WHERE exerc_atual = <fs_calc_cresci>-exercatual
                                  AND exerc_anter = <fs_calc_cresci>-exercanter
                                  AND ciclo = <fs_calc_cresci>-ciclo.


          CLEAR: lv_valor.
          IF <fs_items_proc>-bonus_calculado > 0.
            lv_valor = <fs_items_proc>-bonus_calculado.
          ELSE.
            lv_valor = <fs_items_proc>-mont_bonus.
          ENDIF.

          CLEAR: ls_contab.
          ls_contab = VALUE #( bukrs = <fs_items_proc>-bukrs
                               gsber = <fs_items_proc>-gsber
                               region = <fs_items_proc>-bzirk
                               mont_valido = lv_valor
                               mont_fi = lv_valor
                               mont_copa = lv_valor
                               ).

          "Devido a cenarios com erros, caso vazio preencher divisao padrao
          IF ls_contab-gsber IS INITIAL.
            ls_contab-gsber = '1000'.
          ENDIF.

          COLLECT ls_contab INTO gt_contab.

        ENDLOOP.

        process_value_cont(  ).

        process_bapi( <fs_calc_cresci> ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD process_bapi.

    CONSTANTS: lc_cres     TYPE char10     VALUE 'CRESC-',
               lc_cres_atr TYPE acpi_zuonr VALUE 'CRESCIMENTO',
               lc_moeda    TYPE waers      VALUE 'BRL',
               lc_40       TYPE acpi_kstaz VALUE 'S',
               lc_50       TYPE acpi_kstaz VALUE 'H',
               lc_error    TYPE sy-msgty   VALUE 'E'.

    DATA: lt_accountpayable TYPE STANDARD TABLE OF bapiacap09,
          lt_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
          lt_return         TYPE STANDARD TABLE OF bapiret2,
          lt_accountgl      TYPE STANDARD TABLE OF bapiacgl09.

    DATA: lv_item     TYPE posnr_acc,
          lv_obj_type TYPE bapiache09-obj_type,
          lv_obj_key  TYPE bapiache09-obj_key,
          lv_obj_sys  TYPE bapiache09-obj_sys.

    DATA: lr_craz40 TYPE RANGE OF saknr,
          lr_craz50 TYPE RANGE OF saknr.

    fill_header(
      EXPORTING
        is_log_crescimento = is_log_crescimento
      IMPORTING
        es_header = DATA(ls_header)
                   ).


    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = gc_prm_modulo
                                         iv_chave1 = 'CRESCIMENTO'
                                         iv_chave2 = 'CONTARAZAO40'
                               IMPORTING et_range  = lr_craz40 ).

      CATCH zcxca_tabela_parametros.
        RETURN.
    ENDTRY.

    DATA(ls_craz) = lr_craz40[ 1 ].

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = gc_prm_modulo
                                         iv_chave1 = 'CRESCIMENTO'
                                         iv_chave2 = 'CONTARAZAO50'
                               IMPORTING et_range  = lr_craz50 ).

      CATCH zcxca_tabela_parametros.
        RETURN.
    ENDTRY.

    DATA(ls_craz2) = lr_craz50[ 1 ].


    LOOP AT gt_contab ASSIGNING FIELD-SYMBOL(<fs_contab>).

      CHECK <fs_contab>-mont_fi > 0.

      READ TABLE gt_cad_cc ASSIGNING FIELD-SYMBOL(<fs_cad_cc>) WITH KEY
                                         bukrs = <fs_contab>-bukrs
                                         gsber = <fs_contab>-gsber
                                         region = <fs_contab>-region.
      IF sy-subrc = 0.

        SELECT SINGLE kostl, prctr
        FROM csks
        INTO @DATA(ls_csks)
        WHERE kostl = @<fs_cad_cc>-kostl
        AND datbi >= @sy-datum.

        lv_item = lv_item + 1.

        lt_accountgl = VALUE #( BASE lt_accountgl ( itemno_acc = lv_item
                                                    bus_area   = <fs_contab>-gsber
                                                    gl_account = ls_craz-low
                                                    alloc_nmbr = lc_cres_atr
                                                    item_text  = |{ lc_cres }{ gs_contrato-nomefantasia }|
                                                    costcenter = <fs_cad_cc>-kostl
                                                    profit_ctr = ls_csks-prctr
                                                    segment    = space ) ).
        lt_currencyamount = VALUE #( BASE lt_currencyamount ( itemno_acc = lv_item
                                                              currency   = lc_moeda
                                                              amt_doccur = <fs_contab>-mont_fi ) ).

        lv_item = lv_item + 1.

        lt_accountgl = VALUE #( BASE lt_accountgl ( itemno_acc = lv_item
                                                    bus_area   = <fs_contab>-gsber
                                                    gl_account = ls_craz2-low
                                                    alloc_nmbr = lc_cres_atr
                                                    item_text  = |{ lc_cres }{ gs_contrato-nomefantasia }|
                                                    costcenter = <fs_cad_cc>-kostl
                                                    profit_ctr = ls_csks-prctr
                                                    segment    = space ) ).

        lt_currencyamount = VALUE #( BASE lt_currencyamount ( itemno_acc = lv_item
                                                              currency   = lc_moeda
                                                              amt_doccur = <fs_contab>-mont_fi * -1 ) ).

      ELSE.
        "error.
        "Erro no lançamento da contabilização
        APPEND VALUE #( id = 'ZFI_BASE_CALCULO'
                               type = 'E'
                               number = 036 )  TO gt_msg.

        APPEND VALUE #( id = 'ZFI_BASE_CALCULO'
                        type = 'E'
                        number = 046
                        message_v1 = <fs_contab>-bukrs
                        message_v2 = <fs_contab>-gsber
                        message_v3 = <fs_contab>-region
                          ) TO gt_msg.

      ENDIF.

    ENDLOOP.

    LOOP AT lt_accountgl ASSIGNING FIELD-SYMBOL(<fs_accountgl>).
      IF <fs_accountgl>-gl_account(1) <> 3 AND
         <fs_accountgl>-gl_account(1) <> 4.

        CLEAR: <fs_accountgl>-costcenter.

      ENDIF.

    ENDLOOP.

    IF lt_accountgl[] IS NOT INITIAL.
      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader = ls_header
        IMPORTING
          obj_type       = lv_obj_type
          obj_key        = lv_obj_key
          obj_sys        = lv_obj_sys
        TABLES
          accountgl      = lt_accountgl
          currencyamount = lt_currencyamount
          return         = lt_return.

      IF line_exists( lt_return[ type = lc_error ] ).    "#EC CI_STDSEQ

        "Erro no lançamento da contabilização
        gt_msg = VALUE #( ( id = 'ZFI_BASE_CALCULO'
                               type = 'E'
                               number = 036 ) ).
        APPEND LINES OF lt_return TO gt_msg.

      ELSE.

        UPDATE ztfi_log_clcresc
            SET belnr = lv_obj_key(10)
                gjahr = lv_obj_key+14(4)
             WHERE contrato = is_log_crescimento-contrato
               AND aditivo = is_log_crescimento-aditivo
               AND ciclo = is_log_crescimento-ciclo
               AND exerc_atual = is_log_crescimento-exercatual
               AND exerc_anter = is_log_crescimento-exercanter.

        "Nº Doc. & Empresa & Exercício & Contabilizado com Sucesso
        APPEND VALUE #( id = 'ZFI_BASE_CALCULO'
                        type = 'S'
                        number = 037
                        message_v1 = lv_obj_key(10)
                        message_v2 = lv_obj_key+10(4)
                        message_v3 = lv_obj_key+14(4) ) TO gt_msg.

        CALL FUNCTION 'ZFMFI_CRESCI_CRAT_COPA'
          EXPORTING
            is_key    = is_log_crescimento
          IMPORTING
            et_return = lt_return.

        APPEND LINES OF lt_return TO gt_msg.

      ENDIF.
    ENDIF.



  ENDMETHOD.


  METHOD fill_header.

    DATA lr_blart  TYPE RANGE OF blart.

    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = gc_prm_modulo
                                         iv_chave1 = 'CRESCIMENTO'
                                         iv_chave2 = 'TIPODOC'
                                         iv_chave3 = 'LANCAR'
                               IMPORTING et_range  = lr_blart ).

      CATCH zcxca_tabela_parametros.
        RETURN.
    ENDTRY.

    DATA(ls_blart) = lr_blart[ 1 ].


    DATA lv_refdoc TYPE xblnr.

    IF gs_contrato-aditivo IS INITIAL.
      CONCATENATE 'CON' gs_contrato-contrato INTO lv_refdoc SEPARATED BY space.
    ELSE.
      CONCATENATE 'CON' gs_contrato-aditivo INTO lv_refdoc SEPARATED BY space.
    ENDIF.

    es_header = VALUE bapiache09( doc_date   = sy-datum
                                         pstng_date = gs_cont_key-budat_screen
*                                         pstng_date = sy-datum
                                         doc_type   = ls_blart-low
                                         comp_code  = gs_contrato-empresa
                                         fisc_year = gs_cont_key-budat_screen(4)
                                         fis_period = gs_cont_key-budat_screen+4(2)
                                         ref_doc_no = lv_refdoc
                                         username   = sy-uname
                                         header_txt = 'Periodo:' && is_log_crescimento-peridavaliado  ).

  ENDMETHOD.


  METHOD get_config_cc.

    SELECT *
    FROM ztfi_cad_cc
    INTO TABLE gt_cad_cc.

    SORT: gt_cad_cc BY bukrs gsber region.

  ENDMETHOD.


  METHOD process_value_cont.

    DATA: lv_valor_positivo TYPE ze_mont_valido,
          lv_valor_negativo TYPE ze_mont_valido,
          lv_valor_lancar   TYPE ze_mont_valido,
          lv_perc           TYPE ze_mont_valido.

    "Separar valores
    LOOP AT gt_contab ASSIGNING FIELD-SYMBOL(<fs_contab>).
      IF <fs_contab>-mont_valido > 0.
        lv_valor_positivo = lv_valor_positivo + <fs_contab>-mont_valido.
      ELSE.
        lv_valor_negativo = lv_valor_negativo + <fs_contab>-mont_valido.
      ENDIF.

      lv_valor_lancar = lv_valor_lancar + <fs_contab>-mont_valido.

    ENDLOOP.

    "Verifica se possui itens negativos para contabilizar
    IF lv_valor_negativo < 0 .

      LOOP AT gt_contab ASSIGNING <fs_contab>.

        CHECK <fs_contab>-mont_valido > 0.

        "Calcula o peso do agrupamento com o valor total a ser lancado
        lv_perc = <fs_contab>-mont_valido / lv_valor_positivo.

        <fs_contab>-mont_fi = lv_perc * lv_valor_lancar.

      ENDLOOP.

    ENDIF.


  ENDMETHOD.
ENDCLASS.
