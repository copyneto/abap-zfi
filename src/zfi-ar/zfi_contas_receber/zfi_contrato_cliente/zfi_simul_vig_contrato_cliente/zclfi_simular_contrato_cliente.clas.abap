CLASS zclfi_simular_contrato_cliente DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_contrato_key,
        docuuidh   TYPE sysuuid_x16,
        contrato   TYPE ze_num_contrato,
        aditivo    TYPE ze_num_aditivo,
        parametros TYPE zc_fi_simular_contrato_cliente,
      END OF ty_contrato_key,

      BEGIN OF ty_cad_prov,
        contrato        TYPE ztfi_cad_provi-contrato,
        aditivo         TYPE ztfi_cad_provi-aditivo,
*        tipo_ap_devoluc TYPE ZTFI_CAD_PROVI-tipo_ap_devoluc,
        tipo_ap_imposto TYPE ztfi_cad_provi-tipo_ap_imposto,
        tipo_imposto    TYPE ztfi_cad_provi-tipo_imposto,
        perc_cond_desc  TYPE ztfi_cad_provi-perc_cond_desc,
      END OF ty_cad_prov.


    METHODS:
      executar
        IMPORTING
          is_contrato_key     TYPE ty_contrato_key
        RETURNING
          VALUE(rt_mensagens) TYPE bapiret2_tab.
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_contrato,
        contrato          TYPE zi_fi_clientes_cont-contrato,
        aditivo           TYPE zi_fi_clientes_cont-aditivo,
        cnpjraiz          TYPE zi_fi_clientes_cont-cnpjraiz,
        cliente           TYPE zi_fi_clientes_cont-cliente,
        empresa           TYPE zi_fi_clientes_cont-empresa,
        cnpj              TYPE zi_fi_clientes_cont-cnpj,
        canaldistribuicao TYPE zi_fi_clientes_cont-canaldistribuicao,
        setoratividade    TYPE zi_fi_clientes_cont-setoratividade,
        classifcnpj       TYPE zi_fi_clientes_cont-classifcnpj,
        bzirk             TYPE knvv-bzirk,
      END OF ty_contrato .
    TYPES:
      tt_contrato TYPE STANDARD TABLE OF ty_contrato  WITH KEY contrato aditivo .
    TYPES:
      BEGIN OF ty_documentos,
        bukrs    TYPE bsid_view-bukrs,
        kunnr    TYPE bsid_view-kunnr,
        belnr    TYPE bsid_view-belnr,
        buzei    TYPE bsid_view-buzei,
        gjahr    TYPE bsid_view-gjahr,
        blart    TYPE bsid_view-blart,
        xblnr    TYPE bsid_view-xblnr,
        augdt    TYPE bsid_view-augdt,
        augbl    TYPE bsid_view-augbl,
        bschl    TYPE bsid_view-bschl,
        budat    TYPE bsid_view-budat,
        zbd1p    TYPE bsid_view-zbd1p,
        gsber    TYPE bsid_view-gsber,
        vbeln    TYPE bsid_view-vbeln,
        xref1_hd TYPE p_bkpf_com-xref1_hd,
        netdt    TYPE bseg-netdt,
        wrbtr    TYPE bsid_view-wrbtr,
      END OF ty_documentos .
    TYPES:
      tt_documentos TYPE STANDARD TABLE OF ty_documentos WITH DEFAULT KEY .
    TYPES:
      BEGIN OF ty_billing,
        billingdocument             TYPE i_billingdocumentitembasic-billingdocument,
        billingdocumentitem         TYPE i_billingdocumentitembasic-billingdocumentitem,
        profitcenter                TYPE i_billingdocumentitembasic-profitcenter,
        salesordersalesorganization TYPE i_billingdocumentitembasic-salesordersalesorganization,
      END OF ty_billing .
    TYPES:
*      tt_billing TYPE STANDARD TABLE OF ty_billing WITH DEFAULT KEY .
      tt_billing TYPE SORTED TABLE OF ty_billing WITH NON-UNIQUE KEY billingdocument.
    TYPES:
      BEGIN OF ty_cad_familia,
        doc_uuid_h      TYPE ztfi_cad_provi-doc_uuid_h,
        empresa         TYPE ztfi_cad_provi-empresa,
        tipo_desconto   TYPE ztfi_cad_provi-tipo_desconto,
        cond_desconto   TYPE ztfi_cad_provi-cond_desconto,
        perc_cond_desc  TYPE ztfi_cad_provi-perc_cond_desc,
        aplica_desconto TYPE ztfi_cad_provi-aplica_desconto,
        tipo_apuracao   TYPE ztfi_cad_provi-tipo_apuracao,
        mes_vigencia    TYPE ztfi_cad_provi-mes_vigencia,
        reco_anual_desc TYPE ztfi_cad_provi-reco_anual_desc,
        classific_cnpj  TYPE ztfi_cad_provi-classific_cnpj,
        familia         TYPE ztfi_prov_fam-familia,
      END OF ty_cad_familia .
    TYPES:
*      tt_cad_familia TYPE STANDARD TABLE OF ty_cad_familia WITH DEFAULT KEY.
      tt_cad_familia TYPE SORTED TABLE OF ty_cad_familia WITH NON-UNIQUE KEY familia.

    TYPES:
      BEGIN OF ty_montantes,
        vbeln        TYPE vbeln_vf,
        posnr        TYPE posnr_vf,
        total        TYPE kzwi1,
        mont_descons TYPE kzwi1,
      END OF ty_montantes,
*      tt_montantes TYPE STANDARD TABLE OF ty_montantes WITH DEFAULT KEY.
      tt_montantes TYPE SORTED TABLE OF ty_montantes WITH NON-UNIQUE KEY vbeln posnr.


    CONSTANTS gc_prm_modulo TYPE ze_param_modulo VALUE 'FI-AR' ##NO_TEXT.
    CONSTANTS gc_chv1_simul_vig TYPE ze_param_chave VALUE 'SIMULAVIGENCIA' ##NO_TEXT.
    CONSTANTS gc_chv2_tp_doc TYPE ze_param_chave VALUE 'TIPODOC' ##NO_TEXT.
    CONSTANTS gc_msg_tp_e TYPE syst_msgty VALUE 'E' ##NO_TEXT.
    CONSTANTS gc_msg_id TYPE syst_msgid VALUE 'ZFI_BASE_CALCULO' ##NO_TEXT.
    CONSTANTS gc_msg_tp_s TYPE syst_msgty VALUE 'S' ##NO_TEXT.
    CONSTANTS gc_msg_suces_tx TYPE syst_msgno VALUE '031' ##NO_TEXT.
    CONSTANTS gc_msg_error_tx TYPE syst_msgno VALUE '024' ##NO_TEXT.
    CONSTANTS gc_msg_1 TYPE syst_msgno VALUE '025' ##NO_TEXT.
    CONSTANTS gc_msg_2 TYPE syst_msgno VALUE '026' ##NO_TEXT.
    CONSTANTS gc_msg_3 TYPE syst_msgno VALUE '027' ##NO_TEXT.
    CONSTANTS gc_msg_4 TYPE syst_msgno VALUE '028' ##NO_TEXT.
    CONSTANTS gc_msg_5 TYPE syst_msgno VALUE '029' ##NO_TEXT.
    CONSTANTS gc_msg_6 TYPE syst_msgno VALUE '030' ##NO_TEXT.
    DATA gt_return TYPE bapiret2_tab .

    METHODS step1
      IMPORTING
        !is_contrato_key  TYPE ty_contrato_key
      RETURNING
        VALUE(rt_retorno) TYPE tt_contrato .
    METHODS step2
      IMPORTING
        !is_contrato_key  TYPE ty_contrato_key
        !it_contratos     TYPE tt_contrato
      RETURNING
        VALUE(rt_retorno) TYPE tt_documentos .
    METHODS step3
      IMPORTING
        !is_contrato_key  TYPE ty_contrato_key
        !it_documentos    TYPE tt_documentos
      EXPORTING
        !et_tot_montante  TYPE tt_montantes
        es_cad_cresci     TYPE ty_cad_prov
      RETURNING
        VALUE(rt_retorno) TYPE tt_documentos .
    METHODS step5
      IMPORTING
        !is_contrato_key  TYPE ty_contrato_key
      RETURNING
        VALUE(rt_retorno) TYPE tt_cad_familia .
    METHODS step6
      IMPORTING
        !is_contrato_key  TYPE ty_contrato_key
        !it_documentos    TYPE tt_documentos
        !it_cad_provi     TYPE tt_cad_familia
      RETURNING
        VALUE(rt_retorno) TYPE tt_billing .
    METHODS step7
      IMPORTING
        !is_contrato_key TYPE ty_contrato_key
        !it_documentos   TYPE tt_documentos
        !it_billing      TYPE tt_billing
        !it_cad_provi    TYPE tt_cad_familia
        !it_contrato     TYPE tt_contrato
        !it_tot_montante TYPE tt_montantes
        is_cad_prov      TYPE ty_cad_prov.
ENDCLASS.



CLASS ZCLFI_SIMULAR_CONTRATO_CLIENTE IMPLEMENTATION.


  METHOD executar.
    DATA ls_cad_prov TYPE ty_cad_prov.
    DATA(lt_contratos) = step1( is_contrato_key ).
    IF gt_return IS INITIAL.
      DATA(lt_documentos) = step2(
        is_contrato_key = is_contrato_key
        it_contratos = lt_contratos ).
    ENDIF.
    IF gt_return IS INITIAL.
      DATA lt_montantes TYPE tt_montantes.
      lt_documentos = step3(
        EXPORTING
          is_contrato_key = is_contrato_key
          it_documentos   = lt_documentos
        IMPORTING
          et_tot_montante = lt_montantes
          es_cad_cresci = ls_cad_prov
      ).
    ENDIF.
    IF gt_return IS INITIAL.
      DATA(lt_cad_provi) = step5( is_contrato_key ).
    ENDIF.
    IF gt_return IS INITIAL.
      DATA(lt_billing) = step6(
        is_contrato_key = is_contrato_key
        it_documentos   = lt_documentos
        it_cad_provi    = lt_cad_provi ).
    ENDIF.

*    SELECT * FROM ztfi_contrato INTO TABLE @DATA(lt_fi_contratos)
*    WHERE contrato = @is_contrato_key-contrato
*    AND aditivo = @is_contrato_key-aditivo.
*
*    DATA lt_simul_contr TYPE TABLE OF ztfi_simul_contr.
*
*    lt_simul_contr = CORRESPONDING #( lt_fi_contratos ).
*
*    MODIFY  ztfi_simul_contr FROM TABLE lt_simul_contr.
    step7(
      is_contrato_key = is_contrato_key
      it_documentos = lt_documentos
      it_billing    = lt_billing
      it_cad_provi  = lt_cad_provi
      it_contrato  = lt_contratos
      it_tot_montante = lt_montantes
      is_cad_prov = ls_cad_prov
    ).
    IF gt_return IS NOT INITIAL.
      rt_mensagens = gt_return.
    ELSE.
      DATA(lv_chave) = COND #(
        WHEN is_contrato_key-aditivo IS NOT INITIAL
        THEN is_contrato_key-aditivo
        ELSE  is_contrato_key-contrato
      ).
      rt_mensagens = VALUE #(
      ( id = gc_msg_id
        type       = gc_msg_tp_s
        number = '006'  )
      ( id = gc_msg_id
        number = gc_msg_suces_tx
        type       = gc_msg_tp_s
        message_v1 = lv_chave  )
      ).
    ENDIF.
  ENDMETHOD.


  METHOD step1.

    DATA: lt_valid_prov TYPE tt_contrato.

    SELECT contrato,
           aditivo,
           cnpjraiz,
           cliente,
           empresa,
           cnpj,
           canaldistribuicao, "vtweg
           setoratividade,    "spart
           kna1~katr2 AS classifcnpj,        "katr2 - classif_cnpj
           regiaovendas AS bzirk
      FROM zi_fi_clientes_cont
      LEFT OUTER JOIN kna1
      ON kna1~kunnr = zi_fi_clientes_cont~cliente
     WHERE contrato = @is_contrato_key-contrato
       AND aditivo  = @is_contrato_key-aditivo
      INTO TABLE @rt_retorno.

    IF sy-subrc IS INITIAL.

      SELECT contrato,
             aditivo,
             classific_cnpj
             FROM ztfi_cad_provi
             INTO TABLE @DATA(lt_prov)
             FOR ALL ENTRIES IN @rt_retorno
             WHERE contrato = @rt_retorno-contrato
               AND aditivo  = @rt_retorno-aditivo.

      IF sy-subrc = 0.

        lt_valid_prov = rt_retorno.

        LOOP AT lt_valid_prov ASSIGNING FIELD-SYMBOL(<fs_valid>).

          READ TABLE lt_prov WITH KEY contrato = <fs_valid>-contrato
                                      aditivo = <fs_valid>-aditivo
                                      classific_cnpj = <fs_valid>-classifcnpj
                                      TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            CONTINUE.

          ELSE.
            READ TABLE lt_prov WITH KEY contrato = <fs_valid>-contrato
                                    aditivo = <fs_valid>-aditivo
                                    classific_cnpj = space
                                    TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              DELETE rt_retorno WHERE contrato = <fs_valid>-contrato
                                   AND aditivo = <fs_valid>-aditivo.
            ENDIF.
          ENDIF.


        ENDLOOP.

      ENDIF.

      SORT rt_retorno BY contrato aditivo.

      IF rt_retorno IS INITIAL.
        DATA(lv_chave2) = COND #(
        WHEN is_contrato_key-aditivo IS NOT INITIAL
        THEN is_contrato_key-aditivo
        ELSE  is_contrato_key-contrato
      ).
        gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_e
                                              number     = gc_msg_error_tx
                                              message_v1 = lv_chave2 ) ).

        gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                              type       = gc_msg_tp_e
                                              number     = gc_msg_1 ) ).
      ENDIF.

    ELSE.
      DATA(lv_chave) = COND #(
        WHEN is_contrato_key-aditivo IS NOT INITIAL
        THEN is_contrato_key-aditivo
        ELSE  is_contrato_key-contrato
      ).
      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = lv_chave ) ).

      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_1 ) ).
    ENDIF.
  ENDMETHOD.


  METHOD step2.
    DATA: lr_tp_docs TYPE RANGE OF bkpf-blart.
    TRY.
        NEW zclca_tabela_parametros( )->m_get_range(
          EXPORTING
            iv_modulo = gc_prm_modulo
            iv_chave1 = gc_chv1_simul_vig
            iv_chave2 = gc_chv2_tp_doc
          IMPORTING
            et_range  = lr_tp_docs
       ).
      CATCH zcxca_tabela_parametros.
        RETURN.
    ENDTRY.
    DATA(lt_contratos) = it_contratos.
    SORT lt_contratos BY empresa cliente.
    DELETE ADJACENT DUPLICATES FROM lt_contratos COMPARING empresa cliente.

    SELECT bsid~bukrs,
           bsid~kunnr,
           bsid~belnr,
           bsid~buzei,
           bsid~gjahr,
           bsid~blart,
           bsid~xblnr,
           bsid~augdt,
           bsid~augbl,
           bsid~bschl,
           bsid~budat,
           bsid~zbd1p,
           bseg~gsber, "bsid~gsber,
           bsid~vbeln,
           bkpf_com~xref1_hd,
           bseg~netdt,
           bsid~wrbtr
      FROM bsid_view AS bsid
        INNER JOIN @lt_contratos AS contratos
*        INNER JOIN @it_contratos AS contratos
      ON ( bsid~bukrs = contratos~empresa AND
           bsid~kunnr = contratos~cliente )
        INNER JOIN p_bkpf_com AS bkpf_com
        ON ( bkpf_com~belnr = bsid~belnr AND
             bkpf_com~bukrs = bsid~bukrs AND
             bkpf_com~gjahr = bsid~gjahr )
        INNER JOIN bseg AS bseg
        ON ( bseg~bukrs = bsid~bukrs AND
             bseg~belnr = bsid~belnr AND
             bseg~buzei = bsid~buzei AND
             bseg~gjahr = bsid~gjahr )
     WHERE bsid~blart IN @lr_tp_docs
       AND ( bsid~budat >= @is_contrato_key-parametros-datainivalid AND
             bsid~budat <= @is_contrato_key-parametros-datafimvalid )
      INTO TABLE @rt_retorno.

    SELECT bsad~bukrs,
           bsad~kunnr,
           bsad~belnr,
           bsad~buzei,
           bsad~gjahr,
           bsad~blart,
           bsad~xblnr,
           bsad~augdt,
           bsad~augbl,
           bsad~bschl,
           bsad~budat,
           bsad~zbd1p,
           bseg~gsber, "bsad~gsber,
           bsad~vbeln,
           bkpf_com~xref1_hd,
           bseg~netdt,
           bsad~wrbtr
      FROM bsad_view AS bsad
        INNER JOIN @lt_contratos AS contratos
*        INNER JOIN @it_contratos AS contratos
      ON ( bsad~bukrs = contratos~empresa AND
           bsad~kunnr = contratos~cliente )
        INNER JOIN p_bkpf_com AS bkpf_com
        ON ( bkpf_com~belnr = bsad~belnr AND
             bkpf_com~bukrs = bsad~bukrs AND
             bkpf_com~gjahr = bsad~gjahr )
        INNER JOIN bseg AS bseg
        ON ( bseg~bukrs = bsad~bukrs AND
             bseg~belnr = bsad~belnr AND
             bseg~buzei = bsad~buzei AND
             bseg~gjahr = bsad~gjahr )
     WHERE bsad~blart IN @lr_tp_docs
       AND ( bsad~budat >= @is_contrato_key-parametros-datainivalid AND
             bsad~budat <= @is_contrato_key-parametros-datafimvalid )
      INTO  TABLE @DATA(lt_bsad_dados).
    APPEND LINES OF lt_bsad_dados TO  rt_retorno.

    IF rt_retorno IS NOT INITIAL.
      SORT rt_retorno BY bukrs gjahr belnr buzei.

      SELECT bukrs, belnr, gjahr, gsber
        FROM bseg
        FOR ALL ENTRIES IN @rt_retorno
        WHERE bukrs = @rt_retorno-bukrs
          AND belnr = @rt_retorno-belnr
          AND gjahr = @rt_retorno-gjahr
          AND gsber IS NOT INITIAL
        INTO TABLE @DATA(lt_bseg_gsber).
      SORT lt_bseg_gsber BY bukrs belnr gjahr.
      LOOP AT rt_retorno ASSIGNING FIELD-SYMBOL(<fs_retorno>).
        READ TABLE lt_bseg_gsber INTO DATA(ls_bseg_gsber) WITH KEY bukrs = <fs_retorno>-bukrs belnr = <fs_retorno>-belnr gjahr = <fs_retorno>-gjahr BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_retorno>-gsber = ls_bseg_gsber-gsber.
        ENDIF.
      ENDLOOP.

    ELSE.
      DATA(lv_chave) = COND #(
        WHEN is_contrato_key-aditivo IS NOT INITIAL
        THEN is_contrato_key-aditivo
        ELSE  is_contrato_key-contrato
      ).
      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = lv_chave ) ).

      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_2 ) ).
    ENDIF.


  ENDMETHOD.


  METHOD step3.

    DATA: lv_inverte TYPE boolean.

    SELECT contrato,
           aditivo,
*           tipo_ap_devoluc,
           tipo_ap_imposto,
           tipo_imposto,
           perc_cond_desc
*           ajuste_anual
      INTO @es_cad_cresci
        UP TO 1 ROWS
      FROM ztfi_cad_provi
     WHERE contrato = @is_contrato_key-contrato
       AND aditivo  = @is_contrato_key-aditivo.
    ENDSELECT.
    IF sy-subrc <> 0.
*      RETURN.
    ENDIF.

*    SELECT contrato,
*           aditivo,
*           tipo_ap_devoluc,
*           tipo_ap_imposto,
*           tipo_imposto,
*           ajuste_anual
*      INTO @es_cad_cresci
*        UP TO 1 ROWS
*      FROM ztfi_cad_cresci
*     WHERE contrato = @is_contrato_key-contrato
*       AND aditivo  = @is_contrato_key-aditivo.
*    ENDSELECT.
*    IF sy-subrc <> 0.
**      RETURN.
*    ENDIF.

*    LOOP AT it_documentos INTO DATA(ls_documentos).
    LOOP AT it_documentos ASSIGNING FIELD-SYMBOL(<fs_documentos>).
*      CASE es_cad_cresci-tipo_ap_devoluc.
      CASE es_cad_cresci-tipo_ap_imposto.
        WHEN 'L'.
          IF <fs_documentos>-bschl = '01' OR <fs_documentos>-bschl = '11' OR <fs_documentos>-bschl = '12'.
            APPEND <fs_documentos> TO rt_retorno.
          ENDIF.
        WHEN 'B'.
          IF <fs_documentos>-bschl = '01' OR <fs_documentos>-bschl = '12'.
            APPEND <fs_documentos> TO rt_retorno.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    IF rt_retorno IS NOT INITIAL.
      SORT rt_retorno BY vbeln.

      SELECT billingdocument,
             billingdocumentitem,
             subtotal1amount, " Valor Bruto sem IPI e ICMS ST
             subtotal2amount, " Valor ICMS
             subtotal3amount, " IPI
             subtotal4amount, " ICMS ST
             subtotal5amount  " Valor PIS e COFINS
        FROM i_billingdocumentitembasic
         FOR ALL ENTRIES IN @rt_retorno
       WHERE billingdocument = @rt_retorno-vbeln
        INTO TABLE @DATA(lt_billing).
    ENDIF.
    IF sy-subrc <> 0 OR rt_retorno IS INITIAL.
      DATA(lv_chave) = COND #(
        WHEN is_contrato_key-aditivo IS NOT INITIAL
        THEN is_contrato_key-aditivo
        ELSE  is_contrato_key-contrato
      ).
      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = lv_chave ) ).

      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_3 ) ).
    ENDIF.

    DATA: ls_total TYPE ty_montantes.

    LOOP AT lt_billing ASSIGNING FIELD-SYMBOL(<fs_billing>).

      READ TABLE it_documentos WITH KEY belnr = <fs_billing>-billingdocument
                                        ASSIGNING FIELD-SYMBOL(<fs_document>).

      IF sy-subrc = 0.

        IF <fs_document>-blart = 'RB'.
          lv_inverte = abap_true.
        ELSE.
          lv_inverte = abap_false.
        ENDIF.

        CASE es_cad_cresci-tipo_ap_imposto.
          WHEN 'B'.
            ls_total-vbeln = <fs_billing>-billingdocument.
            ls_total-posnr = <fs_billing>-billingdocumentitem.
            ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount.
            IF lv_inverte = abap_true.
              ls_total-total = ls_total-total * -1.
            ENDIF.
            COLLECT ls_total INTO et_tot_montante.

          WHEN 'L'.
            " Validar pelo campo ZIMP
            CASE es_cad_cresci-tipo_imposto.
              WHEN '1'. " ICMS
                ls_total-vbeln = <fs_billing>-billingdocument.
                ls_total-posnr = <fs_billing>-billingdocumentitem.
                ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount - <fs_billing>-subtotal2amount.
                IF lv_inverte = abap_true.
                  ls_total-total = ls_total-total * -1.
                ENDIF.
                ls_total-mont_descons = <fs_billing>-subtotal2amount.
                COLLECT ls_total INTO et_tot_montante.

              WHEN '2'. " IPI
                ls_total-vbeln = <fs_billing>-billingdocument.
                ls_total-posnr = <fs_billing>-billingdocumentitem.
                ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount - <fs_billing>-subtotal3amount .
                IF lv_inverte = abap_true.
                  ls_total-total = ls_total-total * -1.
                ENDIF.
                ls_total-mont_descons = <fs_billing>-subtotal3amount.
                COLLECT ls_total INTO et_tot_montante.

              WHEN '3'. " ICMS ST
                ls_total-vbeln = <fs_billing>-billingdocument.
                ls_total-posnr = <fs_billing>-billingdocumentitem.
                ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount.
                IF lv_inverte = abap_true.
                  ls_total-total = ls_total-total * -1.
                ENDIF.
                ls_total-mont_descons = <fs_billing>-subtotal4amount.
                COLLECT ls_total INTO et_tot_montante.

              WHEN '4'. " PIS e COFINS
                ls_total-vbeln = <fs_billing>-billingdocument.
                ls_total-posnr = <fs_billing>-billingdocumentitem.
                ls_total-total = <fs_billing>-subtotal1amount + <fs_billing>-subtotal3amount + <fs_billing>-subtotal4amount .
                IF lv_inverte = abap_true.
                  ls_total-total = ls_total-total * -1.
                ENDIF.
                ls_total-mont_descons = <fs_billing>-subtotal5amount.
                COLLECT ls_total INTO et_tot_montante.

              WHEN '5'. " Todos
                ls_total-vbeln = <fs_billing>-billingdocument.
                ls_total-posnr = <fs_billing>-billingdocumentitem.
                ls_total-total = <fs_billing>-subtotal1amount - ( <fs_billing>-subtotal2amount + <fs_billing>-subtotal5amount ).
                IF lv_inverte = abap_true.
                  ls_total-total = ls_total-total * -1.
                ENDIF.
                COLLECT ls_total INTO et_tot_montante.
              WHEN OTHERS.
            ENDCASE.

          WHEN OTHERS.
            RETURN.
        ENDCASE.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD step5.
    SELECT cad_provi~doc_uuid_h,
           cad_provi~empresa,
           cad_provi~tipo_desconto,
           cad_provi~cond_desconto,
           cad_provi~perc_cond_desc,
           cad_provi~aplica_desconto,
           cad_provi~tipo_apuracao,
           cad_provi~mes_vigencia,
           cad_provi~reco_anual_desc,
           cad_provi~classific_cnpj,
           prov_fam~familia
      FROM ztfi_cad_provi AS cad_provi
        LEFT OUTER JOIN ztfi_prov_fam AS prov_fam
        ON cad_provi~doc_uuid_h = prov_fam~doc_uuid_h
        AND  cad_provi~doc_uuid_prov = prov_fam~doc_uuid_prov
     WHERE cad_provi~doc_uuid_h = @is_contrato_key-docuuidh
*     contrato = @is_contrato_key-contrato
*       AND aditivo  = @is_contrato_key-aditivo
      INTO TABLE @rt_retorno.
    IF sy-subrc <> 0.
      DATA(lv_chave) = COND #(
        WHEN is_contrato_key-aditivo IS NOT INITIAL
        THEN is_contrato_key-aditivo
        ELSE  is_contrato_key-contrato
      ).
      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = lv_chave ) ).

      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_4 ) ).
    ENDIF.
  ENDMETHOD.


  METHOD step6.
    IF it_documentos IS NOT INITIAL.
      SELECT billingdocument,
             billingdocumentitem,
             profitcenter,
             salesordersalesorganization
        FROM i_billingdocumentitembasic
         FOR ALL ENTRIES IN @it_documentos
       WHERE billingdocument             = @it_documentos-vbeln
         AND salesordersalesorganization = @it_documentos-bukrs
        INTO TABLE @DATA(lt_billing).
    ENDIF.
    IF sy-subrc = 0.
      LOOP AT lt_billing ASSIGNING FIELD-SYMBOL(<fs_billing>).
        IF line_exists( it_cad_provi[ familia = '' ] )
           OR line_exists( it_cad_provi[ familia = <fs_billing>-profitcenter(2) ] ).
          INSERT <fs_billing> INTO TABLE rt_retorno.
        ENDIF.
      ENDLOOP.
    ELSE.
      DATA(lv_chave) = COND #(
        WHEN is_contrato_key-aditivo IS NOT INITIAL
        THEN is_contrato_key-aditivo
        ELSE  is_contrato_key-contrato
      ).
      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_error_tx
                                            message_v1 = lv_chave ) ).

      gt_return = VALUE #( BASE gt_return ( id         = gc_msg_id
                                            type       = gc_msg_tp_e
                                            number     = gc_msg_5 ) ).
    ENDIF.

  ENDMETHOD.


  METHOD step7.

    DATA lt_simul_contr TYPE TABLE OF ztfi_simul_contr.
    DATA ls_simul_contr TYPE ztfi_simul_contr.
    DATA lt_cad_familia TYPE TABLE OF ty_cad_familia.
    DATA lr_classif TYPE RANGE OF kna1-katr2.

    DATA(lt_contrato) = it_contrato.
    SORT lt_contrato BY empresa cliente.

    LOOP AT it_documentos ASSIGNING FIELD-SYMBOL(<fs_documento>).
      READ TABLE it_billing TRANSPORTING NO FIELDS WITH KEY billingdocument = <fs_documento>-vbeln BINARY SEARCH.
      DATA(lv_tabix) = sy-tabix.
      CHECK sy-subrc = 0.
      LOOP AT it_billing ASSIGNING FIELD-SYMBOL(<fs_billing>) FROM lv_tabix. "#EC CI_NESTED
        IF <fs_billing>-billingdocument <> <fs_documento>-vbeln.
          EXIT.
        ENDIF.

        CLEAR ls_simul_contr.
*      LOOP AT it_billing ASSIGNING FIELD-SYMBOL(<fs_billing>) WHERE billingdocument = <fs_documento>-vbeln.
        ls_simul_contr = CORRESPONDING #( <fs_documento> ).

        READ TABLE lt_contrato INTO DATA(ls_contrato) WITH KEY empresa = <fs_documento>-bukrs cliente = <fs_documento>-kunnr BINARY SEARCH.
*        READ TABLE it_contrato INTO DATA(ls_contrato) WITH KEY empresa =  <fs_documento>-bukrs cliente = <fs_documento>-kunnr.
        IF sy-subrc = 0.

          CLEAR: lt_cad_familia.
          lt_cad_familia = it_cad_provi.

          lr_classif = VALUE #( ( sign = 'I'
                                  option = 'EQ'
                                  low = space )
                                ( sign = 'I'
                                  option = 'EQ'
                                  low = ls_contrato-classifcnpj ) ).

          DELETE lt_cad_familia WHERE classific_cnpj NOT IN lr_classif. "#EC CI_SORTSEQ

          LOOP AT lt_cad_familia ASSIGNING FIELD-SYMBOL(<fs_cad_prov>). "#EC CI_NESTED

            IF <fs_cad_prov>-familia IS NOT INITIAL.

              IF <fs_cad_prov>-familia <> <fs_billing>-profitcenter(2).
                CONTINUE.
              ENDIF.

            ELSE.
              ls_simul_contr-flagfamtodos = abap_true.
            ENDIF.

**          READ TABLE it_cad_provi ASSIGNING FIELD-SYMBOL(<fs_cad_prov>) WITH KEY classific_cnpj = ls_contrato-classifcnpj
**                                                                                 familia = <fs_billing>-profitcenter(2).
**          IF sy-subrc <> 0.
**
**            READ TABLE it_cad_provi ASSIGNING <fs_cad_prov> WITH KEY classific_cnpj = ''
**                                                                     familia = <fs_billing>-profitcenter(2).
**            IF sy-subrc <> 0.
**
**
**              READ TABLE it_cad_provi ASSIGNING <fs_cad_prov> WITH KEY classific_cnpj = ''
**                                                                       familia = ''.
**              IF sy-subrc <> 0.
**                CONTINUE.
**              ENDIF.
**            ENDIF.
**          ENDIF.

            ls_simul_contr-familia_cl = <fs_cad_prov>-familia.
            ls_simul_contr-tipo_desconto = <fs_cad_prov>-tipo_desconto.
            ls_simul_contr-cond_desconto = <fs_cad_prov>-cond_desconto.
            ls_simul_contr-aplica_desconto = <fs_cad_prov>-aplica_desconto.
            ls_simul_contr-vbeln = <fs_billing>-billingdocument.
            ls_simul_contr-posnr = <fs_billing>-billingdocumentitem.


            ls_simul_contr-contrato = ls_contrato-contrato.
            ls_simul_contr-aditivo = ls_contrato-aditivo.
            ls_simul_contr-classif_cnpj = ls_contrato-classifcnpj.
            ls_simul_contr-cliente = ls_contrato-cliente.
            ls_simul_contr-canal = ls_contrato-canaldistribuicao.
            ls_simul_contr-setor = ls_contrato-setoratividade.
            ls_simul_contr-bzirk = ls_contrato-bzirk.

            READ TABLE it_tot_montante INTO DATA(ls_tot_montante) WITH KEY vbeln = <fs_billing>-billingdocument posnr = <fs_billing>-billingdocumentitem.
            IF sy-subrc = 0.
              ls_simul_contr-montdesccom = ls_tot_montante-mont_descons.
              ls_simul_contr-wrbtrcal = ls_tot_montante-total.
              IF ls_simul_contr-wrbtrcal < 0.
                ls_simul_contr-wrbtr = ls_simul_contr-wrbtr * -1.
              ENDIF.
            ENDIF.


**        IF is_cad_prov-tipo_ap_imposto = 'B'.
**          ls_simul_contr-wrbtrcal = ls_simul_contr-wrbtr.
**        ENDIF.
            IF <fs_cad_prov>-perc_cond_desc IS NOT INITIAL.
              ls_simul_contr-montdesccom = ls_simul_contr-wrbtrcal * ( <fs_cad_prov>-perc_cond_desc / 100 ).
              ls_simul_contr-zbd1p = <fs_cad_prov>-perc_cond_desc .
            ENDIF.

            GET TIME STAMP FIELD ls_simul_contr-created_at.
            GET TIME STAMP FIELD ls_simul_contr-last_changed_at.
            GET TIME STAMP FIELD ls_simul_contr-local_last_changed_at.

            ls_simul_contr-created_by = sy-uname.
            ls_simul_contr-last_changed_by = sy-uname.

            APPEND ls_simul_contr TO lt_simul_contr.


          ENDLOOP.

        ENDIF.

*        "inserir uma nova linha com a familia geral
*        IF ls_simul_contr-familia_cl IS NOT INITIAL.
*
*          ls_simul_contr-flagfamtodos = abap_true.
*          READ TABLE it_cad_provi ASSIGNING <fs_cad_prov> WITH KEY familia = ''.
*          IF sy-subrc <> 0.
*            CONTINUE.
*          ENDIF.
*
*          ls_simul_contr-familia_cl = <fs_cad_prov>-familia.
*          ls_simul_contr-tipo_desconto = <fs_cad_prov>-tipo_desconto.
*          ls_simul_contr-cond_desconto = <fs_cad_prov>-cond_desconto.
*          ls_simul_contr-aplica_desconto = <fs_cad_prov>-aplica_desconto.
*          ls_simul_contr-vbeln = <fs_billing>-billingdocument.
*          ls_simul_contr-posnr = <fs_billing>-billingdocumentitem.
*
*          READ TABLE lt_contrato INTO ls_contrato WITH KEY empresa =  <fs_documento>-bukrs cliente = <fs_documento>-kunnr BINARY SEARCH.
*          IF sy-subrc = 0.
*            ls_simul_contr-contrato = ls_contrato-contrato.
*            ls_simul_contr-aditivo = ls_contrato-aditivo.
*            ls_simul_contr-classif_cnpj = ls_contrato-classifcnpj.
*            ls_simul_contr-cliente = ls_contrato-cliente.
*            ls_simul_contr-canal = ls_contrato-canaldistribuicao.
*            ls_simul_contr-setor = ls_contrato-setoratividade.
*            ls_simul_contr-bzirk = ls_contrato-bzirk.
*          ENDIF.
*          READ TABLE it_tot_montante INTO ls_tot_montante WITH KEY vbeln = <fs_billing>-billingdocument posnr = <fs_billing>-billingdocumentitem.
*          IF sy-subrc = 0.
*            ls_simul_contr-montdesccom = ls_tot_montante-mont_descons.
*            ls_simul_contr-wrbtrcal = ls_tot_montante-total.
*            IF ls_simul_contr-wrbtrcal < 0.
*              ls_simul_contr-wrbtr = ls_simul_contr-wrbtr * -1.
*            ENDIF.
*          ENDIF.
*
*
*          IF <fs_cad_prov>-perc_cond_desc IS NOT INITIAL.
*            ls_simul_contr-montdesccom = ls_simul_contr-wrbtrcal * ( <fs_cad_prov>-perc_cond_desc / 100 ).
*          ENDIF.
*
*          GET TIME STAMP FIELD ls_simul_contr-created_at.
*          GET TIME STAMP FIELD ls_simul_contr-last_changed_at.
*          GET TIME STAMP FIELD ls_simul_contr-local_last_changed_at.
*
*          ls_simul_contr-created_by = sy-uname.
*          ls_simul_contr-last_changed_by = sy-uname.
*
*          APPEND ls_simul_contr TO lt_simul_contr.
*
*        ENDIF.

        CLEAR ls_simul_contr.

*        AT END OF billingdocument.
*          EXIT.
*        ENDAT.
      ENDLOOP.
    ENDLOOP.
    DELETE FROM ztfi_simul_contr WHERE aditivo = is_contrato_key-aditivo AND contrato = is_contrato_key-contrato.
    MODIFY  ztfi_simul_contr FROM TABLE lt_simul_contr.

  ENDMETHOD.
ENDCLASS.
