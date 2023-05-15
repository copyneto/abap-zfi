"!<p>Classe processar Interface Processa Proposta</p>
"!<p><strong>Autor:</strong>Marcos Rubik</p>
"!<p><strong>Data:</strong> 17 de Março de 2022</p>
CLASS zclfi_interface_proc_proposta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS executar
      IMPORTING
        !is_input  TYPE zclfi_mt_criar_proposta
      EXPORTING
        !es_output TYPE zclfi_mt_criar_proposta_resp
      RAISING
        zcxca_erro_interface .
    METHODS constructor .
  PROTECTED SECTION.
PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_infos_aux,
      coscen  TYPE string,
      kostl   TYPE kostl,
      gsber   TYPE gsber,
      prctr   TYPE prctr,
      segment TYPE fb_segment,
    END OF ty_infos_aux .
  TYPES:
    tt_infos_aux TYPE TABLE OF ty_infos_aux .
  TYPES:
    BEGIN OF ty_j_1bbranch,
      bukrs  TYPE j_1bbranch-bukrs,
      branch TYPE j_1bbranch-branch,
    END OF ty_j_1bbranch .
  TYPES:
    tt_j_1bbranch TYPE TABLE OF ty_j_1bbranch .
  TYPES ty_reversao TYPE zi_fi_reversao_provisao_pdc .
  TYPES ty_reversao_popup TYPE zi_fi_reversao_provisao_popup .

  CONSTANTS:
    BEGIN OF gc_erros,
      interface TYPE string VALUE 'ZCLFI_CL_SI_RECEBER_CRIAR_PROP',
      metodo    TYPE string VALUE 'executar'                             ##NO_TEXT,
      classe    TYPE string VALUE 'ZCLFI_INTERFACE_PROC_PROPOSTA'        ##NO_TEXT,
    END OF gc_erros .
  CONSTANTS:
    BEGIN OF gc_param,
      modulo  TYPE ztca_param_par-modulo VALUE 'FI-AR',
      chave1  TYPE ztca_param_par-chave1 VALUE 'PDC',
      chave2  TYPE ztca_param_par-chave2 VALUE 'CRIARPROP',
      tipodoc TYPE ztca_param_par-chave3 VALUE 'TIPODOC',
      chave40 TYPE ztca_param_par-chave3 VALUE 'CHAVE40',
    END OF gc_param .
  DATA:
    gt_dados_cab TYPE TABLE OF ztfi_contratocab .
  DATA:
    gt_dados_par TYPE TABLE OF ztfi_contratopar .
  DATA gt_branch TYPE tt_j_1bbranch .
  DATA gt_info TYPE tt_infos_aux .
  DATA gv_tipo_doc TYPE blart .
  DATA gv_saknr TYPE saknr .
  CONSTANTS gc_error_id TYPE syst_msgid VALUE 'ZFI_CONTAB' ##NO_TEXT.
  CONSTANTS gc_msg_no_002 TYPE syst_msgno VALUE '002' ##NO_TEXT.
  CONSTANTS gc_error TYPE syst_msgty VALUE 'E' ##NO_TEXT.
  DATA:
    gt_dados_par_rateio TYPE TABLE OF zsfi_contratopar .



  TYPES:
    BEGIN OF ty_ref_info,
      bukrs TYPE bkpf-bukrs,
      belnr TYPE bkpf-belnr,
      gjahr TYPE bkpf-gjahr,
      xblnr TYPE bkpf-xblnr,
    END OF ty_ref_info .
  TYPES:
    tt_ty_ref_info TYPE TABLE OF ty_ref_info .

  DATA gt_ref_part TYPE tt_ty_ref_info .

  "! Return error raising
  METHODS error_raise
    IMPORTING
      !is_ret TYPE scx_t100key
    RAISING
      zcxca_erro_interface .
  METHODS get_data
    IMPORTING
      !is_input TYPE zclfi_mt_criar_proposta .
  METHODS save_data .
  METHODS process_data
    EXPORTING
      !es_output TYPE zclfi_mt_criar_proposta_resp .
  METHODS get_data_header
    IMPORTING
      !is_dados_par TYPE ztfi_contratopar
      !is_dados_cab TYPE ztfi_contratocab
    EXPORTING
      !es_docheader TYPE bapiache09 .
  METHODS select_data .
  METHODS add_data_accountgl
    IMPORTING
      !iv_item_no   TYPE posnr_acc
      !is_dados_par TYPE ztfi_contratopar
    EXPORTING
      !et_accountgl TYPE bapiacgl09_tab .
  METHODS add_data_accountreceivable
    IMPORTING
      !iv_item_no           TYPE posnr_acc
      !is_dados_par         TYPE ztfi_contratopar
      !is_docheader         TYPE bapiache09
    EXPORTING
      !et_accountreceivable TYPE bapiacar09_tab .
  METHODS add_data_currencyamount
    IMPORTING
      !iv_item_no        TYPE posnr_acc
      !iv_shkzg          TYPE shkzg
      !is_dados_par      TYPE ztfi_contratopar
    CHANGING
      !ct_currencyamount TYPE bapiaccr09_tab .
  METHODS get_data_provisao
    IMPORTING
      !is_docheader TYPE bapiache09
      !is_dados_par TYPE ztfi_contratopar
    EXPORTING
      !es_reversao  TYPE zi_fi_reversao_provisao_pdc .
  METHODS add_data_extension2
    IMPORTING
      !iv_item_no    TYPE posnr_acc
      !is_dados_par  TYPE ztfi_contratopar
    CHANGING
      !ct_extension2 TYPE bapiapoparex_tab .
  METHODS update_document
    IMPORTING
      !is_dados_par TYPE ztfi_contratopar
      !iv_key       TYPE bapiache09-obj_key .
ENDCLASS.



CLASS ZCLFI_INTERFACE_PROC_PROPOSTA IMPLEMENTATION.


  METHOD constructor.
    DATA(lo_param) = NEW zclca_tabela_parametros( ).

    TRY.
        lo_param->m_get_single( EXPORTING iv_modulo = gc_param-modulo
                                         iv_chave1 = gc_param-chave1
                                         iv_chave2 = gc_param-chave2
                                         iv_chave3 = gc_param-tipodoc
                                IMPORTING ev_param = gv_tipo_doc ).

        lo_param->m_get_single( EXPORTING iv_modulo = gc_param-modulo
                                         iv_chave1 = gc_param-chave1
                                         iv_chave2 = gc_param-chave2
                                         iv_chave3 = gc_param-chave40
                                IMPORTING ev_param = gv_saknr ).

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

    DATA: lt_rateio TYPE zctgfi_lista_rateio.

    gt_dados_cab = VALUE #( (  branch        = is_input-mt_criar_proposta-j_1bbranch
                               kunnr         = is_input-mt_criar_proposta-kunnr
                               zproposta     = is_input-mt_criar_proposta-zcontrato
                               zcoord_filial = is_input-mt_criar_proposta-zcoord_filial
                               zlsch         = is_input-mt_criar_proposta-formapagamento
                               zfase         = is_input-mt_criar_proposta-zfase
                               znome_cliente = is_input-mt_criar_proposta-znome_cliente
                               zacordo       = is_input-mt_criar_proposta-zacordo
                               zdt_emissao   = is_input-mt_criar_proposta-zdataemissao
                               zmontante     = is_input-mt_criar_proposta-zvalor
                               zaprovgmr     = is_input-mt_criar_proposta-zaprovgmr
                               zaprova       = is_input-mt_criar_proposta-zaprovacao
                               ztipoacao     = is_input-mt_criar_proposta-ztipoacao
                               kostl         = is_input-mt_criar_proposta-zkostl
                               gsber         = is_input-mt_criar_proposta-zgsber
                               dtvencimento  = is_input-mt_criar_proposta-datavencimento )  ).

    LOOP AT is_input-mt_criar_proposta-lista_parcelas ASSIGNING FIELD-SYMBOL(<fs_parcela>).

      SPLIT <fs_parcela>-zcontrato AT '-' INTO lv_contrato
                                               lv_parcela
                                               lv_rateio.

      DATA(ls_dados_par) = VALUE ztfi_contratopar(
                             branch        = <fs_parcela>-branch
*                             branch        = is_input-mt_criar_proposta-j_1bbranch
*                             kunnr         = is_input-mt_criar_proposta-kunnr
                             kunnr         = <fs_parcela>-kunnr
                             zproposta     = is_input-mt_criar_proposta-zcontrato
                             zqtdparcelas  = <fs_parcela>-zparcela
                             zlsch         = <fs_parcela>-zlsch
                             stcd1         = <fs_parcela>-stcd1
                             zmes          = <fs_parcela>-zmes
                             zoperacao_inic = <fs_parcela>-zoperacaoinicio
                             zoperacao_fim  = <fs_parcela>-dataoperacaofim
                             zcodvendedor  = <fs_parcela>-zcodvendedor
                             zmeiopagame   = <fs_parcela>-zmeiopagame
                             zvalor        = <fs_parcela>-zmontanteparcela
                             zacordo       = <fs_parcela>-zacordo
                             znotafiscal   = <fs_parcela>-znotafiscal
                             ztipoacao     = <fs_parcela>-ztipoacao
                             zvalorparcela = <fs_parcela>-zmontanteparcela
                             kostl         = <fs_parcela>-kostl
                             gsber         = <fs_parcela>-gsber
                             bzirk         = <fs_parcela>-regiaodevenda
                             vtweg         = <fs_parcela>-canaldistribuicao
                             spart         = <fs_parcela>-setordeatividade
                             rkeg_wwmt1    = <fs_parcela>-familiacl
                             werks         = <fs_parcela>-centro
                             parcela       = lv_parcela
                             rateio        = lv_rateio ).

      APPEND ls_dados_par TO gt_dados_par.

      LOOP AT <fs_parcela>-rateio_centro_lucro ASSIGNING FIELD-SYMBOL(<fs_rateio>). "#EC CI_NESTED

        DATA(ls_dados_rateio) = VALUE zsfi_lista_rateio(
                        prctr = <fs_rateio>-prctr
                        vv001 = <fs_rateio>-vv001 ).

        APPEND ls_dados_rateio TO lt_rateio.

      ENDLOOP.

      DATA(ls_dados_par_rateio) = VALUE zsfi_contratopar(
                             branch        = <fs_parcela>-branch
                             kunnr         = <fs_parcela>-kunnr
                             zproposta     = is_input-mt_criar_proposta-zcontrato
                             zqtdparcelas  = <fs_parcela>-zparcela
                             zlsch         = <fs_parcela>-zlsch
                             stcd1         = <fs_parcela>-stcd1
                             zmes          = <fs_parcela>-zmes
                             zoperacao_inic = <fs_parcela>-zoperacaoinicio
                             zoperacao_fim  = <fs_parcela>-dataoperacaofim
                             zcodvendedor  = <fs_parcela>-zcodvendedor
                             zmeiopagame   = <fs_parcela>-zmeiopagame
                             zvalor        = <fs_parcela>-zmontanteparcela
                             zacordo       = <fs_parcela>-zacordo
                             znotafiscal   = <fs_parcela>-znotafiscal
                             ztipoacao     = <fs_parcela>-ztipoacao
                             zvalorparcela = <fs_parcela>-zmontanteparcela
                             kostl         = <fs_parcela>-kostl
                             gsber         = <fs_parcela>-gsber
                             bzirk         = <fs_parcela>-regiaodevenda
                             vtweg         = <fs_parcela>-canaldistribuicao
                             spart         = <fs_parcela>-setordeatividade
                             rkeg_wwmt1    = <fs_parcela>-familiacl
                             werks         = <fs_parcela>-centro
                             parcela       = lv_parcela
                             lista_rateio  = lt_rateio ).

      APPEND ls_dados_par_rateio TO gt_dados_par_rateio.

      CLEAR: lt_rateio[].

    ENDLOOP.

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


  METHOD process_data.

    DATA: ls_docheader      TYPE bapiache09,
          ls_reversao       TYPE ty_reversao,
          ls_reversao_popup TYPE ty_reversao_popup.

    DATA: lt_accountgl         TYPE bapiacgl09_tab,
          lt_accountreceivable TYPE bapiacar09_tab,
          lt_currencyamount    TYPE bapiaccr09_tab,
          lt_extension2        TYPE bapiapoparex_tab,
          lt_return            TYPE bapiret2_t,
          lt_info              TYPE tt_infos_aux,
          lt_respost           TYPE zclfi_dt_criar_proposta_re_tab,
          lt_return_rever      TYPE bapiret2_t.

    DATA: lv_msg   TYPE bapi_msg.

*    SORT: gt_dados_cab BY branch kunnr zproposta,
*          gt_dados_par BY branch kunnr zproposta zqtdparcelas.

    SORT: gt_dados_par_rateio BY branch kunnr zproposta zqtdparcelas.

    me->select_data(  ).

*    LOOP AT gt_dados_cab ASSIGNING FIELD-SYMBOL(<fs_dados_cab>).
*      "Processa lançamento
*      READ TABLE gt_dados_par
*        ASSIGNING FIELD-SYMBOL(<fs_dados_par>)
*        WITH KEY branch     = <fs_dados_cab>-branch
*                 kunnr      = <fs_dados_cab>-kunnr
*                 zproposta  = <fs_dados_cab>-zproposta
*        BINARY SEARCH.

    LOOP AT gt_dados_par ASSIGNING FIELD-SYMBOL(<fs_dados_par>).

      CLEAR: ls_docheader,
             ls_reversao.

      FREE: lt_accountgl,
            lt_accountreceivable[],
            lt_extension2[],
            lt_currencyamount[],
            lt_return[],
            lt_return_rever[].


      READ TABLE gt_dados_cab ASSIGNING FIELD-SYMBOL(<fs_dados_cab>) INDEX 1.
      IF sy-subrc = 0.

        DATA(lv_parcela) = |{ <fs_dados_cab>-zproposta }-{ <fs_dados_par>-parcela }|.
        READ TABLE gt_ref_part ASSIGNING FIELD-SYMBOL(<fs_ref_part>) WITH KEY
                    xblnr = lv_parcela
                    BINARY SEARCH.
        IF sy-subrc = 0.

          CONCATENATE 'Parcela existe Documento' <fs_ref_part>-belnr
                                                 <fs_ref_part>-bukrs
                                                 <fs_ref_part>-gjahr INTO lv_msg SEPARATED BY space.

          lt_respost = VALUE #( BASE lt_respost ( erro      = lv_msg
                                                  parcela   = <fs_dados_par>-parcela
                                                  zcontrato = <fs_dados_par>-zproposta
                                                  proposta  = <fs_dados_par>-zproposta
                                                  rateio    = <fs_dados_par>-rateio
                                                  kunnr     = <fs_dados_par>-kunnr ) ).

        ELSE.

          me->get_data_header( EXPORTING is_dados_par = <fs_dados_par>
                                         is_dados_cab = <fs_dados_cab>
                               IMPORTING es_docheader = ls_docheader ).

          me->add_data_accountreceivable( EXPORTING iv_item_no           = '1'
                                                    is_dados_par         = <fs_dados_par>
                                                    is_docheader         = ls_docheader
                                          IMPORTING et_accountreceivable = lt_accountreceivable ) .

          me->add_data_currencyamount( EXPORTING iv_item_no       = '1'
                                                 iv_shkzg         = 'H'
                                                 is_dados_par     = <fs_dados_par>
                                       CHANGING ct_currencyamount = lt_currencyamount ).

          me->add_data_extension2( EXPORTING iv_item_no        = '1'
                                             is_dados_par      = <fs_dados_par>
                                   CHANGING  ct_extension2     = lt_extension2 ).

          me->add_data_accountgl( EXPORTING iv_item_no   = '2'
                                            is_dados_par = <fs_dados_par>
                                  IMPORTING et_accountgl = lt_accountgl ) .

          me->add_data_currencyamount( EXPORTING iv_item_no        = '2'
                                                 iv_shkzg          = 'S'
                                                 is_dados_par      = <fs_dados_par>
                                       CHANGING  ct_currencyamount = lt_currencyamount ).

          me->add_data_extension2( EXPORTING iv_item_no        = '2'
                                             is_dados_par      = <fs_dados_par>
                                   CHANGING  ct_extension2     = lt_extension2 ).

          NEW zclfi_exec_lancamento_desconto( )->executar(
               EXPORTING
                 iv_commit            = space
                 is_docheader         = ls_docheader
                 it_accountgl         = lt_accountgl
                 it_accountreceivable = lt_accountreceivable
                 it_extension2        = lt_extension2
                 it_currencyamount    = lt_currencyamount
               IMPORTING
                 ev_type           = DATA(lv_type)
                 ev_key            = DATA(lv_key)
                 ev_sys            = DATA(lv_sys)
               RECEIVING
                 rt_return         = lt_return ).

          IF NOT line_exists( lt_return[ type = 'E' ] ).
            me->get_data_provisao( EXPORTING is_docheader = ls_docheader
                                             is_dados_par = <fs_dados_par>
                                   IMPORTING es_reversao = ls_reversao ).

            READ TABLE gt_dados_par_rateio ASSIGNING FIELD-SYMBOL(<fs_dados_par_rateio>)
                                            WITH KEY branch       = <fs_dados_par>-branch
                                                     kunnr        = <fs_dados_par>-kunnr
                                                     zproposta    = <fs_dados_par>-zproposta
                                                     zqtdparcelas = <fs_dados_par>-zqtdparcelas
                                            BINARY SEARCH.
            IF sy-subrc IS INITIAL.

              READ TABLE gt_info ASSIGNING FIELD-SYMBOL(<fs_info>)
                                  WITH KEY kostl = <fs_dados_par_rateio>-kostl
                                  BINARY SEARCH.

              IF sy-subrc IS INITIAL.

                <fs_dados_par_rateio>-gsber = <fs_info>-gsber.

              ENDIF.

              NEW zclfi_reversao_provisao_events(  )->create_copa_post_cost_list(
                  EXPORTING
                    is_reversao       = ls_reversao
                    is_reversao_popup = ls_reversao_popup
                    is_contratopar    = <fs_dados_par_rateio>                " Cadastro de Parcelas
                  IMPORTING
                    et_return         = lt_return_rever ).

*          ELSE.

*            NEW zclfi_reversao_provisao_events(  )->create_copa_post_cost(
*                EXPORTING
*                  is_reversao       = ls_reversao
*                  is_reversao_popup = ls_reversao_popup
*                IMPORTING
*                  et_return         = lt_return_rever ).

            ENDIF.

*          es_output-mt_criar_proposta_resp-kunnr     = <fs_dados_par>-kunnr.
*          es_output-mt_criar_proposta_resp-zcontrato = <fs_dados_par>-zproposta.
*          es_output-mt_criar_proposta_resp-proposta  = <fs_dados_par>-zproposta.
*          es_output-mt_criar_proposta_resp-parcela   = <fs_dados_par>-parcela.
*          es_output-mt_criar_proposta_resp-rateio    = <fs_dados_par>-rateio.

            IF line_exists( lt_return_rever[ type = 'E' ] ).

              IF lines( lt_return_rever ) > 1.
                READ TABLE lt_return_rever INTO DATA(ls_return) INDEX 2.
              ELSE.
                ls_return = lt_return_rever[ type = 'E' ].
              ENDIF.

              FREE: lt_return_rever[].

              IF ls_return-message IS INITIAL.
                CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
                  EXPORTING
                    id         = ls_return-id
                    number     = ls_return-number
                    language   = sy-langu
                    textformat = 'ASC'
                    message_v1 = ls_return-message_v1
                    message_v2 = ls_return-message_v2
                    message_v3 = ls_return-message_v3
                    message_v4 = ls_return-message_v4
                  IMPORTING
                    message    = lv_msg.
              ELSE.
                lv_msg = ls_return-message.
              ENDIF.

              lt_respost = VALUE #( BASE lt_respost ( kunnr     = <fs_dados_par>-kunnr
                                                      zcontrato = <fs_dados_par>-zproposta
                                                      proposta  = <fs_dados_par>-zproposta
                                                      parcela   = <fs_dados_par>-parcela
                                                      rateio    = <fs_dados_par>-rateio
                                                      erro      = lv_msg ) ).

            ELSE.

              update_document( EXPORTING is_dados_par = <fs_dados_par>
                                         iv_key       = lv_key ).

              lt_respost = VALUE #( BASE lt_respost ( kunnr     = <fs_dados_par>-kunnr
                                                      zcontrato = <fs_dados_par>-zproposta
                                                      proposta  = <fs_dados_par>-zproposta
                                                      parcela   = <fs_dados_par>-parcela
                                                      rateio    = <fs_dados_par>-rateio
                                                      belnr     = lv_key(10) ) ).

*            es_output-mt_criar_proposta_resp-belnr = lv_key(10).
            ENDIF.

          ELSE.

            IF lines( lt_return ) > 1.
              READ TABLE lt_return INTO ls_return INDEX 2.

              IF ls_return-type = 'W' AND ls_return-id = 'FICUSTOM'.
                DELETE lt_return WHERE type = 'E' AND number = '609'. "#EC CI_STDSEQ
                READ TABLE lt_return INTO ls_return WITH KEY type = 'E'. "#EC CI_STDSEQ
              ENDIF.

            ELSE.
              ls_return = lt_return[ type = 'E' ].
            ENDIF.

            IF ls_return-message IS INITIAL.
              CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
                EXPORTING
                  id         = ls_return-id
                  number     = ls_return-number
                  language   = sy-langu
                  textformat = 'ASC'
                  message_v1 = ls_return-message_v1
                  message_v2 = ls_return-message_v2
                  message_v3 = ls_return-message_v3
                  message_v4 = ls_return-message_v4
                IMPORTING
                  message    = lv_msg.
            ELSE.
              lv_msg = ls_return-message.
            ENDIF.

            lt_respost = VALUE #( BASE lt_respost ( erro      = lv_msg
                                                    parcela   = <fs_dados_par>-parcela
                                                    zcontrato = <fs_dados_par>-zproposta
                                                    proposta  = <fs_dados_par>-zproposta
                                                    rateio    = <fs_dados_par>-rateio
                                                    kunnr     = <fs_dados_par>-kunnr ) ).

*            es_output-mt_criar_proposta_resp-erro = lv_msg.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF gt_dados_par[] IS INITIAL.
      MESSAGE ID gc_error_id TYPE gc_error NUMBER gc_msg_no_002 INTO lv_msg.
      lt_respost = VALUE #( BASE lt_respost ( erro = lv_msg ) ).
    ENDIF.

    es_output-mt_criar_proposta_resp-retorno_provisionamento_parcel[] = CORRESPONDING #( lt_respost[] ).

  ENDMETHOD.


  METHOD get_data_header.

    READ TABLE gt_branch
     ASSIGNING FIELD-SYMBOL(<fs_branch>)
    WITH KEY branch = is_dados_cab-branch
    BINARY SEARCH.

    CHECK sy-subrc = 0.

    es_docheader-pstng_date = CONV dats( is_dados_par-zoperacao_inic ).
    IF es_docheader-pstng_date > sy-datum.
      es_docheader-doc_date = sy-datum.
    ELSE.
      es_docheader-doc_date = es_docheader-pstng_date.
    ENDIF.
    es_docheader-username     = sy-uname.
    es_docheader-fisc_year    = es_docheader-pstng_date(4).
    es_docheader-fis_period   = es_docheader-pstng_date+4(2).
    es_docheader-doc_type     = gv_tipo_doc.
    es_docheader-comp_code    = <fs_branch>-bukrs.
*    es_docheader-ref_doc_no   = |{ is_dados_par-zacordo }-{ is_dados_par-parcela }|.
    es_docheader-ref_doc_no   = |{ is_dados_par-zproposta }-{ is_dados_par-parcela }|.
    es_docheader-header_txt   = |{ is_dados_par-bzirk }-{ is_dados_par-zproposta }|.
    es_docheader-glo_ref2_hd  = |CD{ is_dados_par-vtweg }/SA{ is_dados_par-spart }/{ is_dados_par-kostl }|.

  ENDMETHOD.


  METHOD select_data.

    DATA lr_ref_doc TYPE RANGE OF bkpf-xblnr.

    READ TABLE gt_dados_cab ASSIGNING FIELD-SYMBOL(<fs_dados_cab>) INDEX 1.

    lr_ref_doc = VALUE #( FOR ls_dados_par IN gt_dados_par
                          ( sign = 'I'
                            option = 'EQ'
                            low = |{ <fs_dados_cab>-zproposta }-{ ls_dados_par-parcela }| ) ).


    IF lr_ref_doc IS NOT INITIAL.

      CLEAR: gt_ref_part.
      SELECT bukrs,
             belnr,
             gjahr,
             xblnr
            FROM bkpf
        INTO TABLE @gt_ref_part
        WHERE xblnr IN @lr_ref_doc.

      SORT: gt_ref_part BY xblnr.
      DELETE ADJACENT DUPLICATES FROM gt_ref_part COMPARING xblnr.

    ENDIF.



    IF gt_dados_cab[] IS NOT INITIAL.
      SELECT bukrs
             branch
         FROM j_1bbranch
         INTO TABLE gt_branch
         FOR ALL ENTRIES IN gt_dados_cab
         WHERE branch = gt_dados_cab-branch.
      IF sy-subrc = 0.
        SORT gt_branch BY branch.
      ENDIF.
    ENDIF.

    gt_info = VALUE #( FOR <fs_dados_par_val> IN gt_dados_par ( coscen = CONV string( <fs_dados_par_val>-kostl )
                                                                kostl  = <fs_dados_par_val>-kostl ) ).

    NEW zclfi_interface_exec_lanc_desc(  )->get_info_auxiliares( CHANGING ct_info = gt_info ).

    SORT gt_info BY kostl.

  ENDMETHOD.


  METHOD add_data_accountreceivable.
    DATA: lv_gsber TYPE gsber.

    READ TABLE gt_info
         ASSIGNING FIELD-SYMBOL(<fs_info>)
      WITH KEY kostl = is_dados_par-kostl
      BINARY SEARCH.

    CHECK sy-subrc = 0.

    lv_gsber = <fs_info>-gsber.

    APPEND VALUE #(  itemno_acc = iv_item_no
                     customer   = is_dados_par-kunnr
                     pmnt_block = 'A'
                     pymt_meth  = is_dados_par-zlsch
                     bline_date = is_docheader-doc_date
                     sp_gl_ind  = 'C'
                     ref_key_1  = is_dados_par-werks
*                     alloc_nmbr = |PONTUAL-{ is_dados_par-zproposta }|
                     alloc_nmbr = |AC-{ is_dados_par-zacordo }|
                     item_text  = |PROP PONTUAL-{ is_dados_par-zacordo }-{ is_dados_par-parcela }|
                     bus_area   = lv_gsber )
           TO et_accountreceivable.

  ENDMETHOD.


  METHOD add_data_currencyamount.
    APPEND VALUE #( itemno_acc = iv_item_no
                     currency   = 'BRL'
                     amt_doccur = SWITCH #( iv_shkzg WHEN 'H' THEN ( is_dados_par-zvalorparcela * -1 ) ELSE is_dados_par-zvalorparcela ) )
           TO ct_currencyamount.
  ENDMETHOD.


  METHOD add_data_accountgl.
    DATA: lv_prctr TYPE prctr,
          lv_gsber TYPE gsber.

    READ TABLE gt_info
         ASSIGNING FIELD-SYMBOL(<fs_info>)
      WITH KEY kostl = is_dados_par-kostl
      BINARY SEARCH.

    CHECK sy-subrc = 0.

    lv_gsber = <fs_info>-gsber.
    lv_prctr = <fs_info>-prctr.

    APPEND VALUE #( itemno_acc = '2'
                     gl_account = gv_saknr
                     item_text  = |PROP PONTUAL-{ is_dados_par-zacordo }-{ is_dados_par-parcela }|
*                     alloc_nmbr = |PONTUAL-{ is_dados_par-zproposta }|
                     alloc_nmbr = |AC-{ is_dados_par-zacordo }|
                     plant      = is_dados_par-werks
                     costcenter = is_dados_par-kostl
                     bus_area   = lv_gsber
                     profit_ctr = lv_prctr
                     segment    = <fs_info>-segment )
           TO et_accountgl.

  ENDMETHOD.


  METHOD get_data_provisao.
    es_reversao-companycode                     = is_docheader-comp_code.
    es_reversao-balancetransactioncurrency      = 'BRL'.
    es_reversao-documentdate                    = is_docheader-pstng_date.
    es_reversao-customer                        = is_dados_par-kunnr.
    es_reversao-reference2indocumentheader+2(2) = is_dados_par-vtweg.
    es_reversao-accountingdocumentheadertext    = is_dados_par-bzirk.
    es_reversao-profitcenter                    = is_dados_par-rkeg_wwmt1.
    es_reversao-plant                           = is_dados_par-werks.
    es_reversao-amountinbalancetransaccrcy      = is_dados_par-zvalorparcela.

  ENDMETHOD.


  METHOD add_data_extension2.
    APPEND VALUE #( structure  = 'BUPLA'
                    valuepart1 = iv_item_no
                    valuepart2 = is_dados_par-branch )
           TO ct_extension2.
  ENDMETHOD.


  METHOD update_document.

    DATA: lt_accchg TYPE STANDARD TABLE OF accchg.

    DATA: lv_obzei TYPE bseg-obzei,
          lv_buzei TYPE bseg-buzei,
          lv_bukrs TYPE  bukrs,
          lv_belnr TYPE  belnr_d,
          lv_gjahr TYPE  gjahr.

    CONSTANTS: lc_fdname TYPE fieldname  VALUE 'XREF2_HD',
               lc_xref1  TYPE fieldname  VALUE 'XREF1_HD',
               lc_cd     TYPE char2      VALUE 'CD',
               lc_sa     TYPE char3      VALUE '/SA',
               lc_barra  TYPE char1      VALUE '/',
               lc_obzei  TYPE bseg-obzei VALUE '000',
               lc_buzei  TYPE bseg-buzei VALUE '001'.

    " XREF1_HD
    lt_accchg[] = VALUE #( BASE lt_accchg ( fdname = lc_xref1
                                            newval = is_dados_par-rateio ) ).

    " XREF2_HD
    lt_accchg[] = VALUE #( BASE lt_accchg ( fdname = lc_fdname
                                            newval = |{ lc_cd }{ is_dados_par-vtweg }{ lc_sa }{ is_dados_par-spart }{ lc_barra }{ is_dados_par-kostl }| ) ).

    lv_obzei = lc_obzei.
    lv_buzei = lc_buzei.
    lv_bukrs = iv_key+10(4).
    lv_belnr = iv_key(10).
    lv_gjahr = iv_key+14(4).

    WAIT UP TO 1 SECONDS.

    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        i_obzei              = lv_obzei
        i_buzei              = lv_buzei
        x_lock               = abap_true
        i_bukrs              = lv_bukrs
        i_belnr              = lv_belnr
        i_gjahr              = lv_gjahr
        i_upd_fqm            = abap_true
      TABLES
        t_accchg             = lt_accchg
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.

    IF sy-subrc IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
