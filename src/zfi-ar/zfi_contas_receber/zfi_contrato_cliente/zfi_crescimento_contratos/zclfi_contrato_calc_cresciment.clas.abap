CLASS zclfi_contrato_calc_cresciment DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS execute
      IMPORTING
        !is_import TYPE zsfi_key_crescimnt
      EXPORTING
        !et_return TYPE bapiret2_t .
    METHODS step3
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
      EXPORTING
        !et_periodos TYPE zctgfi_cresctr_periodos
        !et_return   TYPE bapiret2_t .


    DATA gv_gjahr_inicio TYPE bseg-gjahr.
    DATA gv_gjahr_fim TYPE bseg-gjahr.

    DATA gs_crescimento TYPE ztfi_cad_cresci.
    DATA gs_contrato    TYPE ztfi_contrato.
    DATA gv_contrato_msg TYPE char24.

    DATA gt_ciclo_process TYPE TABLE OF zsfi_cresc_ciclo_process.
    DATA gs_ciclo_process TYPE zsfi_cresc_ciclo_process.
    DATA gt_ciclo_de TYPE zctgfi_cresc_ciclo.
    DATA gt_ciclo_ate TYPE zctgfi_cresc_ciclo.

    DATA gt_doc_h_de TYPE TABLE OF zsfi_cresci_doc_h.
    DATA gt_familia TYPE TABLE OF ztfi_cresc_famil.
    DATA gt_doc_h_ate TYPE TABLE OF zsfi_cresci_doc_h.

    DATA gt_doc_h_tp_de TYPE TABLE OF zsfi_cresci_doc_h_tipo.
    DATA gt_doc_h_tp_ate TYPE TABLE OF zsfi_cresci_doc_h_tipo.

    DATA gt_doc_fdc_de TYPE zctgfi_cresctr_fdc.
    DATA gt_doc_fdc_ate TYPE zctgfi_cresctr_fdc.

    DATA gt_doc_bill_de TYPE zctgfi_cresctr_billing.
    DATA gt_doc_bill_ate TYPE zctgfi_cresctr_billing.

    DATA gt_base_comp TYPE TABLE OF ztfi_comp_cresci.

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS gc_prm_modulo TYPE ze_param_modulo VALUE 'FI-AR' ##NO_TEXT.
    CONSTANTS gc_chv_calcres TYPE ze_param_chave VALUE 'CONTRATOS' ##NO_TEXT.
    CONSTANTS gc_chv_tpdocs TYPE ze_param_chave VALUE 'CLIENTE_FAC9' ##NO_TEXT.
    CONSTANTS gc_chv_fac7 TYPE ze_param_chave VALUE 'CLIENTE_FAC7' ##NO_TEXT.
    CONSTANTS gc_msg_tp_e TYPE syst_msgty VALUE 'E' ##NO_TEXT.
    CONSTANTS gc_msg_id TYPE syst_msgid VALUE 'ZFI_BASE_CALCULO' ##NO_TEXT.
    CONSTANTS gc_msg_tp_s TYPE syst_msgty VALUE 'S' ##NO_TEXT.
    CONSTANTS gc_msg_suces_tx TYPE syst_msgno VALUE '010' ##NO_TEXT.
    CONSTANTS gc_msg_error_tx TYPE syst_msgno VALUE '011' ##NO_TEXT.
    CONSTANTS gc_msg_1 TYPE syst_msgno VALUE '012' ##NO_TEXT.
    CONSTANTS gc_msg_2 TYPE syst_msgno VALUE '013' ##NO_TEXT.
    CONSTANTS gc_msg_3 TYPE syst_msgno VALUE '014' ##NO_TEXT.
    CONSTANTS gc_msg_4 TYPE syst_msgno VALUE '015' ##NO_TEXT.
    CONSTANTS gc_msg_5 TYPE syst_msgno VALUE '016' ##NO_TEXT.
    CONSTANTS gc_msg_6 TYPE syst_msgno VALUE '016' ##NO_TEXT.
    CONSTANTS gc_msg_7 TYPE syst_msgno VALUE '018' ##NO_TEXT.
    CONSTANTS gc_msg_8 TYPE syst_msgno VALUE '019' ##NO_TEXT.
    CONSTANTS gc_msg_9 TYPE syst_msgno VALUE '020' ##NO_TEXT.
    CONSTANTS gc_msg_10 TYPE syst_msgno VALUE '021' ##NO_TEXT.
    CONSTANTS gc_msg_11 TYPE syst_msgno VALUE '022' ##NO_TEXT.
    CONSTANTS gc_msg_12 TYPE syst_msgno VALUE '023' ##NO_TEXT.

    METHODS step1
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
      EXPORTING
        !et_clientes TYPE zctgfi_cresctr_cliente
        !et_return   TYPE bapiret2_t .
    METHODS step2
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
      EXPORTING
        !et_return   TYPE bapiret2_t
      CHANGING
        !ct_clientes TYPE zctgfi_cresctr_cliente .
    METHODS step4
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
        it_clientes  TYPE zctgfi_cresctr_cliente
      EXPORTING
        !et_return   TYPE bapiret2_t .
    METHODS step5
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
      EXPORTING
        !ev_error    TYPE char1
        !et_return   TYPE bapiret2_t .
    METHODS step7
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
      EXPORTING
        !et_return   TYPE bapiret2_t .
    METHODS step8
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
      EXPORTING
        !et_return   TYPE bapiret2_t .
    METHODS step9
      IMPORTING
        !is_contrato     TYPE zsfi_key_crescimnt
      EXPORTING
        !et_tot_montante TYPE zctgfi_cresctr_impost
        !et_tot_item     TYPE zctgfi_cresc_valor_item
        !et_return       TYPE bapiret2_t
      CHANGING
        !ct_doc_fdc      TYPE zctgfi_cresctr_fdc
        !ct_documentos   TYPE zctgfi_cresctr_docs .
    METHODS step9_comp
      IMPORTING
        !is_contrato       TYPE zsfi_key_crescimnt
      EXPORTING
        !et_tot_comparacao TYPE zctgfi_cresctr_impost
        !et_return         TYPE bapiret2_t
      CHANGING
        !ct_doc_fdc        TYPE zctgfi_cresctr_fdc
        !ct_documentos     TYPE zctgfi_cresctr_docs .
    METHODS step10
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
        !it_doc_fdc  TYPE zctgfi_cresctr_fdc .
    METHODS step12_13
      IMPORTING
        !iv_perid_ant     TYPE gjahr OPTIONAL
        !is_contrato      TYPE zsfi_key_crescimnt
        !it_documentos    TYPE zctgfi_cresctr_docs
        !it_tot_montante  TYPE zctgfi_cresctr_impost
        !it_tot_item      TYPE zctgfi_cresc_valor_item
        !it_tot_item_comp TYPE zctgfi_cresc_valor_item
        !it_tot_mont_comp TYPE zctgfi_cresctr_impost OPTIONAL
        !it_doc_fdc       TYPE zctgfi_cresctr_fdc
        !it_billing_ref   TYPE zctgfi_cresctr_billing OPTIONAL
        !it_clientes      TYPE zctgfi_cresctr_cliente OPTIONAL
      EXPORTING
        !et_return        TYPE bapiret2_t .
    METHODS step_validation
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
      EXPORTING
        !et_return   TYPE bapiret2_t .
    METHODS get_contrato_cresc
      IMPORTING
        !is_contrato TYPE zsfi_key_crescimnt
      EXPORTING
        !et_return   TYPE bapiret2_t .
ENDCLASS.



CLASS ZCLFI_CONTRATO_CALC_CRESCIMENT IMPLEMENTATION.


  METHOD execute.

    DATA: lt_clientes      TYPE zctgfi_cresctr_cliente,
          lt_periodos      TYPE zctgfi_cresctr_periodos,
          lt_documentos	   TYPE zctgfi_cresctr_docs,
          lt_documen_comp  TYPE zctgfi_cresctr_docs,
          lt_billing_ref   TYPE zctgfi_cresctr_billing,
          lt_doc_fdc       TYPE zctgfi_cresctr_fdc,
          lt_doc_fdc_comp  TYPE zctgfi_cresctr_fdc,
          lt_tot_montante	 TYPE zctgfi_cresctr_impost,
          lt_valor_item	   TYPE zctgfi_cresc_valor_item,
          lt_tot_mont_comp TYPE zctgfi_cresctr_impost,
          lt_msg           TYPE bapiret2_t.

    DATA: ls_return      TYPE bapiret2.

    DATA: lv_perd_ant TYPE gjahr,
          lv_error    TYPE char1,
          lv_cont     TYPE char30.


    "Buscar dados contrato e crescimento
    me->get_contrato_cresc( EXPORTING is_contrato = is_import
                         IMPORTING et_return   = et_return ).

    CHECK et_return IS INITIAL.

    "Validações - Buscar exercicios de comparação
    me->step_validation( EXPORTING is_contrato = is_import
                         IMPORTING et_return   = et_return ).

    CHECK et_return IS INITIAL.

    me->step1( EXPORTING is_contrato = is_import
               IMPORTING et_clientes = lt_clientes
                         et_return   = et_return ).

    IF lt_clientes IS NOT INITIAL.

      me->step2( EXPORTING is_contrato = is_import
                 IMPORTING et_return   = et_return
                  CHANGING ct_clientes = lt_clientes ).

      IF lt_clientes IS NOT INITIAL.

        me->step3( EXPORTING is_contrato = is_import
                   IMPORTING et_periodos = lt_periodos
                             et_return   = et_return ).

        IF et_return[] IS NOT INITIAL.
          RETURN.
        ENDIF.

        me->step5( EXPORTING is_contrato = is_import
                   IMPORTING ev_error    = lv_error
                             et_return   = et_return ).

        IF et_return[] IS NOT INITIAL.
          RETURN.
        ENDIF.

        "Calculo realizado por ciclos
        CLEAR: gs_ciclo_process.
        LOOP AT gt_ciclo_process ASSIGNING FIELD-SYMBOL(<fs_ciclo_process>) .
          gs_ciclo_process = <fs_ciclo_process>.

          me->step4( EXPORTING is_contrato = is_import
                               it_clientes = lt_clientes
                     IMPORTING et_return   = et_return ).

          IF et_return[] IS NOT INITIAL.
            APPEND LINES OF et_return TO lt_msg.
            CLEAR: et_return.
            CONTINUE.
*            RETURN.
          ENDIF.

          me->step7( EXPORTING is_contrato = is_import
                     IMPORTING et_return   = et_return ).

          IF gt_doc_bill_ate[] IS INITIAL.
            CONTINUE.
          ENDIF.

          " Documentos do período e comparação
          me->step8( EXPORTING is_contrato = is_import
                     IMPORTING et_return   = et_return ).

          IF et_return[] IS NOT INITIAL.
            RETURN.
          ENDIF.

          " Total do documento do período
          CLEAR: lt_tot_montante, lt_valor_item.
          me->step9( EXPORTING is_contrato     = is_import
                     IMPORTING et_tot_montante = lt_tot_montante
                               et_return       = et_return
                               et_tot_item     = lt_valor_item
                      CHANGING ct_doc_fdc      = lt_doc_fdc
                               ct_documentos   = lt_documentos ).

          IF et_return[] IS NOT INITIAL.
            RETURN.
          ENDIF.

          " Total do documento de comparação
          CLEAR: lt_tot_mont_comp.
          me->step9_comp( EXPORTING is_contrato       = is_import
                          IMPORTING et_tot_comparacao = lt_tot_mont_comp
                                    et_return         = et_return
                           CHANGING ct_doc_fdc        = lt_doc_fdc_comp
                                    ct_documentos     = lt_documen_comp ).

          IF et_return[] IS NOT INITIAL.
            RETURN.
          ENDIF.

*          me->step10( EXPORTING is_contrato = is_import
*                                it_doc_fdc  = lt_doc_fdc ).

          me->step12_13( EXPORTING iv_perid_ant     = lv_perd_ant
                                   is_contrato      = is_import
                                   it_documentos    = lt_documentos
                                   it_tot_montante  = lt_tot_montante
                                   it_tot_item      = lt_valor_item
                                   it_tot_item_comp = lt_valor_item ">>>>>
                                   it_tot_mont_comp = lt_tot_mont_comp
                                   it_doc_fdc       = lt_doc_fdc
                                   it_billing_ref   = lt_billing_ref
                                   it_clientes = lt_clientes
                                   IMPORTING et_return        = et_return ).

        ENDLOOP.

      ENDIF.

      IF et_return[] IS INITIAL.

        IF is_import-aditivo IS NOT INITIAL.
          lv_cont = is_import-aditivo.
        ELSE.
          lv_cont = is_import-contrato.
        ENDIF.

        et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_s
                                              number     = gc_msg_suces_tx
                                              message_v1 = lv_cont )
                                            ( id         = gc_msg_id
                                              type       = gc_msg_tp_s
                                              number     = 006
                                              message_v1 = lv_cont ) ).
      ENDIF.
    ENDIF.


  ENDMETHOD.


  METHOD step1.

**    SELECT contrato,
**           aditivo,
**           cnpj_raiz,
**           cliente,
**           cnpj
**      FROM ztfi_cnpj_client
**     WHERE contrato = @is_contrato-contrato
**       AND aditivo  = @is_contrato-aditivo
**      INTO TABLE @et_clientes.

    SELECT contrato,
          aditivo,
          cnpjraiz,
          cliente,
          cnpj,
          classifcnpj
     FROM zi_fi_clientes_cont
    WHERE contrato = @is_contrato-contrato
      AND aditivo  = @is_contrato-aditivo
     INTO TABLE @et_clientes.


    IF sy-subrc IS INITIAL.
      SORT et_clientes BY contrato
                          aditivo.
    ELSE.

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = gv_contrato_msg ) ).

      " STEP 1 Buscar Clientes.
      et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                            type   = gc_msg_tp_e
                                            number = gc_msg_1 ) ).
    ENDIF.

  ENDMETHOD.


  METHOD step10.

    " Validação sendo realizada no STEP 12/13

    DATA: lr_zlsch TYPE RANGE OF bseg-zlsch.

    SELECT contrato,
           aditivo,
           tipoentrega AS tipo_entrega
      FROM zi_fi_contrato
     WHERE contrato = @is_contrato-contrato
       AND aditivo  = @is_contrato-aditivo
      INTO @DATA(ls_contrato)
        UP TO 1 ROWS.
    ENDSELECT.

    IF sy-subrc IS INITIAL.

      DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

      TRY.
          lo_param->m_get_range( EXPORTING iv_modulo = gc_prm_modulo
                                           iv_chave1 = 'CRESCIMENTO'
                                           iv_chave2 = 'FORMADEPGTO'
                                 IMPORTING et_range  = lr_zlsch ).

        CATCH zcxca_tabela_parametros.
          RETURN.
      ENDTRY.

      CASE ls_contrato-tipo_entrega.
        WHEN 'DDE'.

          SELECT bukrs,                         "#EC CI_FAE_NO_LINES_OK
                 belnr,
                 gjahr,
                 buzei,
                 zlsch
            FROM p_bseg_com
             FOR ALL ENTRIES IN @it_doc_fdc
           WHERE bukrs = @it_doc_fdc-bukrs
             AND belnr = @it_doc_fdc-belnr
             AND gjahr = @it_doc_fdc-gjahr
             AND buzei = @it_doc_fdc-buzei
             AND zlsch IN @lr_zlsch
            INTO TABLE @DATA(lt_bseg).

          IF sy-subrc IS INITIAL.

            DATA(lt_bseg_fae) = lt_bseg[].

            SORT lt_bseg_fae BY bukrs
                                belnr
                                gjahr.

            DELETE ADJACENT DUPLICATES FROM lt_bseg_fae COMPARING bukrs
                                                                  belnr
                                                                  gjahr.
            SELECT bukrs,
                   belnr,
                   gjahr,
                   xref1_hd
              FROM p_bkpf_com
               FOR ALL ENTRIES IN @lt_bseg_fae
             WHERE bukrs = @lt_bseg_fae-bukrs
               AND belnr = @lt_bseg_fae-belnr
               AND gjahr = @lt_bseg_fae-gjahr
              INTO TABLE @DATA(lt_bkpf).
            IF sy-subrc IS INITIAL.
              SORT lt_bkpf BY bukrs
                              belnr
                              gjahr.
            ENDIF.
          ENDIF.

        WHEN OTHERS.
      ENDCASE.

    ENDIF.

  ENDMETHOD.


  METHOD step12_13.

    DATA: lt_log       TYPE STANDARD TABLE OF ztfi_log_clcresc,
          lt_calc_cres TYPE STANDARD TABLE OF ztfi_calc_cresci.

    DATA: lv_timestamp           TYPE timestamp,
          lv_perd_ava            TYPE ze_perid_avaliad,
          lv_period_fin          TYPE numc2,
          lv_exer_ant            TYPE gjahr,
          lv_mont                TYPE ze_mont_pavaliad,
          lv_mont_comp           TYPE ze_mont_comparacao,
          lv_perc_bonus          TYPE ze_perc_bonus,
          lv_perc_cres           TYPE ze_perc_crescm,
          lv_mont_bonus          TYPE ze_mont_bonus,
          lv_mont_bonus_parcela  TYPE ze_mont_bonus,
          lv_count_bonus_parcela TYPE sy-index,
          lv_mont_cres           TYPE ze_mont_crescimento,
          lv_bonus_calc          TYPE ze_bonus_calcul,
          lv_total               TYPE kzwi1,
          lv_stt_dde             TYPE ze_status_dde,
          lv_cont                TYPE char30.

    SELECT contrato,
           aditivo,
           canal,
           tipoentrega AS tipo_entrega
      FROM zi_fi_contrato
     WHERE contrato = @is_contrato-contrato
       AND aditivo  = @is_contrato-aditivo
      INTO @DATA(ls_contrato)
        UP TO 1 ROWS.
    ENDSELECT.

    GET TIME STAMP FIELD lv_timestamp.

    WAIT UP TO 1 SECONDS.


    lv_period_fin = gs_ciclo_process-de_endda+4(2) .
    lv_perd_ava = |{ gs_ciclo_process-de_begda+4(2) }{ '/' }{ lv_period_fin } |.

    IF gs_crescimento-tipo_comparacao EQ 'BC'.
      CLEAR lv_exer_ant.
    ELSE.
      lv_exer_ant = iv_perid_ant.
    ENDIF.

    " Montante do Período
*    LOOP AT it_tot_montante ASSIGNING FIELD-SYMBOL(<fs_mont>).
    LOOP AT it_tot_item ASSIGNING FIELD-SYMBOL(<fs_mont>).
      lv_mont = lv_mont + <fs_mont>-total.
    ENDLOOP.

    " Montante de Comparação
    IF gs_crescimento-tipo_comparacao EQ 'PA'.

*      LOOP AT it_tot_mont_comp ASSIGNING FIELD-SYMBOL(<fs_mont_comp>).
      LOOP AT it_tot_item_comp ASSIGNING FIELD-SYMBOL(<fs_mont_comp>).
        lv_mont_comp = lv_mont_comp + <fs_mont_comp>-total.
      ENDLOOP.

    ELSE.

      READ TABLE gt_base_comp ASSIGNING FIELD-SYMBOL(<fs_base_com>)
                                            WITH KEY ciclos = gs_ciclo_process-ciclo
                                            BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lv_mont_comp = <fs_base_com>-mont_comp.
      ENDIF.
    ENDIF.

    " Montante de Crescimento
    lv_mont_cres = ( lv_mont - lv_mont_comp ).

    " Percentual de Crescimento
*    lv_perc_cres = ( lv_mont_comp * 100 ) / lv_mont.
*    lv_perc_cres = ( lv_mont_cres * 100 ) / lv_mont.
    lv_perc_cres = ( lv_mont_cres * 100 ) / lv_mont_comp.

    SELECT  *
      FROM ztfi_faixa_cresc
     WHERE doc_uuid_h = @is_contrato-doc_uuid_h
      INTO TABLE @DATA(lt_faixa).

    IF sy-subrc IS INITIAL.

      LOOP AT lt_faixa ASSIGNING FIELD-SYMBOL(<fs_faixa>).

        " Faixa de Porcentagem
        IF <fs_faixa>-cod_faixa IS NOT INITIAL
       AND ( <fs_faixa>-vlr_faixa_ini IS NOT INITIAL OR <fs_faixa>-vlr_faixa_fim IS NOT INITIAL ).

          CASE <fs_faixa>-cod_faixa.
              " Entre
            WHEN '1'.
              IF lv_perc_cres GE <fs_faixa>-vlr_faixa_ini
             AND lv_perc_cres LE <fs_faixa>-vlr_faixa_fim.
                lv_perc_bonus = <fs_faixa>-vlr_bonus_ini.
              ENDIF.

              " Igual
            WHEN '2'.
              IF lv_perc_cres EQ <fs_faixa>-vlr_faixa_ini.
                lv_perc_bonus = <fs_faixa>-vlr_bonus_ini.
              ENDIF.

              " Superior a
            WHEN '3'.
              IF lv_perc_cres GT <fs_faixa>-vlr_faixa_ini.
                lv_perc_bonus = <fs_faixa>-vlr_bonus_ini.
              ENDIF.

              " Superior a
            WHEN '4'.
              IF lv_perc_cres GE <fs_faixa>-vlr_faixa_ini.
                lv_perc_bonus = <fs_faixa>-vlr_bonus_ini.
              ENDIF.

              " Inferior a
            WHEN '5'.
              IF lv_perc_cres LT <fs_faixa>-vlr_faixa_ini.
                lv_perc_bonus = <fs_faixa>-vlr_bonus_ini.
              ENDIF.

              " Inferior ou Igual
            WHEN '6'.
              IF lv_perc_cres LE <fs_faixa>-vlr_faixa_ini.
                lv_perc_bonus = <fs_faixa>-vlr_bonus_ini.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.
        ENDIF.

        " Faixa de Montante
*        IF lv_mont_bonus IS INITIAL.
        IF <fs_faixa>-cod_montante IS NOT INITIAL
       AND ( <fs_faixa>-vlr_mont_ini IS NOT INITIAL OR <fs_faixa>-vlr_mont_fim IS NOT INITIAL ).

          CASE <fs_faixa>-cod_montante.

              " Entre
            WHEN '1'.
              IF lv_mont_cres GE <fs_faixa>-vlr_mont_ini
             AND lv_mont_cres LE <fs_faixa>-vlr_mont_fim.
                lv_mont_bonus = <fs_faixa>-vlr_montbonus_ini.
              ENDIF.

              " Igual
            WHEN '2'.
              IF lv_mont_cres EQ <fs_faixa>-vlr_mont_ini.
                lv_mont_bonus = <fs_faixa>-vlr_montbonus_ini.
              ENDIF.

              " Superior a
            WHEN '3'.
              IF lv_mont_cres GT <fs_faixa>-vlr_mont_ini.
                lv_mont_bonus = <fs_faixa>-vlr_montbonus_ini.
              ENDIF.

              " Superior ou Igual a
            WHEN '4'.
              IF lv_mont_cres GE <fs_faixa>-vlr_mont_ini.
                lv_mont_bonus = <fs_faixa>-vlr_montbonus_ini.
              ENDIF.

              " Inferior a
            WHEN '5'.
              IF lv_mont_cres LT <fs_faixa>-vlr_mont_ini.
                lv_mont_bonus = <fs_faixa>-vlr_montbonus_ini.
              ENDIF.

              " Inferior ou Igual
            WHEN '6'.
              IF lv_mont_cres LE <fs_faixa>-vlr_mont_ini.
                lv_mont_bonus = <fs_faixa>-vlr_montbonus_ini.
              ENDIF.
            WHEN OTHERS.
          ENDCASE.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lv_mont_bonus IS NOT INITIAL.
      lv_bonus_calc = lv_mont_bonus.
    ENDIF.

    IF lv_perc_bonus IS NOT INITIAL.
      lv_bonus_calc = ( lv_mont / 100 ) * lv_perc_bonus.
    ENDIF.

    IF lv_mont_cres < 1.
      CLEAR: lv_perc_cres, lv_perc_bonus, lv_mont_bonus, lv_bonus_calc.
    ENDIF.

    lt_log = VALUE #( BASE lt_log ( contrato         = is_contrato-contrato
                                    aditivo          = is_contrato-aditivo
                                    bukrs            = gs_contrato-bukrs
                                    ajuste_anual     = gs_crescimento-ajuste_anual
                                    ciclo            = gs_ciclo_process-ciclo
                                    exerc_atual      = gs_ciclo_process-ate_begda(4)
                                    exerc_anter      = gs_ciclo_process-de_begda(4)
                                    timestamp        = lv_timestamp
                                    canal            = ls_contrato-canal
                                    tipo_comparacao  = gs_crescimento-tipo_comparacao
                                    perid_avaliado   = lv_perd_ava
                                    mont_perid_aval  = lv_mont
                                    mont_comparacao  = lv_mont_comp
                                    mont_crescimento = lv_mont_cres
                                    perc_crescimento = lv_perc_cres
                                    perc_bonus       = lv_perc_bonus
                                    mont_bonus       = lv_mont_bonus
                                    bonus_calculado  = lv_bonus_calc
                                    created_by       = sy-uname
                                     ) ).

    IF gs_crescimento-tipo_comparacao = 'BC'.
      LOOP AT lt_log ASSIGNING FIELD-SYMBOL(<fs_log>).
        CLEAR: <fs_log>-exerc_anter.
      ENDLOOP.
    ENDIF.

    IF lt_log[] IS NOT INITIAL.
      MODIFY ztfi_log_clcresc FROM TABLE lt_log.
      FREE: lt_log[].
    ELSE.
      IF is_contrato-aditivo IS NOT INITIAL.
        lv_cont = is_contrato-aditivo.
      ELSE.
        lv_cont = is_contrato-contrato.
      ENDIF.

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = lv_cont ) ).

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_11 ) ).
    ENDIF.

    "**********************************************
    " STEP 13
    "**********************************************
    DATA(lt_doc_fdc_aux) = gt_doc_fdc_ate[].
    SORT lt_doc_fdc_aux BY bukrs
                           belnr
                           gjahr
                           buzei.

    DATA(lt_billing) = gt_doc_bill_ate[].
    FREE: lt_billing[].

    DATA(lt_billing_aux) = gt_doc_bill_ate[].
    FREE: lt_billing_aux[].

    DATA(lt_tot_montante_aux) = it_tot_montante[].
    SORT lt_tot_montante_aux BY vbeln.

    DATA(lt_tot_montante_item) = it_tot_item[].
    SORT lt_tot_montante_item BY vbeln item.

    IF lv_mont_bonus IS NOT INITIAL.
      lv_mont_bonus_parcela = lv_mont_bonus /  lines( it_tot_item ).
    ENDIF.

    IF gt_doc_fdc_ate[] IS NOT INITIAL.

      SELECT bukrs,                             "#EC CI_FAE_NO_LINES_OK
             gjahr,
             belnr,
             buzei,
             wrbtr,
             bschl,
             blart,
             zuonr,
             kunnr,
             zlsch,
             sgtxt,
             augbl,
             augdt,
             vbeln
        FROM bsid_view
         FOR ALL ENTRIES IN @gt_doc_fdc_ate
       WHERE bukrs = @gt_doc_fdc_ate-bukrs
         AND gjahr = @gt_doc_fdc_ate-gjahr
         AND belnr = @gt_doc_fdc_ate-belnr
         AND buzei = @gt_doc_fdc_ate-buzei
        INTO TABLE @DATA(lt_bsid).

      IF sy-subrc IS INITIAL.
        SORT lt_bsid BY bukrs
                        gjahr
                        belnr
                        buzei.
      ENDIF.


      SELECT bukrs,                             "#EC CI_FAE_NO_LINES_OK
           gjahr,
           belnr,
           buzei,
           wrbtr,
           bschl,
           blart,
           zuonr,
           kunnr,
           zlsch,
           sgtxt,
           augbl,
           augdt,
           vbeln
      FROM bsad_view
       FOR ALL ENTRIES IN @gt_doc_fdc_ate
     WHERE bukrs = @gt_doc_fdc_ate-bukrs
       AND gjahr = @gt_doc_fdc_ate-gjahr
       AND belnr = @gt_doc_fdc_ate-belnr
       AND buzei = @gt_doc_fdc_ate-buzei
      INTO TABLE @DATA(lt_bsad).

      IF sy-subrc IS INITIAL.
        SORT lt_bsad BY bukrs
                        gjahr
                        belnr
                        buzei.
      ENDIF.


      SELECT bukrs,                             "#EC CI_FAE_NO_LINES_OK
             belnr,
             gjahr,
             buzei,
             netdt
        FROM bseg
         FOR ALL ENTRIES IN @gt_doc_fdc_ate
       WHERE bukrs = @gt_doc_fdc_ate-bukrs
         AND gjahr = @gt_doc_fdc_ate-gjahr
         AND belnr = @gt_doc_fdc_ate-belnr
         AND buzei = @gt_doc_fdc_ate-buzei
        INTO TABLE @DATA(lt_bseg).

      IF sy-subrc IS INITIAL.
        SORT lt_bseg BY bukrs
                        gjahr
                        belnr
                        buzei.
      ENDIF.

      SELECT bukrs,                             "#EC CI_FAE_NO_LINES_OK
             belnr,
             gjahr,
             xblnr,
             budat,
             bldat,
             xref1_hd
        FROM p_bkpf_com
         FOR ALL ENTRIES IN @gt_doc_fdc_ate
       WHERE bukrs = @gt_doc_fdc_ate-bukrs
         AND gjahr = @gt_doc_fdc_ate-gjahr
         AND belnr = @gt_doc_fdc_ate-belnr
        INTO TABLE @DATA(lt_bkpf).

      IF sy-subrc IS INITIAL.
        SORT lt_bkpf BY bukrs
                        gjahr
                        belnr.
      ENDIF.

      SELECT billingdocument,                 "#EC CI_FAE_LINES_ENSURED
             distributionchannel,
             division,
             salesdistrict
        FROM i_billingdocumentbasic
         FOR ALL ENTRIES IN @gt_doc_fdc_ate
       WHERE billingdocument = @gt_doc_fdc_ate-vbeln
        INTO TABLE @DATA(lt_billing_basic).

      IF sy-subrc IS INITIAL.
        SORT lt_billing_basic BY billingdocument.
      ENDIF.

    ENDIF.

    IF gt_doc_bill_ate[] IS NOT INITIAL.
      SELECT billingdocument,                 "#EC CI_FAE_LINES_ENSURED
             billingdocumentitem,
             referencesddocument
        FROM i_billingdocumentitembasic
         FOR ALL ENTRIES IN @gt_doc_bill_ate
       WHERE billingdocument     = @gt_doc_bill_ate-vbeln
         AND billingdocumentitem = @gt_doc_bill_ate-posnr
        INTO TABLE @DATA(lt_billing_item).

      IF sy-subrc IS INITIAL.
        SORT lt_billing_item BY billingdocument
                                billingdocumentitem.
      ENDIF.
    ENDIF.

    SELECT contrato,
           aditivo,
           familia_cl,
           tipo_apuracao,
           tipo_ap_imposto,
           tipo_imposto,
           tipo_desconto,
           cond_desconto
      FROM ztfi_cad_provi
     WHERE contrato = @is_contrato-contrato
       AND aditivo  = @is_contrato-aditivo
      INTO @DATA(ls_cad_provi)
        UP TO 1 ROWS.
    ENDSELECT.

    SELECT contrato,
           aditivo,
           tipoentrega AS tipo_entrega
      FROM zi_fi_contrato
     WHERE contrato = @is_contrato-contrato
       AND aditivo  = @is_contrato-aditivo
      INTO @DATA(ls_ontrato1)
        UP TO 1 ROWS.
    ENDSELECT.

    DATA(lt_doc_h_tp) = gt_doc_fdc_ate[].

    SORT lt_doc_h_tp BY bukrs
                        gjahr
                        belnr.

    DELETE ADJACENT DUPLICATES FROM lt_doc_h_tp COMPARING bukrs
                                                          gjahr
                                                          belnr.

    DATA(lt_doc_bill_aux) = gt_doc_bill_ate[].

    SORT lt_doc_bill_aux BY vbeln
                            vkorg.

*    LOOP AT it_documentos ASSIGNING FIELD-SYMBOL(<fs_documents>).
    LOOP AT lt_doc_h_tp ASSIGNING FIELD-SYMBOL(<fs_documents>).

      READ TABLE lt_doc_fdc_aux TRANSPORTING NO FIELDS
                                              WITH KEY bukrs = <fs_documents>-bukrs
                                                       gjahr = <fs_documents>-gjahr
                                                       belnr = <fs_documents>-belnr
                                                       BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        LOOP AT lt_doc_fdc_aux ASSIGNING FIELD-SYMBOL(<fs_doc_fdc>) FROM sy-tabix. "#EC CI_NESTED
          IF <fs_doc_fdc>-bukrs NE <fs_documents>-bukrs
          OR <fs_doc_fdc>-gjahr NE <fs_documents>-gjahr
          OR <fs_doc_fdc>-belnr NE <fs_documents>-belnr.
            EXIT.
          ENDIF.

*          lt_billing[] = gt_doc_bill_ate[].

          FREE: lt_billing[].

          READ TABLE lt_doc_bill_aux TRANSPORTING NO FIELDS
                                                   WITH KEY vbeln = <fs_doc_fdc>-vbeln
                                                            vkorg = <fs_doc_fdc>-bukrs
                                                            BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            LOOP AT lt_doc_bill_aux ASSIGNING FIELD-SYMBOL(<fs_doc_bill>) FROM sy-tabix.
              IF <fs_doc_bill>-vbeln NE <fs_doc_fdc>-vbeln
              OR <fs_doc_bill>-vkorg NE <fs_doc_fdc>-bukrs.
                EXIT.
              ENDIF.

              APPEND <fs_doc_bill> TO lt_billing.

            ENDLOOP.
          ENDIF.

*          DELETE lt_billing WHERE vbeln NE <fs_doc_fdc>-vbeln "#EC CI_STDSEQ
*                              AND vkorg NE <fs_doc_fdc>-bukrs.

          lt_billing_aux[] = lt_billing[].

          LOOP AT lt_billing_aux ASSIGNING FIELD-SYMBOL(<fs_aux>). "#EC CI_NESTED
            <fs_aux>-prctr = <fs_aux>-prctr(2).
          ENDLOOP.

          SORT lt_billing_aux BY prctr                 "#EC CI_SORTLOOP
                                 gsber.

          DELETE ADJACENT DUPLICATES FROM lt_billing_aux COMPARING prctr
                                                                   gsber.

          DATA(lv_lines) = lines( lt_billing_aux ).

          READ TABLE lt_tot_montante_aux ASSIGNING FIELD-SYMBOL(<fs_tot>)
                                                       WITH KEY vbeln = <fs_doc_fdc>-vbeln
                                                       BINARY SEARCH.
          IF sy-subrc IS INITIAL
             AND lv_lines IS NOT INITIAL.
            lv_total = <fs_tot>-total / lv_lines.
          ELSE.
            CLEAR lv_total.
          ENDIF.



          LOOP AT lt_billing ASSIGNING FIELD-SYMBOL(<fs_billing_proc>). "#EC CI_NESTED

            IF gt_familia IS NOT INITIAL.
              READ TABLE gt_familia TRANSPORTING NO FIELDS
                                                      WITH KEY familia_cl = <fs_billing_proc>-prctr(2)
                                                      BINARY SEARCH.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF.

            ENDIF.

            READ TABLE lt_tot_montante_item ASSIGNING FIELD-SYMBOL(<fs_tot_item>)
                                                     WITH KEY vbeln = <fs_billing_proc>-vbeln
                                                              item = <fs_billing_proc>-posnr
                                                     BINARY SEARCH.

            READ TABLE lt_bsid INTO DATA(ls_bsid)
                                WITH KEY bukrs = <fs_doc_fdc>-bukrs
                                         gjahr = <fs_doc_fdc>-gjahr
                                         belnr = <fs_doc_fdc>-belnr
                                         buzei = <fs_doc_fdc>-buzei
                                         BINARY SEARCH.
            IF sy-subrc IS NOT INITIAL.

              READ TABLE lt_bsad INTO ls_bsid
                                WITH KEY bukrs = <fs_doc_fdc>-bukrs
                                         gjahr = <fs_doc_fdc>-gjahr
                                         belnr = <fs_doc_fdc>-belnr
                                         buzei = <fs_doc_fdc>-buzei
                                         BINARY SEARCH.
              IF sy-subrc IS NOT INITIAL.
                CLEAR ls_bsid.
              ENDIF.
            ENDIF.

            READ TABLE lt_bseg INTO DATA(ls_bseg)
                                WITH KEY bukrs = <fs_doc_fdc>-bukrs
                                         gjahr = <fs_doc_fdc>-gjahr
                                         belnr = <fs_doc_fdc>-belnr
                                         buzei = <fs_doc_fdc>-buzei
                                         BINARY SEARCH.
            IF sy-subrc IS NOT INITIAL.
              CLEAR ls_bseg.
            ENDIF.

            READ TABLE lt_bkpf INTO DATA(ls_bkpf)
                                WITH KEY bukrs = <fs_doc_fdc>-bukrs
                                         gjahr = <fs_doc_fdc>-gjahr
                                         belnr = <fs_doc_fdc>-belnr
                                         BINARY SEARCH.
            IF sy-subrc IS NOT INITIAL.
              CLEAR ls_bkpf.
            ENDIF.

            READ TABLE lt_billing_basic INTO DATA(ls_billing_basic)
                                         WITH KEY billingdocument = <fs_billing_proc>-vbeln
                                         BINARY SEARCH.
            IF sy-subrc IS NOT INITIAL.
              CLEAR ls_billing_basic.
            ENDIF.

            READ TABLE lt_billing_item INTO DATA(ls_billing_item)
                                        WITH KEY billingdocument     = <fs_billing_proc>-vbeln
                                                 billingdocumentitem = <fs_billing_proc>-posnr
                                                 BINARY SEARCH.
            IF sy-subrc IS NOT INITIAL.
              CLEAR ls_billing_item.
            ENDIF.

            READ TABLE it_clientes INTO DATA(ls_cnpj)
                                    WITH KEY contrato = is_contrato-contrato
                                             aditivo  = is_contrato-aditivo
                                             BINARY SEARCH.
            IF sy-subrc IS NOT INITIAL.
              CLEAR ls_cnpj.
            ENDIF.

            IF ls_contrato-tipo_entrega EQ 'DDE'.
              IF ls_bkpf-xref1_hd(2) EQ 'DDE'.
                lv_stt_dde = 'E'.
              ELSE.
                lv_stt_dde = 'P'.
              ENDIF.
            ELSE.
              CLEAR lv_stt_dde.
            ENDIF.

            IF <fs_tot>-total < 0.
              ls_bsid-wrbtr = ls_bsid-wrbtr * -1.
            ENDIF.

            "Calcular valor de montante bonus para cada item
            IF lv_mont_bonus IS NOT INITIAL.
              lv_count_bonus_parcela = lines( it_tot_item ) - lines( lt_calc_cres ).
              IF lv_count_bonus_parcela = 1.
                lv_mont_bonus_parcela = lv_mont_bonus.
              ELSE.
                lv_mont_bonus = lv_mont_bonus - lv_mont_bonus_parcela .
              ENDIF.
            ENDIF.


            lt_calc_cres = VALUE #( BASE lt_calc_cres ( contrato         = is_contrato-contrato
                                                        aditivo          = is_contrato-aditivo
                                                        bukrs            = gs_contrato-bukrs
                                                        belnr            = <fs_doc_fdc>-belnr
                                                        gjahr            = <fs_doc_fdc>-gjahr
                                                        buzei            = <fs_doc_fdc>-buzei
                                                        ajuste_anual     = gs_crescimento-ajuste_anual
                                                        ciclo            = gs_ciclo_process-ciclo
                                                        exerc_atual      = gs_ciclo_process-ate_begda(4)
                                                        exerc_anter      = gs_ciclo_process-de_begda(4)
                                                        gsber            = <fs_billing_proc>-gsber
                                                        familia_cl       = <fs_billing_proc>-prctr(2)
                                                        tipo_comparacao  = gs_crescimento-tipo_comparacao
                                                        tipo_ap_imposto  = gs_crescimento-tipo_ap_imposto
                                                        tipo_apuracao  = gs_crescimento-tipo_ap_devoluc
                                                        perid_avaliado   = lv_perd_ava
                                                        wrbtr            = ls_bsid-wrbtr
                                                        bschl            = ls_bsid-bschl
                                                        blart            = ls_bsid-blart
                                                        zuonr            = ls_bsid-zuonr
                                                        kunnr            = ls_bsid-kunnr
                                                        zlsch            = ls_bsid-zlsch
                                                        sgtxt            = ls_bsid-sgtxt
                                                        netdt            = ls_bseg-netdt
                                                        xblnr            = ls_bkpf-xblnr
                                                        budat            = ls_bkpf-budat
                                                        bldat            = ls_bkpf-bldat
                                                        augbl            = ls_bsid-augbl
                                                        augdt            = ls_bsid-augdt
                                                        vbeln            = ls_bsid-vbeln
                                                        posnr            = <fs_billing_proc>-posnr
                                                        vgbel            = ls_billing_item-referencesddocument
                                                        vtweg            = ls_billing_basic-distributionchannel
                                                        spart            = ls_billing_basic-division
                                                        bzirk            = ls_billing_basic-salesdistrict
                                                        katr2            = ls_cnpj-classifcnpj
                                                        wwmt1            = ls_cad_provi-familia_cl
                                                        prctr            = <fs_billing_proc>-prctr
                                                        tipo_entrega     = ls_ontrato1-tipo_entrega
                                                        xref1_hd         = ls_bkpf-xref1_hd
                                                        status_dde       = lv_stt_dde
                                                        tipo_imposto     = ls_cad_provi-tipo_imposto
                                                        impost_desconsid = <fs_tot>-mont_descons
*                                                        mont_liq_tax     = <fs_tot>-total
                                                        mont_liq_tax     = <fs_tot_item>-total
*                                                        mont_valido      = <fs_tot>-total
                                                        mont_valido      = <fs_tot_item>-total
                                                        tipo_desconto    = ls_cad_provi-tipo_desconto
                                                        cond_desconto    = ls_cad_provi-cond_desconto
                                                        kostl            = ''
                                                        mont_bonus       = lv_mont_bonus_parcela
                                                        bonus_calculado  = <fs_tot_item>-total * ( lv_perc_bonus / 100 )
                                                        created_by       = sy-uname
                                                        created_at       = lv_timestamp ) ).



          ENDLOOP.

        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF gs_crescimento-tipo_comparacao = 'BC'.
      LOOP AT lt_calc_cres ASSIGNING FIELD-SYMBOL(<fs_calc_cres_i>).
        CLEAR: <fs_calc_cres_i>-exerc_anter.
      ENDLOOP.
    ENDIF.

    IF lt_calc_cres[] IS NOT INITIAL.
      MODIFY ztfi_calc_cresci FROM TABLE lt_calc_cres.
      FREE: lt_calc_cres[].

      SELECT docuuidh
        FROM zi_fi_contrato
       WHERE contrato = @is_contrato-contrato
         AND aditivo  = @is_contrato-aditivo
        INTO @DATA(lv_uidh)
        UP TO 1 ROWS.
      ENDSELECT.

      IF sy-subrc IS INITIAL.

        SELECT SINGLE *
          FROM ztfi_contrato
         WHERE doc_uuid_h = @lv_uidh
          INTO @DATA(ls_contrt).

        IF sy-subrc IS INITIAL.
          ls_contrt-crescimento = abap_true.
          MODIFY ztfi_contrato FROM ls_contrt.
        ENDIF.
      ENDIF.

    ELSE.
      IF is_contrato-aditivo IS NOT INITIAL.
        lv_cont = is_contrato-aditivo.
      ELSE.
        lv_cont = is_contrato-contrato.
      ENDIF.

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = lv_cont ) ).

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_12 ) ).

    ENDIF.

  ENDMETHOD.


  METHOD step2.

    DATA: lr_forma_desc TYPE RANGE OF ztfi_cad_cresci-forma_descont.

    CONSTANTS: lc_msg_nb  TYPE syst_msgno VALUE '007',
               lc_msg_040 TYPE syst_msgno VALUE '040',
               lc_msg_041 TYPE syst_msgno VALUE '041',
               lc_msg_042 TYPE syst_msgno VALUE '041'.

    lr_forma_desc = VALUE #( ( sign = 'I' option = 'EQ' low = '5'  )
                             ( sign = 'I' option = 'EQ' low = '6'  )
                             ( sign = 'I' option = 'EQ' low = '7'  ) ).

    IF gs_crescimento-flag_td_atribut IS INITIAL.

      SELECT kunnr,                             "#EC CI_FAE_NO_LINES_OK
             katr2
        FROM fndei_kna1_filter
         FOR ALL ENTRIES IN @ct_clientes
       WHERE kunnr = @ct_clientes-cliente
        INTO TABLE @DATA(lt_kna1).

      IF sy-subrc IS INITIAL.

        SORT lt_kna1 BY kunnr.

        LOOP AT ct_clientes ASSIGNING FIELD-SYMBOL(<fs_clientes>).
          READ TABLE lt_kna1 ASSIGNING FIELD-SYMBOL(<fs_kna1>)
                                           WITH KEY kunnr = <fs_clientes>-cliente
                                           BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            IF gs_crescimento-classific_cnpj NE <fs_kna1>-katr2.
              DELETE ct_clientes.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF gs_contrato-desativado = abap_true.

      FREE ct_clientes[].

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = lc_msg_040
                                            message_v1 = gv_contrato_msg ) ).

      et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                            type   = gc_msg_tp_e
                                            number = gc_msg_2 ) ).

    ELSEIF gs_contrato-data_fim_valid < sy-datum.

      FREE ct_clientes[].

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = lc_msg_041
                                            message_v1 = gv_contrato_msg ) ).

      et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                            type   = gc_msg_tp_e
                                            number = gc_msg_2 ) ).

    ELSEIF gs_crescimento-forma_descont IN lr_forma_desc.

      FREE ct_clientes[].

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = lc_msg_042
                                            message_v1 = gv_contrato_msg ) ).

      et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                            type   = gc_msg_tp_e
                                            number = gc_msg_2 ) ).

    ENDIF.

    IF ct_clientes[] IS INITIAL.

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = gv_contrato_msg ) ).

      et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                            type   = gc_msg_tp_e
                                            number = gc_msg_2 ) ).
    ENDIF.

  ENDMETHOD.


  METHOD step3.

    DATA: lv_erro  TYPE boolean.
    DATA: lr_ciclo_del TYPE RANGE OF ze_ciclobasecomp.

    CLEAR: gt_ciclo_de, gt_ciclo_ate, lv_erro, lr_ciclo_del.

    CALL FUNCTION 'ZFMFI_CRESCIMENTO_CICLO'
      EXPORTING
        iv_contrato        = gs_contrato-contrato
        iv_aditivo         = gs_contrato-aditivo
        iv_exercicio       = gv_gjahr_inicio
      IMPORTING
        et_ciclos          = gt_ciclo_de
      EXCEPTIONS
        contrato_not_found = 1
        aditivo_not_found  = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
      lv_erro = abap_true.
    ENDIF.

    CALL FUNCTION 'ZFMFI_CRESCIMENTO_CICLO'
      EXPORTING
        iv_contrato        = gs_contrato-contrato
        iv_aditivo         = gs_contrato-aditivo
        iv_exercicio       = gv_gjahr_fim
      IMPORTING
        et_ciclos          = gt_ciclo_ate
      EXCEPTIONS
        contrato_not_found = 1
        aditivo_not_found  = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
      lv_erro = abap_true.
    ENDIF.

    SORT gt_ciclo_ate BY ciclo.

    " Validar se o ciclo existe em de/até para comparar.
    " Buscar somente ciclos fechados / Data < sy-datum
    IF lv_erro IS INITIAL.

      LOOP AT gt_ciclo_de ASSIGNING FIELD-SYMBOL(<fs_ciclo>).

        READ TABLE gt_ciclo_ate ASSIGNING FIELD-SYMBOL(<fs_ciclo_ate>)
                                              WITH KEY ciclo = <fs_ciclo>-ciclo
                                              BINARY SEARCH.

        IF sy-subrc <> 0.
          APPEND INITIAL LINE TO lr_ciclo_del ASSIGNING FIELD-SYMBOL(<fs_ciclo_del>).
          <fs_ciclo_del>-sign   = 'I'.
          <fs_ciclo_del>-option = 'EQ'.
          <fs_ciclo_del>-low    = <fs_ciclo>-ciclo.
        ELSE.
          APPEND INITIAL LINE TO gt_ciclo_process ASSIGNING FIELD-SYMBOL(<fs_ciclo_proc>).
          <fs_ciclo_proc>-ciclo     = <fs_ciclo>-ciclo.
          <fs_ciclo_proc>-de_begda  = <fs_ciclo>-begda.
          <fs_ciclo_proc>-de_endda  = <fs_ciclo>-endda.
          <fs_ciclo_proc>-ate_begda = <fs_ciclo_ate>-begda.
          <fs_ciclo_proc>-ate_endda = <fs_ciclo_ate>-endda.
        ENDIF.
      ENDLOOP.

      IF lr_ciclo_del IS NOT INITIAL.
        DELETE gt_ciclo_de WHERE ciclo IN lr_ciclo_del.
      ENDIF.
    ENDIF.

    IF gt_ciclo_ate IS INITIAL
    OR gt_ciclo_de IS INITIAL.
      lv_erro = abap_true.
    ELSE.
      SORT: gt_ciclo_process BY ciclo,
            gt_ciclo_de      BY ciclo,
            gt_ciclo_ate     BY ciclo.
    ENDIF.

    IF lv_erro IS NOT INITIAL.
      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = gv_contrato_msg ) ).

      et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                            type   = gc_msg_tp_e
                                            number = gc_msg_3 ) ).
      RETURN.
    ENDIF.


  ENDMETHOD.


  METHOD step4.

    TYPES: BEGIN OF ty_doc,
             bukrs TYPE bseg-bukrs,
             belnr TYPE bseg-belnr,
             gjahr TYPE bseg-gjahr,
             augbl TYPE bseg-augbl,
             bschl TYPE bseg-bschl,
             blart TYPE bkpf-blart,
             budat TYPE bkpf-budat,
             monat TYPE bkpf-monat,
           END OF ty_doc.

    DATA: lt_bkpf  TYPE TABLE OF ty_doc,
          lt_bkpf2 TYPE TABLE OF ty_doc.

    CONSTANTS lc_msg_45 TYPE sy-msgno VALUE '045'.

    DATA: lr_tp_docs TYPE RANGE OF bkpf-blart,
          lr_budat   TYPE RANGE OF bkpf-budat.

    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.
        lo_param->m_get_range( EXPORTING iv_modulo = gc_prm_modulo
                                         iv_chave1 = 'CRESCIMENTO'
                                         iv_chave2 = 'TIPODOC'
                               IMPORTING et_range  = lr_tp_docs ).

      CATCH zcxca_tabela_parametros.

        et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_e
                                              number     = gc_msg_error_tx
                                              message_v1 = gv_contrato_msg ) ).

        " Parâmetros tipo de documentos do crescimento não cadastrado
        et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_e
                                              number     = lc_msg_45 ) ).

        RETURN.

    ENDTRY.

    CLEAR: gt_doc_h_de, gt_doc_h_ate.

    " Busca os documento pelos ciclos DE
    CLEAR: lr_budat.

    lr_budat = VALUE #( (  sign   = 'I'
                           option = 'BT'
                           low    = gs_ciclo_process-de_begda
                           high   = gs_ciclo_process-de_endda ) ).

    DATA(lt_clientes_fae) = it_clientes[].
    SORT lt_clientes_fae BY cliente.
    DELETE ADJACENT DUPLICATES FROM lt_clientes_fae COMPARING cliente.

    FREE: lt_bkpf[].
    IF lt_clientes_fae[] IS NOT INITIAL.
      SELECT a~bukrs,
             a~belnr,
             a~gjahr,
             b~augbl,
             b~bschl,
             a~blart,
             a~budat,
             a~monat
        FROM p_bkpf_com AS a
       INNER JOIN bsid_view AS b ON a~bukrs = b~bukrs
                                AND a~belnr = b~belnr
                                AND a~gjahr = b~gjahr
         FOR ALL ENTRIES IN @lt_clientes_fae
       WHERE a~bukrs EQ @gs_contrato-bukrs
         AND a~blart IN @lr_tp_docs
         AND a~budat IN @lr_budat
         AND b~kunnr = @lt_clientes_fae-cliente
*           AND gjahr EQ @it_periodos-exercicio
*           AND monat EQ @it_periodos-mes
        INTO TABLE @lt_bkpf.

      SELECT a~bukrs,
             a~belnr,
             a~gjahr,
             b~augbl,
             b~bschl,
             a~blart,
             a~budat,
             a~monat
        FROM p_bkpf_com AS a
       INNER JOIN bsad_view AS b ON a~bukrs = b~bukrs
                                AND a~belnr = b~belnr
                                AND a~gjahr = b~gjahr
         FOR ALL ENTRIES IN @lt_clientes_fae
       WHERE a~bukrs EQ @gs_contrato-bukrs
         AND a~blart IN @lr_tp_docs
         AND a~budat IN @lr_budat
         AND b~kunnr = @lt_clientes_fae-cliente
*                   AND gjahr EQ @it_periodos-exercicio
*                   AND monat EQ @it_periodos-mes
          APPENDING TABLE @lt_bkpf.
    ENDIF.


    LOOP AT lt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>).

      "Permitir doc RB com chave 12
      IF <fs_bkpf>-belnr = <fs_bkpf>-augbl.
        IF <fs_bkpf>-blart <> 'RB'.
          CONTINUE.
        ELSE.
          IF <fs_bkpf>-bschl <> '12'.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND INITIAL LINE TO gt_doc_h_de ASSIGNING FIELD-SYMBOL(<fs_doc_h_de>).
      MOVE-CORRESPONDING <fs_bkpf> TO <fs_doc_h_de>.
      <fs_doc_h_de>-ciclo = gs_ciclo_process-ciclo.
    ENDLOOP.

    " Busca os documento pelos ciclos ATE
    CLEAR: lr_budat.

    lr_budat = VALUE #( (  sign   = 'I'
                           option = 'BT'
                           low    = gs_ciclo_process-ate_begda
                           high   = gs_ciclo_process-ate_endda ) ).

    FREE: lt_bkpf2.
    IF lt_clientes_fae[] IS NOT INITIAL.
      SELECT a~bukrs,
             a~belnr,
             a~gjahr,
             b~augbl,
             b~bschl,
             a~blart,
             a~budat,
             a~monat
        FROM p_bkpf_com AS a
       INNER JOIN bsid_view AS b ON a~bukrs = b~bukrs
                                AND a~belnr = b~belnr
                                AND a~gjahr = b~gjahr
         FOR ALL ENTRIES IN @lt_clientes_fae
       WHERE a~bukrs EQ @gs_contrato-bukrs
         AND a~blart IN @lr_tp_docs
         AND a~budat IN @lr_budat
         AND b~kunnr = @lt_clientes_fae-cliente
*                   AND gjahr EQ @it_periodos-exercicio
*                   AND monat EQ @it_periodos-mes
        INTO TABLE @lt_bkpf2.

      SELECT a~bukrs,
             a~belnr,
             a~gjahr,
             b~augbl,
             b~bschl,
             a~blart,
             a~budat,
             a~monat
        FROM p_bkpf_com AS a
       INNER JOIN bsad_view AS b ON a~bukrs = b~bukrs
                                AND a~belnr = b~belnr
                                AND a~gjahr = b~gjahr
         FOR ALL ENTRIES IN @lt_clientes_fae
       WHERE a~bukrs EQ @gs_contrato-bukrs
         AND a~blart IN @lr_tp_docs
         AND a~budat IN @lr_budat
         AND b~kunnr = @lt_clientes_fae-cliente
*                   AND gjahr EQ @it_periodos-exercicio
*                   AND monat EQ @it_periodos-mes
          APPENDING TABLE @lt_bkpf2.
    ENDIF.

    LOOP AT lt_bkpf2 ASSIGNING FIELD-SYMBOL(<fs_bkpf2>).

      "Permitir doc RV com chave 12
      IF <fs_bkpf2>-belnr = <fs_bkpf2>-augbl.
        IF <fs_bkpf2>-blart <> 'RB'.
          CONTINUE.
        ELSE.
          IF <fs_bkpf2>-bschl <> '12'.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND INITIAL LINE TO gt_doc_h_ate ASSIGNING FIELD-SYMBOL(<fs_doc_h_ate>).
      MOVE-CORRESPONDING <fs_bkpf2> TO <fs_doc_h_ate>.
      <fs_doc_h_ate>-ciclo = gs_ciclo_process-ciclo.
    ENDLOOP.

    IF ( gs_crescimento-tipo_comparacao EQ 'BC' AND
         gt_doc_h_ate IS INITIAL )
    OR ( gs_crescimento-tipo_comparacao NE 'BC' AND
         ( gt_doc_h_de IS INITIAL OR gt_doc_h_ate IS INITIAL ) ).

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = gv_contrato_msg ) ).

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_4 ) ).
    ENDIF.

  ENDMETHOD.


  METHOD step5.

    DATA: lv_mes   TYPE ze_ini_periodic,
          lv_gjahr TYPE gjahr.

    CONSTANTS: lc_bcomp  TYPE ze_tp_comparacao VALUE 'BC',
               lc_pante  TYPE ze_tp_comparacao VALUE 'PA',
               lc_msg_ci TYPE syst_msgno       VALUE '008'.

    CHECK gs_crescimento-tipo_comparacao IS NOT INITIAL.

    IF gs_crescimento-tipo_comparacao EQ lc_bcomp.

      SELECT *
        FROM ztfi_comp_cresci
        INTO TABLE gt_base_comp
       WHERE doc_uuid_h = gs_contrato-doc_uuid_h.

      IF sy-subrc <> 0.

        ev_error = abap_true.
        et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_e
                                              number     = gc_msg_error_tx
                                              message_v1 = gv_contrato_msg ) ).

        et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_e
                                              number     = gc_msg_5 ) ).

      ELSE.

        SORT gt_base_comp BY ciclos.

      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD step7.

    TYPES: BEGIN OF ty_doc_step7,
             bukrs TYPE bseg-bukrs,
             gjahr TYPE bseg-gjahr,
             belnr TYPE bseg-belnr,
             buzei TYPE bseg-buzei,
             vbeln TYPE bseg-vbeln,
           END OF ty_doc_step7.

    DATA: lt_bsid_de  TYPE TABLE OF ty_doc_step7,
          lt_bsid_ate TYPE TABLE OF ty_doc_step7.

    DATA: lv_continue TYPE char1,
          lv_gsber    TYPE gsber,
          lv_vbeln    TYPE vbeln_vf.

    CONSTANTS: lc_numb TYPE sy-msgno VALUE '009'.

    " Verifica se possui cadastro de familia para filtro
    CLEAR: gt_familia.
    SELECT *
      FROM ztfi_cresc_famil
      INTO TABLE @gt_familia
     WHERE doc_uuid_h = @gs_contrato-doc_uuid_h.

    IF sy-subrc IS INITIAL.
      SORT gt_familia BY familia_cl.
    ENDIF.

    " Documento DE
    IF gt_doc_h_de IS NOT INITIAL.

      CLEAR: lt_bsid_de.
      SELECT bukrs,                                     "#EC CI_SEL_DEL
             gjahr,
             belnr,
             buzei,
             vbeln
        FROM bsid_view
         FOR ALL ENTRIES IN @gt_doc_h_de
       WHERE bukrs = @gt_doc_h_de-bukrs
         AND gjahr = @gt_doc_h_de-gjahr
         AND belnr = @gt_doc_h_de-belnr
        INTO TABLE @lt_bsid_de.

      SELECT bukrs,                                     "#EC CI_SEL_DEL
            gjahr,
            belnr,
            buzei,
            vbeln
       FROM bsad_view
        FOR ALL ENTRIES IN @gt_doc_h_de
      WHERE bukrs = @gt_doc_h_de-bukrs
        AND gjahr = @gt_doc_h_de-gjahr
        AND belnr = @gt_doc_h_de-belnr
       APPENDING TABLE @lt_bsid_de.

      IF sy-subrc IS INITIAL.

        SORT lt_bsid_de BY bukrs
                           gjahr
                           belnr
                           vbeln.

        DELETE ADJACENT DUPLICATES FROM lt_bsid_de COMPARING bukrs
                                                             gjahr
                                                             belnr
                                                             vbeln.
        SORT lt_bsid_de BY bukrs
                           gjahr
                           belnr.

        SELECT billingdocument,
               billingdocumentitem,
               profitcenter,
               salesordersalesorganization,
               businessarea,
               subtotal1amount,
               subtotal2amount,
               subtotal3amount,
               subtotal4amount,
               subtotal5amount
          FROM i_billingdocumentitembasic
           FOR ALL ENTRIES IN @lt_bsid_de
         WHERE billingdocument             = @lt_bsid_de-vbeln
           AND salesordersalesorganization = @lt_bsid_de-bukrs
           AND businessarea <> @space
          INTO TABLE @gt_doc_bill_de.

        SORT gt_doc_bill_de BY vbeln
                               vkorg.

        IF gt_familia[] IS NOT INITIAL.
          LOOP AT lt_bsid_de ASSIGNING FIELD-SYMBOL(<fs_bsig_de>).

*            READ TABLE gt_doc_bill_de ASSIGNING FIELD-SYMBOL(<fs_billing_de>)
*                                                    WITH KEY vbeln = <fs_bsig_de>-vbeln
*                                                             vkorg = <fs_bsig_de>-bukrs
*                                                             BINARY SEARCH.
            LOOP AT gt_doc_bill_de ASSIGNING FIELD-SYMBOL(<fs_billing_de>) WHERE vbeln = <fs_bsig_de>-vbeln
                                                                            AND vkorg = <fs_bsig_de>-bukrs.

              READ TABLE gt_familia TRANSPORTING NO FIELDS
                                                WITH KEY familia_cl = <fs_billing_de>-prctr(2)
                                                BINARY SEARCH.
              IF sy-subrc <> 0.
**                DELETE gt_doc_h_de WHERE belnr = <fs_bsig_de>-belnr.
                DELETE gt_doc_bill_de WHERE vbeln = <fs_billing_de>-vbeln
                                         AND posnr = <fs_billing_de>-posnr .
              ENDIF.

            ENDLOOP.
          ENDLOOP.
        ENDIF.

        IF gt_doc_h_de    IS INITIAL
        OR gt_doc_bill_de IS INITIAL.
          et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_e
                                              number     = gc_msg_error_tx
                                              message_v1 = gv_contrato_msg ) ).

          et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                                type   = gc_msg_tp_e
                                                number = gc_msg_7 ) ).
        ENDIF.
      ENDIF.
    ENDIF.

    " Documento ATÉ
    IF gt_doc_h_ate IS NOT INITIAL.

      CLEAR: lt_bsid_ate.
      SELECT bukrs,                                     "#EC CI_SEL_DEL
             gjahr,
             belnr,
             buzei,
             vbeln
        FROM bsid_view
         FOR ALL ENTRIES IN @gt_doc_h_ate
       WHERE bukrs = @gt_doc_h_ate-bukrs
         AND gjahr = @gt_doc_h_ate-gjahr
         AND belnr = @gt_doc_h_ate-belnr
        INTO TABLE @lt_bsid_ate.

      SELECT bukrs,                                     "#EC CI_SEL_DEL
             gjahr,
             belnr,
             buzei,
             vbeln
        FROM bsad_view
         FOR ALL ENTRIES IN @gt_doc_h_ate
       WHERE bukrs = @gt_doc_h_ate-bukrs
         AND gjahr = @gt_doc_h_ate-gjahr
         AND belnr = @gt_doc_h_ate-belnr
        APPENDING TABLE @lt_bsid_ate.

      SORT lt_bsid_ate BY bukrs
                          gjahr
                          belnr
                          vbeln.

      DELETE ADJACENT DUPLICATES FROM lt_bsid_ate COMPARING bukrs
                                                            gjahr
                                                            belnr
                                                            vbeln.
      SORT lt_bsid_ate BY bukrs
                          gjahr
                          belnr.

      IF lt_bsid_ate[] IS NOT INITIAL.

        SELECT billingdocument,
               billingdocumentitem,
               profitcenter,
               salesordersalesorganization,
               businessarea,
               subtotal1amount,
               subtotal2amount,
               subtotal3amount,
               subtotal4amount,
               subtotal5amount
          FROM i_billingdocumentitembasic
           FOR ALL ENTRIES IN @lt_bsid_ate
         WHERE billingdocument             = @lt_bsid_ate-vbeln
           AND salesordersalesorganization = @lt_bsid_ate-bukrs
           AND businessarea <> @space
          INTO TABLE @gt_doc_bill_ate.

        IF sy-subrc IS INITIAL.

          SORT gt_doc_bill_ate BY vbeln
                                  vkorg.

          IF gt_familia[] IS NOT INITIAL.
            LOOP AT lt_bsid_ate ASSIGNING FIELD-SYMBOL(<fs_bsig_ate>).

*              READ TABLE gt_doc_bill_ate ASSIGNING FIELD-SYMBOL(<fs_billing_ate>)
*                                                       WITH KEY vbeln = <fs_bsig_ate>-vbeln
*                                                                vkorg = <fs_bsig_ate>-bukrs
*                                                                BINARY SEARCH.

              LOOP AT gt_doc_bill_ate ASSIGNING FIELD-SYMBOL(<fs_billing_ate>) WHERE vbeln = <fs_bsig_ate>-vbeln
                                                                                 AND vkorg = <fs_bsig_ate>-bukrs.

                READ TABLE gt_familia TRANSPORTING NO FIELDS
                                                  WITH KEY familia_cl = <fs_billing_ate>-prctr(2)
                                                  BINARY SEARCH.
                IF sy-subrc <> 0.
**                  DELETE gt_doc_h_ate WHERE belnr = <fs_bsig_ate>-belnr.
                  DELETE gt_doc_bill_ate WHERE vbeln = <fs_billing_ate>-vbeln
                                            AND posnr = <fs_billing_ate>-posnr.
                ENDIF.

              ENDLOOP.
            ENDLOOP.
          ENDIF.

          IF gs_crescimento-tipo_comparacao = 'PA'.

            IF gt_doc_h_ate    IS INITIAL
            OR gt_doc_bill_ate IS INITIAL.
              et_return = VALUE #( BASE et_return ( id       = gc_msg_id
                                                  type       = gc_msg_tp_e
                                                  number     = gc_msg_error_tx
                                                  message_v1 = gv_contrato_msg ) ).

              et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                                    type   = gc_msg_tp_e
                                                    number = gc_msg_7 ) ).
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

**    CHECK ct_documentos IS NOT INITIAL.
**
**    SELECT bukrs,                                       "#EC CI_SEL_DEL
**           gjahr,
**           belnr,
**           buzei,
**           vbeln
**      FROM bsid_view
**       FOR ALL ENTRIES IN @ct_documentos
**     WHERE bukrs = @ct_documentos-bukrs
**       AND gjahr = @ct_documentos-gjahr
**       AND belnr = @ct_documentos-belnr
**      INTO TABLE @DATA(lt_bsid).
**
**    IF sy-subrc IS INITIAL.
**
**      SORT lt_bsid BY bukrs
**                      gjahr
**                      belnr
**                      vbeln.
**
**      DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING bukrs
**                                                        gjahr
**                                                        belnr
**                                                        vbeln.
**      SORT lt_bsid BY bukrs
**                      gjahr
**                      belnr.
**
**      SELECT billingdocument,
**             billingdocumentitem,
**             profitcenter,
**             salesordersalesorganization,
**             businessarea,
**             subtotal1amount,
**             subtotal2amount,
**             subtotal3amount,
**             subtotal4amount,
**             subtotal5amount
**        FROM i_billingdocumentitembasic
**         FOR ALL ENTRIES IN @lt_bsid
**       WHERE billingdocument             = @lt_bsid-vbeln
**         AND salesordersalesorganization = @lt_bsid-bukrs
**        INTO TABLE @DATA(lt_billing).
**
**      IF sy-subrc IS INITIAL.
**
**        DATA(lt_bsid_trt) = lt_bsid[].
**        SORT lt_bsid_trt BY vbeln.
**
**        DATA(lt_billing_trt) = lt_billing[].
**        SORT lt_billing_trt BY billingdocument.
**
**        LOOP AT lt_billing ASSIGNING FIELD-SYMBOL(<fs_billing>).
**
**          IF <fs_billing>-billingdocument EQ lv_vbeln.
**
**            IF lv_gsber NE <fs_billing>-businessarea.
**
**              READ TABLE lt_bsid_trt ASSIGNING FIELD-SYMBOL(<fs_bsid>)
**                                                   WITH KEY vbeln = <fs_billing>-billingdocument
**                                                   BINARY SEARCH.
**              IF sy-subrc IS INITIAL.
**                et_return = VALUE #( BASE et_return ( id         = gc_msg_id
**                                                      type       = gc_msg_tp_e
**                                                      number     = lc_numb
**                                                      message_v1 = <fs_bsid>-belnr
**                                                      message_v2 = <fs_bsid>-bukrs
**                                                      message_v3 = <fs_bsid>-gjahr ) ).
**
**                DELETE lt_billing_trt WHERE billingdocument = <fs_billing>-billingdocument. "#EC CI_STDSEQ
**                DELETE ct_documentos WHERE belnr = <fs_bsid>-belnr. "#EC CI_STDSEQ
**              ENDIF.
**
**              CONTINUE.
**            ENDIF.
**
**          ELSE.
**
**            lv_vbeln = <fs_billing>-billingdocument.
**            lv_gsber = <fs_billing>-businessarea.
**
**          ENDIF.
**        ENDLOOP.
**
**        lt_billing[] = lt_billing_trt[].
**
**        SORT lt_billing BY billingdocument
**                           salesordersalesorganization.
**
***        IF is_crescimento-familia_cl IS NOT INITIAL.  "Melhoria 264 - Flavia Nunes - 30.05.2022
**
**        DATA(lt_billing_aux) = lt_billing[].
**        CLEAR lt_billing_aux[].
**
***Melhoria 264 - Flavia Nunes - 30.05.2022 - Início
***          LOOP AT lt_billing ASSIGNING <fs_billing>.
***            IF <fs_billing>-profitcenter(2) EQ is_crescimento-familia_cl.
***              APPEND <fs_billing> TO lt_billing_aux.
***            ENDIF.
***          ENDLOOP.
**
***        SELECT familia_cl, contrato, aditivo
***          FROM ztfi_cresc_famil
***          INTO TABLE @DATA(lt_famil)
***          WHERE contrato = @is_contrato-contrato
***            AND aditivo  = @is_contrato-aditivo.
**        IF sy-subrc IS INITIAL.
**          SORT lt_famil BY familia_cl.
**
**          LOOP AT lt_billing ASSIGNING <fs_billing>.
**            READ TABLE lt_famil ASSIGNING FIELD-SYMBOL(<fs_famil>) WITH KEY familia_cl = <fs_billing>-profitcenter(2)
**                                                                            BINARY SEARCH.
**            IF <fs_famil> IS ASSIGNED.
**
**              APPEND <fs_billing> TO lt_billing_aux.
**
**            ENDIF.
**          ENDLOOP.
***Melhoria 264 - Flavia Nunes - 30.05.2022 - Fim
**
**          lt_billing[] = lt_billing_aux[].
**
**          IF lt_billing[] IS NOT INITIAL.
**
**            DATA(lt_documentos_aux) = ct_documentos[].
**            FREE: lt_documentos_aux[].
**
**            LOOP AT ct_documentos ASSIGNING FIELD-SYMBOL(<fs_documentos>).
**
**              READ TABLE lt_bsid TRANSPORTING NO FIELDS WITH KEY bukrs = <fs_documentos>-bukrs
**                                                                 gjahr = <fs_documentos>-gjahr
**                                                                 belnr = <fs_documentos>-belnr
**                                                                 BINARY SEARCH.
**              IF sy-subrc IS INITIAL.
**                LOOP AT lt_bsid ASSIGNING <fs_bsid> FROM sy-tabix. "#EC CI_NESTED
**                  IF <fs_bsid>-bukrs NE <fs_documentos>-bukrs
**                  OR <fs_bsid>-gjahr NE <fs_documentos>-gjahr
**                  OR <fs_bsid>-belnr NE <fs_documentos>-belnr.
**                    EXIT.
**                  ENDIF.
**
**                  READ TABLE lt_billing TRANSPORTING NO FIELDS WITH KEY billingdocument             = <fs_bsid>-vbeln
**                                                                        salesordersalesorganization = <fs_bsid>-bukrs
**                                                                        BINARY SEARCH.
**                  IF sy-subrc IS INITIAL.
**
**                    LOOP AT lt_billing ASSIGNING <fs_billing> FROM sy-tabix. "#EC CI_NESTED
**                      IF <fs_billing>-billingdocument             NE <fs_bsid>-vbeln
**                      OR <fs_billing>-salesordersalesorganization NE <fs_bsid>-bukrs.
**                        EXIT.
**                      ENDIF.
**
**                      APPEND <fs_documentos> TO lt_documentos_aux.
**                      lv_continue = abap_true.
**                      CONTINUE.
**                    ENDLOOP.
**                  ENDIF.
**
**                  IF lv_continue IS NOT INITIAL.
**                    CLEAR lv_continue.
**                    CONTINUE.
**                  ENDIF.
**
**                ENDLOOP.
**              ENDIF.
**            ENDLOOP.
**
**            ct_documentos[] = lt_documentos_aux[].
**            et_billing_ref[] = lt_billing[].
**
**          ELSE.
**
**            IF is_contrato-aditivo IS NOT INITIAL.
**              lv_cont = is_contrato-aditivo.
**            ELSE.
**              lv_cont = is_contrato-contrato.
**            ENDIF.
**
**            et_return = VALUE #( BASE et_return ( id         = gc_msg_id
**                                                  type       = gc_msg_tp_e
**                                                  number     = gc_msg_error_tx
**                                                  message_v1 = lv_cont ) ).
**
**            et_return = VALUE #( BASE et_return ( id         = gc_msg_id
**                                                  type       = gc_msg_tp_e
**                                                  number     = gc_msg_7 ) ).
**
**            FREE: ct_documentos[].
**            RETURN.
**          ENDIF.
**
**        ELSE.
**          et_billing_ref[] = lt_billing[].
**        ENDIF.
**      ENDIF.
**    ENDIF.
**
**    IF ct_documentos[] IS INITIAL.
**
**      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
**                                            type       = gc_msg_tp_e
**                                            number     = gc_msg_error_tx
**                                            message_v1 = gv_contrato_msg ) ).
**
**      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
**                                            type       = gc_msg_tp_e
**                                            number     = gc_msg_7 ) ).
**    ENDIF.

  ENDMETHOD.


  METHOD step8.

    DATA: lr_bschl TYPE RANGE OF bschl.

    DATA: lv_cont TYPE char30.

    CONSTANTS: lc_sign   TYPE char1 VALUE 'I',
               lc_option TYPE char2 VALUE 'EQ',
               lc_dev    TYPE bschl VALUE '11',
               lc_fat    TYPE bschl VALUE '01',
               lc_canc   TYPE bschl VALUE '12'.

    IF gt_doc_h_de[] IS NOT INITIAL.

      lr_bschl = VALUE #( sign = lc_sign  option = lc_option ( low = lc_dev )
                                                             ( low = lc_fat )
                                                             ( low = lc_canc ) ).

      SELECT bukrs,
             gjahr,
             belnr,
             buzei,
             blart,
             vbeln,
             bschl,
             shkzg
        FROM bsid_view
         FOR ALL ENTRIES IN @gt_doc_h_de
       WHERE bukrs = @gt_doc_h_de-bukrs
         AND gjahr = @gt_doc_h_de-gjahr
         AND belnr = @gt_doc_h_de-belnr
         AND bschl IN @lr_bschl
        INTO TABLE @gt_doc_fdc_de.

      SELECT bukrs,
             gjahr,
             belnr,
             buzei,
             blart,
             vbeln,
             bschl,
             shkzg
        FROM bsad_view
         FOR ALL ENTRIES IN @gt_doc_h_de
       WHERE bukrs = @gt_doc_h_de-bukrs
         AND gjahr = @gt_doc_h_de-gjahr
         AND belnr = @gt_doc_h_de-belnr
         AND bschl IN @lr_bschl
        APPENDING TABLE @gt_doc_fdc_de.

      IF gt_doc_fdc_de IS INITIAL.

        et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_e
                                              number     = gc_msg_error_tx
                                              message_v1 = gv_contrato_msg ) ).

        et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                              type   = gc_msg_tp_e
                                              number = gc_msg_8 ) ).
      ENDIF.
    ENDIF.

    IF gt_doc_h_ate[] IS NOT INITIAL.

      lr_bschl = VALUE #( sign = lc_sign  option = lc_option ( low = lc_dev )
                                                             ( low = lc_fat )
                                                             ( low = lc_canc ) ).

      SELECT bukrs,
             gjahr,
             belnr,
             buzei,
             blart,
             vbeln,
             bschl,
             shkzg
        FROM bsid_view
         FOR ALL ENTRIES IN @gt_doc_h_ate
       WHERE bukrs = @gt_doc_h_ate-bukrs
         AND gjahr = @gt_doc_h_ate-gjahr
         AND belnr = @gt_doc_h_ate-belnr
         AND bschl IN @lr_bschl
        INTO TABLE @gt_doc_fdc_ate.

      SELECT bukrs,
             gjahr,
             belnr,
             buzei,
             blart,
             vbeln,
             bschl,
             shkzg
        FROM bsad_view
         FOR ALL ENTRIES IN @gt_doc_h_ate
       WHERE bukrs = @gt_doc_h_ate-bukrs
         AND gjahr = @gt_doc_h_ate-gjahr
         AND belnr = @gt_doc_h_ate-belnr
         AND bschl IN @lr_bschl
        APPENDING TABLE @gt_doc_fdc_ate.

      IF gt_doc_fdc_ate IS INITIAL.

        et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_e
                                              number     = gc_msg_error_tx
                                              message_v1 = gv_contrato_msg ) ).

        et_return = VALUE #( BASE et_return ( id     = gc_msg_id
                                              type   = gc_msg_tp_e
                                              number = gc_msg_8 ) ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD step9.

    FIELD-SYMBOLS: <fs_tipo> LIKE LINE OF gt_doc_h_tp_de.


    DATA: lv_inverter_valor TYPE boolean,
          lv_moeda_ext      TYPE boolean.
    DATA: ls_total      TYPE zsfi_cresctr_impost,
          ls_total_item TYPE zsfi_cresc_valor_item.

    DATA lt_doc_delete_tp_ap_dev TYPE zctgfi_cresctr_fdc.

    SORT gt_doc_h_ate BY bukrs
                         gjahr
                         belnr.

    LOOP AT gt_doc_fdc_ate ASSIGNING FIELD-SYMBOL(<fs_fdc>).

      CASE gs_crescimento-tipo_ap_devoluc.
        WHEN 'L'.
          IF <fs_fdc>-bschl = '01'
          OR <fs_fdc>-bschl = '11'.

            READ TABLE gt_doc_h_ate TRANSPORTING NO FIELDS
                                                   WITH KEY bukrs = <fs_fdc>-bukrs
                                                            gjahr = <fs_fdc>-gjahr
                                                            belnr = <fs_fdc>-belnr
                                                            BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              LOOP AT gt_doc_h_ate ASSIGNING FIELD-SYMBOL(<fs_documentos>) FROM sy-tabix. "#EC CI_NESTED
                IF <fs_documentos>-bukrs NE <fs_fdc>-bukrs
                OR <fs_documentos>-gjahr NE <fs_fdc>-gjahr
                OR <fs_documentos>-belnr NE <fs_fdc>-belnr.
                  EXIT.
                ENDIF.

                APPEND INITIAL LINE TO gt_doc_h_tp_ate ASSIGNING <fs_tipo>.
                MOVE-CORRESPONDING <fs_documentos> TO <fs_tipo>.
                <fs_tipo>-tipo = 'D'. "Devolução

              ENDLOOP.
            ENDIF.
          ENDIF.

        WHEN 'B'.

          IF <fs_fdc>-bschl = '01'
           AND <fs_fdc>-shkzg = 'S'. " Débito

            READ TABLE gt_doc_h_ate TRANSPORTING NO FIELDS
                                                   WITH KEY bukrs = <fs_fdc>-bukrs
                                                            gjahr = <fs_fdc>-gjahr
                                                            belnr = <fs_fdc>-belnr
                                                            BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              LOOP AT gt_doc_h_ate ASSIGNING <fs_documentos> FROM sy-tabix. "#EC CI_NESTED
                IF <fs_documentos>-bukrs NE <fs_fdc>-bukrs
                OR <fs_documentos>-gjahr NE <fs_fdc>-gjahr
                OR <fs_documentos>-belnr NE <fs_fdc>-belnr.
                  EXIT.
                ENDIF.

                APPEND INITIAL LINE TO gt_doc_h_tp_ate ASSIGNING <fs_tipo>.
                MOVE-CORRESPONDING <fs_documentos> TO <fs_tipo>.
                <fs_tipo>-tipo = 'D'. "Devolução

              ENDLOOP.
            ENDIF.

          ELSE.

            APPEND <fs_fdc> TO lt_doc_delete_tp_ap_dev.

          ENDIF.
      ENDCASE.
    ENDLOOP.

    "Valida tipo de apuração devolução
    LOOP AT lt_doc_delete_tp_ap_dev ASSIGNING FIELD-SYMBOL(<fs_dele>).

      DELETE gt_doc_h_ate WHERE bukrs = <fs_dele>-bukrs
                               AND belnr = <fs_dele>-belnr
                               AND gjahr = <fs_dele>-gjahr.
      DELETE gt_doc_fdc_ate WHERE bukrs = <fs_dele>-bukrs
                               AND belnr = <fs_dele>-belnr
                               AND gjahr = <fs_dele>-gjahr.
      DELETE gt_doc_h_tp_ate WHERE bukrs = <fs_dele>-bukrs
                               AND belnr = <fs_dele>-belnr
                               AND gjahr = <fs_dele>-gjahr.
      DELETE gt_doc_bill_ate WHERE vbeln = <fs_dele>-belnr.
    ENDLOOP.


    IF gt_doc_bill_ate[] IS NOT INITIAL.

      SELECT i~billingdocument,
             i~billingdocumentitem,
             i~subtotal1amount, " Valor Bruto sem IPI e ICMS ST
             i~subtotal2amount, " Valor ICMS
             i~subtotal3amount, " IPI
             i~subtotal4amount, " ICMS ST
             i~subtotal5amount, " Valor PIS e COFINS
             i~transactioncurrency,
             h~accountingexchangerate
        FROM i_billingdocumentitembasic AS i
            INNER JOIN i_billingdocumentbasic AS h
         ON h~billingdocument = i~billingdocument
         FOR ALL ENTRIES IN @gt_doc_bill_ate
       WHERE i~billingdocument = @gt_doc_bill_ate-vbeln
          AND i~billingdocumentitem = @gt_doc_bill_ate-posnr
        INTO TABLE @DATA(lt_billing).

      IF sy-subrc IS INITIAL.

        SELECT contrato,
               aditivo,
               tipo_imposto
          FROM ztfi_cad_provi
         WHERE contrato = @gs_contrato-contrato
           AND aditivo  = @gs_contrato-aditivo
          INTO @DATA(ls_provi)
            UP TO 1 ROWS.
        ENDSELECT.

        SORT gt_doc_fdc_ate BY vbeln.

        " Total - Valor Bruto sem IPI e ICMS ST (KZWI1), Valor IPI (KZWI3) e Valor ICMS ST (KZWI4)
        LOOP AT lt_billing ASSIGNING FIELD-SYMBOL(<fs_billing>).

          CLEAR: ls_total_item.

          IF <fs_billing>-transactioncurrency <> 'BRL'.
            lv_moeda_ext = abap_true.
          ELSE.
            lv_moeda_ext = abap_false.
          ENDIF.

          READ TABLE gt_doc_fdc_ate ASSIGNING FIELD-SYMBOL(<fs_fdc_ate>)
                                                  WITH KEY vbeln = <fs_billing>-billingdocument
                                                  BINARY SEARCH.
          IF sy-subrc = 0.
            IF  <fs_fdc_ate>-shkzg = 'H'.
              lv_inverter_valor = abap_true.
            ELSE.
              lv_inverter_valor = abap_false.
            ENDIF.
          ENDIF.


          CASE gs_crescimento-tipo_ap_imposto.
            WHEN 'B'.

              ls_total-vbeln = <fs_billing>-billingdocument.
              ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount.
              IF lv_inverter_valor = abap_true.
                ls_total-total = ls_total-total * -1.
              ENDIF.

              IF lv_moeda_ext = abap_true.
                ls_total-total = ls_total-total * <fs_billing>-accountingexchangerate.
              ENDIF.

              MOVE-CORRESPONDING ls_total TO ls_total_item.
              ls_total_item-item = <fs_billing>-billingdocumentitem.
              COLLECT ls_total_item INTO et_tot_item.
              COLLECT ls_total INTO et_tot_montante.

            WHEN 'L'.
              " Validar pelo campo ZIMP
              CASE ls_provi-tipo_imposto.
                WHEN '1'. " ICMS
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount - <fs_billing>-subtotal2amount.
                  IF lv_inverter_valor = abap_true.
                    ls_total-total = ls_total-total * -1.
                  ENDIF.
                  IF lv_moeda_ext = abap_true.
                    ls_total-total = ls_total-total * <fs_billing>-accountingexchangerate.
                  ENDIF.
                  ls_total-mont_descons = <fs_billing>-subtotal2amount.

                  MOVE-CORRESPONDING ls_total TO ls_total_item.
                  ls_total_item-item = <fs_billing>-billingdocumentitem.
                  COLLECT ls_total_item INTO et_tot_item.
                  COLLECT ls_total INTO et_tot_montante.

                WHEN '2'. " IPI
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal4amount.
                  IF lv_inverter_valor = abap_true.
                    ls_total-total = ls_total-total * -1.
                  ENDIF.
                  IF lv_moeda_ext = abap_true.
                    ls_total-total = ls_total-total * <fs_billing>-accountingexchangerate.
                  ENDIF.
                  ls_total-mont_descons = <fs_billing>-subtotal3amount.

                  MOVE-CORRESPONDING ls_total TO ls_total_item.
                  ls_total_item-item = <fs_billing>-billingdocumentitem.
                  COLLECT ls_total_item INTO et_tot_item.
                  COLLECT ls_total INTO et_tot_montante.

                WHEN '3'. " ICMS ST
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount.
                  IF lv_inverter_valor = abap_true.
                    ls_total-total = ls_total-total * -1.
                  ENDIF.
                  IF lv_moeda_ext = abap_true.
                    ls_total-total = ls_total-total * <fs_billing>-accountingexchangerate.
                  ENDIF.
                  ls_total-mont_descons = <fs_billing>-subtotal4amount.

                  MOVE-CORRESPONDING ls_total TO ls_total_item.
                  ls_total_item-item = <fs_billing>-billingdocumentitem.
                  COLLECT ls_total_item INTO et_tot_item.
                  COLLECT ls_total INTO et_tot_montante.

                WHEN '4'. " PIS e COFINS
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount - <fs_billing>-subtotal5amount.
                  IF lv_inverter_valor = abap_true.
                    ls_total-total = ls_total-total * -1.
                  ENDIF.
                  IF lv_moeda_ext = abap_true.
                    ls_total-total = ls_total-total * <fs_billing>-accountingexchangerate.
                  ENDIF.
                  ls_total-mont_descons = <fs_billing>-subtotal5amount.

                  MOVE-CORRESPONDING ls_total TO ls_total_item.
                  ls_total_item-item = <fs_billing>-billingdocumentitem.
                  COLLECT ls_total_item INTO et_tot_item.
                  COLLECT ls_total INTO et_tot_montante.

                WHEN '5'. " Todos
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount.
                  IF lv_inverter_valor = abap_true.
                    ls_total-total = ls_total-total * -1.
                  ENDIF.
                  IF lv_moeda_ext = abap_true.
                    ls_total-total = ls_total-total * <fs_billing>-accountingexchangerate.
                  ENDIF.

                  MOVE-CORRESPONDING ls_total TO ls_total_item.
                  ls_total_item-item = <fs_billing>-billingdocumentitem.
                  COLLECT ls_total_item INTO et_tot_item.
                  COLLECT ls_total INTO et_tot_montante.
                WHEN OTHERS.
              ENDCASE.

            WHEN OTHERS.
              RETURN.
          ENDCASE.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD step_validation.

    CONSTANTS: lc_msg_044 TYPE sy-msgno VALUE '044'.

    CONSTANTS: BEGIN OF lc_param,
                 modulo  TYPE zi_ca_param_mod-modulo VALUE 'FI-AR',
                 "! Chave
                 chave1  TYPE zi_ca_param_par-chave1 VALUE 'CRESCIMENTO',
                 "! Chave
                 chave2a TYPE zi_ca_param_par-chave2 VALUE 'EXERCICIODE',
                 chave2b TYPE zi_ca_param_par-chave2 VALUE 'EXERCICIOATE',
               END OF lc_param.

    DATA lv_value TYPE char10.
    DATA lv_error TYPE boolean.

    CLEAR: gv_gjahr_inicio, gv_gjahr_fim.

    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.
        lo_param->m_get_single(
          EXPORTING
            iv_modulo = lc_param-modulo
            iv_chave1 = lc_param-chave1
            iv_chave2 = lc_param-chave2a
          IMPORTING
            ev_param  = lv_value
        ).

        gv_gjahr_inicio = lv_value.

      CATCH zcxca_tabela_parametros.
        lv_error = abap_true.
    ENDTRY.


    TRY.
        lo_param->m_get_single(
          EXPORTING
            iv_modulo = lc_param-modulo
            iv_chave1 = lc_param-chave1
            iv_chave2 = lc_param-chave2b
          IMPORTING
            ev_param  = lv_value
        ).

        gv_gjahr_fim = lv_value.

      CATCH zcxca_tabela_parametros.
        lv_error = abap_true.
    ENDTRY.

    IF lv_error IS NOT INITIAL.

      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = 'e' ) ).

      "Parâmetros de exercicios não cadastrado. Favor verificar.
      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = lc_msg_044 ) ).
    ENDIF.

  ENDMETHOD.


  METHOD get_contrato_cresc.

    CONSTANTS lc_msg_043 TYPE sy-msgno VALUE '043'.

    CLEAR: gs_contrato , gs_crescimento, gv_contrato_msg.

    IF is_contrato-aditivo IS NOT INITIAL.
      CONCATENATE is_contrato-contrato '/' is_contrato-aditivo INTO gv_contrato_msg.
    ELSE.
      gv_contrato_msg =  is_contrato-contrato.
    ENDIF.

    CONDENSE gv_contrato_msg NO-GAPS.


    SELECT SINGLE *
        FROM ztfi_contrato
        INTO @gs_contrato
        WHERE doc_uuid_h = @is_contrato-doc_uuid_h.

    SELECT SINGLE *
        FROM ztfi_cad_cresci
        INTO @gs_crescimento
        WHERE doc_uuid_h = @is_contrato-doc_uuid_h.

    IF gs_contrato IS INITIAL OR
       gs_crescimento IS INITIAL.


      "Cálculo Crescimento Contrato/Aditivo &1 não foi possível!
      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = gv_contrato_msg  ) ).

      "Não foi possivel localizar dados do contrato ou do crescimento cadastrado
      et_return = VALUE #( BASE et_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = lc_msg_043 ) ).

    ENDIF.


  ENDMETHOD.


  METHOD step9_comp.

    FIELD-SYMBOLS: <fs_tipo> LIKE LINE OF gt_doc_h_tp_de.

    DATA: ls_total TYPE zsfi_cresctr_impost.

    DATA lt_doc_delete_tp_ap_dev TYPE zctgfi_cresctr_fdc.

    CHECK gt_doc_h_de[] IS NOT INITIAL.

    SORT gt_doc_h_de BY bukrs
                        gjahr
                        belnr.

    LOOP AT gt_doc_fdc_de ASSIGNING FIELD-SYMBOL(<fs_fdc>).

      CASE gs_crescimento-tipo_ap_devoluc.
        WHEN 'L'.
          IF <fs_fdc>-bschl = '01'
          OR <fs_fdc>-bschl = '11'.

            READ TABLE gt_doc_h_de TRANSPORTING NO FIELDS
                                                 WITH KEY bukrs = <fs_fdc>-bukrs
                                                          gjahr = <fs_fdc>-gjahr
                                                          belnr = <fs_fdc>-belnr
                                                          BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              LOOP AT gt_doc_h_de ASSIGNING FIELD-SYMBOL(<fs_documentos>) FROM sy-tabix. "#EC CI_NESTED
                IF <fs_documentos>-bukrs NE <fs_fdc>-bukrs
                OR <fs_documentos>-gjahr NE <fs_fdc>-gjahr
                OR <fs_documentos>-belnr NE <fs_fdc>-belnr.
                  EXIT.
                ENDIF.

                APPEND INITIAL LINE TO gt_doc_h_tp_de ASSIGNING <fs_tipo>.
                MOVE-CORRESPONDING <fs_documentos> TO <fs_tipo>.
                <fs_tipo>-tipo = 'D'. "Devolução

              ENDLOOP.
            ENDIF.
          ENDIF.

        WHEN 'B'.
          IF <fs_fdc>-bschl = '01'
         AND <fs_fdc>-shkzg = 'S'. " Débito

            READ TABLE gt_doc_h_de TRANSPORTING NO FIELDS
                                                   WITH KEY bukrs = <fs_fdc>-bukrs
                                                            gjahr = <fs_fdc>-gjahr
                                                            belnr = <fs_fdc>-belnr
                                                            BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              LOOP AT gt_doc_h_de ASSIGNING <fs_documentos> FROM sy-tabix. "#EC CI_NESTED
                IF <fs_documentos>-bukrs NE <fs_fdc>-bukrs
                OR <fs_documentos>-gjahr NE <fs_fdc>-gjahr
                OR <fs_documentos>-belnr NE <fs_fdc>-belnr.
                  EXIT.
                ENDIF.

                APPEND INITIAL LINE TO gt_doc_h_tp_de ASSIGNING <fs_tipo>.
                MOVE-CORRESPONDING <fs_documentos> TO <fs_tipo>.
                <fs_tipo>-tipo = 'D'. " Devolução

              ENDLOOP.
            ENDIF.

          ELSE.

            APPEND <fs_fdc> TO lt_doc_delete_tp_ap_dev.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    "Valida tipo de apuração devolução
    LOOP AT lt_doc_delete_tp_ap_dev ASSIGNING FIELD-SYMBOL(<fs_dele>).

      DELETE gt_doc_h_de WHERE bukrs = <fs_dele>-bukrs
                               AND belnr = <fs_dele>-belnr
                               AND gjahr = <fs_dele>-gjahr.
      DELETE gt_doc_fdc_de WHERE bukrs = <fs_dele>-bukrs
                               AND belnr = <fs_dele>-belnr
                               AND gjahr = <fs_dele>-gjahr.
      DELETE gt_doc_h_tp_de WHERE bukrs = <fs_dele>-bukrs
                               AND belnr = <fs_dele>-belnr
                               AND gjahr = <fs_dele>-gjahr.
      DELETE gt_doc_bill_de WHERE vbeln = <fs_dele>-belnr.
    ENDLOOP.

    IF gt_doc_bill_de[] IS NOT INITIAL.

      SELECT billingdocument,
             billingdocumentitem,
             subtotal1amount, " Valor Bruto sem IPI e ICMS ST
             subtotal2amount, " Valor ICMS
             subtotal3amount, " IPI
             subtotal4amount, " ICMS ST
             subtotal5amount  " Valor PIS e COFINS
        FROM i_billingdocumentitembasic
         FOR ALL ENTRIES IN @gt_doc_bill_de
       WHERE billingdocument = @gt_doc_bill_de-vbeln
         AND billingdocumentitem = @gt_doc_bill_de-posnr
        INTO TABLE @DATA(lt_billing).

      IF sy-subrc IS INITIAL.

        SELECT contrato,
               aditivo,
               tipo_imposto
          FROM ztfi_cad_provi
         WHERE contrato = @gs_contrato-contrato
           AND aditivo  = @gs_contrato-aditivo
          INTO @DATA(ls_provi)
            UP TO 1 ROWS.
        ENDSELECT.

        " Total - Valor Bruto sem IPI e ICMS ST (KZWI1), Valor IPI (KZWI3) e Valor ICMS ST (KZWI4)
        LOOP AT lt_billing ASSIGNING FIELD-SYMBOL(<fs_billing>).

          CASE gs_crescimento-tipo_ap_imposto.
            WHEN 'B'.
              ls_total-vbeln = <fs_billing>-billingdocument.
              ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount.
              COLLECT ls_total INTO et_tot_comparacao.

            WHEN 'L'.
              " Validar pelo campo ZIMP
              CASE ls_provi-tipo_imposto.
                WHEN '1'. " ICMS
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount - <fs_billing>-subtotal2amount.
                  ls_total-mont_descons = <fs_billing>-subtotal2amount.
                  COLLECT ls_total INTO et_tot_comparacao.

                WHEN '2'. " IPI
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal4amount.
                  ls_total-mont_descons = <fs_billing>-subtotal3amount.
                  COLLECT ls_total INTO et_tot_comparacao.

                WHEN '3'. " ICMS ST
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount.
                  ls_total-mont_descons = <fs_billing>-subtotal4amount.
                  COLLECT ls_total INTO et_tot_comparacao.

                WHEN '4'. " PIS e COFINS
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount - <fs_billing>-subtotal5amount.
                  ls_total-mont_descons = <fs_billing>-subtotal5amount.
                  COLLECT ls_total INTO et_tot_comparacao.

                WHEN '5'. " Todos
                  ls_total-vbeln = <fs_billing>-billingdocument.
                  ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount.
                  COLLECT ls_total INTO et_tot_comparacao.
                WHEN OTHERS.
              ENDCASE.

            WHEN OTHERS.
              RETURN.
          ENDCASE.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
