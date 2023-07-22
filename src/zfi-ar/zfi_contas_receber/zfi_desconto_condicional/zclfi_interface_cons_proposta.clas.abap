"!<p>Classe processar Interface Consulta Proposta</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 23 de Março de 2022</p>
CLASS zclfi_interface_cons_proposta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS executar
      IMPORTING
        !is_input  TYPE zclfi_mt_consultar_proposta
      EXPORTING
        !es_output TYPE zclfi_mt_retorno_consulta_prop
      RAISING
        zcxca_erro_interface .
    METHODS constructor .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES: BEGIN OF ty_j_1bbranch,
             bukrs  TYPE j_1bbranch-bukrs,
             branch TYPE j_1bbranch-branch,
           END OF ty_j_1bbranch,
           tt_j_1bbranch TYPE TABLE OF ty_j_1bbranch.

    TYPES: BEGIN OF ty_bsid,
             bukrs     TYPE bsid_view-bukrs,
             kunnr     TYPE bsid_view-kunnr,
             xblnr     TYPE bsid_view-xblnr,
             belnr     TYPE bsid_view-belnr,
             zproposta TYPE ztfi_contratopar-zproposta,
           END OF ty_bsid,
           tt_bsid TYPE TABLE OF ty_bsid.

    TYPES: BEGIN OF ty_bsad,
             bukrs     TYPE bsad_view-bukrs,
             kunnr     TYPE bsad_view-kunnr,
             xblnr     TYPE bsad_view-xblnr,
             belnr     TYPE bsad_view-belnr,
             zproposta TYPE ztfi_contratopar-zproposta,
           END OF ty_bsad,
           tt_bsad TYPE TABLE OF ty_bsad.

    CONSTANTS:
      BEGIN OF gc_erros,
        interface TYPE string VALUE 'ZCLFI_CL_SI_RECEBE_CONSULTA_PR',
        metodo    TYPE string VALUE 'executar'                             ##NO_TEXT,
        classe    TYPE string VALUE 'ZCLFI_INTERFACE_CONS_PROPOSTA'        ##NO_TEXT,
      END OF gc_erros,
      BEGIN OF gc_param,
        modulo  TYPE ztca_param_par-modulo VALUE 'FI-AR',
        chave1  TYPE ztca_param_par-chave1 VALUE 'PDC',
        chave2  TYPE ztca_param_par-chave2 VALUE 'CRIARPROP',
        tipodoc TYPE ztca_param_par-chave3 VALUE 'TIPODOC',
      END OF gc_param.

    DATA: gt_dados_cab TYPE TABLE OF ztfi_contratocab,
          gt_dados_par TYPE TABLE OF ztfi_contratopar,
          gt_bsid      TYPE tt_bsid,
          gt_bsad      TYPE tt_bsad,
          gt_branch    TYPE tt_j_1bbranch.

    DATA: gv_tipo_doc TYPE blart.

    "! Return error raising
    METHODS error_raise
      IMPORTING
        !is_ret TYPE scx_t100key
      RAISING
        zcxca_erro_interface .
    METHODS get_data IMPORTING is_input  TYPE zclfi_mt_consultar_proposta.

    METHODS save_data.

    METHODS process_data EXPORTING es_output TYPE zclfi_mt_retorno_consulta_prop.

    METHODS select_data.

ENDCLASS.



CLASS ZCLFI_INTERFACE_CONS_PROPOSTA IMPLEMENTATION.


  METHOD constructor.
    DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 20.07.2023

    TRY.
        lo_param->m_get_single( EXPORTING iv_modulo = gc_param-modulo
                                         iv_chave1 = gc_param-chave1
                                         iv_chave2 = gc_param-chave2
                                         iv_chave3 = gc_param-tipodoc
                                IMPORTING ev_param = gv_tipo_doc ).

      CATCH zcxca_tabela_parametros INTO DATA(lo_cx).
        WRITE lo_cx->get_text( ).
    ENDTRY.
  ENDMETHOD.


  METHOD error_raise.
    RAISE EXCEPTION TYPE zcxca_erro_interface
      EXPORTING
        textid = VALUE #(
                          attr1 = is_ret-attr1
                          attr2 = is_ret-attr2
                          attr3 = is_ret-attr3
                          msgid = is_ret-msgid
                          msgno = is_ret-msgno
                          ).
  ENDMETHOD.


  METHOD executar.

    me->get_data( is_input = is_input ).

    me->save_data(  ).

    me->process_data( IMPORTING es_output = es_output ).

  ENDMETHOD.


  METHOD get_data.

    DATA: lv_contrato TYPE ztfi_contratocab-zproposta,
          lv_parcela  TYPE ztfi_contratopar-parcela,
          lv_rateio   TYPE ztfi_contratopar-rateio.

    gt_dados_cab = VALUE #( (  branch        = is_input-mt_consultar_proposta-j_1bbranch
                               kunnr         = is_input-mt_consultar_proposta-kunnr
                               zproposta     = is_input-mt_consultar_proposta-zcontrato
                               zcoord_filial = is_input-mt_consultar_proposta-zcoord_filial
                               zlsch         = is_input-mt_consultar_proposta-formapagamento
                               zfase         = is_input-mt_consultar_proposta-zfase
                               znome_cliente = is_input-mt_consultar_proposta-znome_cliente
                               zacordo       = is_input-mt_consultar_proposta-zacordo
                               zdt_emissao   = is_input-mt_consultar_proposta-zdataemissao
                               zmontante     = is_input-mt_consultar_proposta-zvalor
                               zaprovgmr     = is_input-mt_consultar_proposta-zaprovgmr
                               zaprova       = is_input-mt_consultar_proposta-zaprovacao
                               ztipoacao     = is_input-mt_consultar_proposta-ztipoacao
                               kostl         = is_input-mt_consultar_proposta-zkostl
                               gsber         = is_input-mt_consultar_proposta-zgsber
                               dtvencimento  = is_input-mt_consultar_proposta-datavencimento )  ).

    LOOP AT is_input-mt_consultar_proposta-lista_parcelas ASSIGNING FIELD-SYMBOL(<fs_parcela>).

      SPLIT <fs_parcela>-zcontrato AT '-' INTO lv_contrato
                                               lv_parcela
                                               lv_rateio.

      DATA(ls_dados_par) = VALUE ztfi_contratopar( branch         = is_input-mt_consultar_proposta-j_1bbranch
                                                   kunnr          = is_input-mt_consultar_proposta-kunnr
                                                   zproposta      = is_input-mt_consultar_proposta-zcontrato
                                                   zqtdparcelas   = <fs_parcela>-zparcela
                                                   stcd1          = <fs_parcela>-stcd1
                                                   zmes           = <fs_parcela>-zmes
                                                   zoperacao_inic = <fs_parcela>-zoperacaoinicio
                                                   zoperacao_fim  = <fs_parcela>-dataoperacaofim
                                                   zcodvendedor   = <fs_parcela>-zcodvendedor
                                                   zmeiopagame    = <fs_parcela>-zmeiopagame
                                                   zvalor         = <fs_parcela>-zmontanteparcela
                                                   zacordo        = <fs_parcela>-zacordo
                                                   znotafiscal    = <fs_parcela>-znotafiscal
                                                   ztipoacao      = <fs_parcela>-ztipoacao
                                                   zvalorparcela  = <fs_parcela>-zmontanteparcela
                                                   kostl          = <fs_parcela>-kostl
                                                   gsber          = <fs_parcela>-gsber
                                                   bzirk          = <fs_parcela>-regiaodevenda
                                                   vtweg          = <fs_parcela>-canaldistribuicao
                                                   spart          = <fs_parcela>-setordeatividade
                                                   rkeg_wwmt1     = <fs_parcela>-familiacl
                                                   werks          = <fs_parcela>-centro
                                                   parcela        = lv_parcela
                                                   rateio         = lv_rateio ).

      APPEND ls_dados_par TO gt_dados_par.

    ENDLOOP.
  ENDMETHOD.


  METHOD process_data.

    DATA: ls_docheader      TYPE bapiache09.

    DATA: lt_accountgl         TYPE bapiacgl09_tab,
          lt_accountreceivable TYPE bapiacar09_tab,
          lt_currencyamount    TYPE bapiaccr09_tab,
          lt_return            TYPE bapiret2_t,
          lt_parcelas          TYPE zclfi_dt_retorno_consulta__tab.

    DATA: lv_msg   TYPE bapi_msg,
          lv_xblnr TYPE xblnr,
          lv_belnr TYPE belnr_d,
          lv_erro  TYPE char1.

    me->select_data(  ).

    SORT: gt_dados_cab BY branch kunnr zproposta,
          gt_dados_par BY branch kunnr zproposta zqtdparcelas,
          gt_bsid      BY kunnr xblnr,
          gt_bsad      BY kunnr xblnr.

    LOOP AT gt_dados_par ASSIGNING FIELD-SYMBOL(<fs_dados_par>).

      CLEAR: lv_belnr,
             lv_erro.

      " Processa lançamento
      READ TABLE gt_dados_cab ASSIGNING FIELD-SYMBOL(<fs_dados_cab>)
                                            WITH KEY branch     = <fs_dados_par>-branch
                                                     kunnr      = <fs_dados_par>-kunnr
                                                     zproposta  = <fs_dados_par>-zproposta
                                                     BINARY SEARCH.

      IF sy-subrc IS INITIAL.

        lv_xblnr = |{ <fs_dados_par>-zproposta }-{ <fs_dados_par>-parcela }|.
        READ TABLE gt_bsid INTO DATA(ls_bsid)
                            WITH KEY kunnr = <fs_dados_cab>-kunnr
                                     xblnr = lv_xblnr
                                     BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_belnr = ls_bsid-belnr.
          lv_erro  = '0'.
        ELSE.
          READ TABLE gt_bsad INTO DATA(ls_bsad)
                              WITH KEY kunnr = <fs_dados_cab>-kunnr
                                       xblnr = lv_xblnr
                                       BINARY SEARCH.
          IF sy-subrc EQ 0.
            lv_belnr = ls_bsad-belnr.
            lv_erro  = '0'.
          ELSE.
            lv_erro  = '1'.
          ENDIF.
        ENDIF.

        lt_parcelas = VALUE #( BASE lt_parcelas ( kunnr     = <fs_dados_par>-kunnr
                                                  zcontrato = <fs_dados_par>-zproposta
                                                  proposta  = <fs_dados_par>-zproposta
                                                  parcela   = <fs_dados_par>-parcela
                                                  rateio    = <fs_dados_par>-rateio
                                                  belnr     = lv_belnr
                                                  erro      = lv_erro ) ).

*        es_output-mt_retorno_consulta_proposta-kunnr     = <fs_dados_par>-kunnr.
*        es_output-mt_retorno_consulta_proposta-zcontrato = <fs_dados_par>-zproposta.
*        es_output-mt_retorno_consulta_proposta-proposta  = <fs_dados_par>-zproposta.
*        es_output-mt_retorno_consulta_proposta-parcela   = <fs_dados_par>-parcela.
*        es_output-mt_retorno_consulta_proposta-rateio    = <fs_dados_par>-rateio.

*        lv_xblnr = |{ <fs_dados_par>-zacordo }-{ <fs_dados_par>-parcela }|.

      ENDIF.
    ENDLOOP.

    es_output-mt_retorno_consulta_proposta-retorno_consulta_proposta_sap[] = CORRESPONDING #( lt_parcelas[] ).

  ENDMETHOD.


  METHOD save_data.
    IF gt_dados_cab[] IS NOT INITIAL.
      MODIFY ztfi_contratocab FROM TABLE gt_dados_cab.
    ENDIF.

    IF gt_dados_par[] IS NOT INITIAL.
      MODIFY ztfi_contratopar FROM TABLE gt_dados_par.
    ENDIF.

    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD select_data.

    DATA: lr_xblnr TYPE RANGE OF bsid_view-xblnr.

    lr_xblnr = VALUE #( FOR <fs_dados_par> IN gt_dados_par
                       ( sign   = 'I'
                         option = 'EQ'
*                         low    = |{ <fs_dados_par>-zacordo }-{ <fs_dados_par>-parcela }| ) ).
                         low    = |{ <fs_dados_par>-zproposta }-{ <fs_dados_par>-parcela }| ) ).

    IF gt_dados_cab[] IS NOT INITIAL.

      SELECT bukrs,
             branch
        FROM j_1bbranch
         FOR ALL ENTRIES IN @gt_dados_cab
       WHERE branch = @gt_dados_cab-branch
        INTO TABLE @gt_branch.

      IF sy-subrc = 0.
        SORT gt_branch BY branch.
      ENDIF.

      READ TABLE gt_branch INTO DATA(ls_branch) INDEX 1.

      SELECT bukrs,
             kunnr,
             xblnr,
             belnr
        FROM bsid_view
         FOR ALL ENTRIES IN @gt_dados_cab
       WHERE blart = @gv_tipo_doc
         AND bukrs = @ls_branch-bukrs
         AND kunnr = @gt_dados_cab-kunnr
         AND xblnr IN @lr_xblnr
        INTO TABLE @gt_bsid.

      IF sy-subrc = 0.
        LOOP AT gt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>).
          <fs_bsid>-zproposta = <fs_bsid>-xblnr(10).
        ENDLOOP.
      ENDIF.

      SELECT s1~bukrs,
             s1~kunnr,
             s1~xblnr,
             s1~belnr
        FROM bsad_view AS s1
       INNER JOIN bkpf AS b1 ON s1~bukrs = b1~bukrs
                            AND s1~belnr = b1~belnr
                            AND s1~gjahr = b1~gjahr
         FOR ALL ENTRIES IN @gt_dados_cab
       WHERE s1~blart = @gv_tipo_doc
         AND s1~bukrs = @ls_branch-bukrs
         AND s1~kunnr = @gt_dados_cab-kunnr
         AND s1~xblnr IN @lr_xblnr
         AND b1~stblg = ''
        INTO TABLE @gt_bsad.

      IF sy-subrc = 0.
        LOOP AT gt_bsad ASSIGNING FIELD-SYMBOL(<fs_bsad>).
          <fs_bsad>-zproposta = <fs_bsad>-xblnr(10).
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
