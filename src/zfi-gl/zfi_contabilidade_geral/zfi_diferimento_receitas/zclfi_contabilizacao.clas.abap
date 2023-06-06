"!<p><h2>Classe para manipular contabilização</h2></p>
"!<p><strong>Autor:</strong>Thiago da Graça</p>
"!<p><strong>Data:</strong>10/02/2021</p>
CLASS zclfi_contabilizacao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      ty_t_header   TYPE TABLE OF zsfi_mercado_header WITH EMPTY KEY,
      ty_t_item     TYPE TABLE OF zsfi_mercado_item,
      ty_rang_bukrs TYPE RANGE OF bukrs,
      ty_rang_budat TYPE RANGE OF budat.

    DATA gr_bukrs       TYPE REF TO data .
    DATA gr_dtsel       TYPE REF TO data .
    DATA gv_endfunction TYPE char01.
    DATA gv_ZFMFI_ESTORNO_DOC        TYPE char05.
    DATA gv_ZFMFI_CONTABILIZACAO     TYPE char05.
    DATA gv_ZFMFI_ZTFI_LOG_DIF       TYPE char05.
    DATA gv_ZFMFI_ATUALIZA_DADOS_TM  TYPE char05.
    data gv_ZFMFI_ATUALIZA_TM        TYPE char05.

    CLASS-METHODS:

      "! Cria instancia e preenche parametros de entrada
      "! @parameter ro_instance  |Classe instanciada
      get_instance

        RETURNING
          VALUE(ro_instance) TYPE REF TO zclfi_contabilizacao .


    "! Executa contabilização
    "! @parameter iv_simular   | Botão simular?
    "! @parameter rt_mensagens | Retorna mensagens
    METHODS build
      IMPORTING
        iv_simular          TYPE abap_bool OPTIONAL
        iv_merc_int         TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(rt_mensagens) TYPE bapiret2_tab.

    METHODS
      diferimento
    RETURNING
        VALUE(rt_mensagens) TYPE bapiret2_tab..

    "! Metodo para executar BAPI document post
    "! @parameter p_task | Parâmetro standard
    METHODS task_finish_cont
      IMPORTING
        !p_task TYPE clike.

    "! Metodo para executar BAPI estorno
    "! @parameter p_task | Parâmetro standard
    METHODS task_finish_est
      IMPORTING
        !p_task TYPE clike .

    "! Metodo para salvar dados TM
    "! @parameter p_task | Parâmetro standard
    METHODS task_finish_tm
      IMPORTING
        !p_task TYPE clike .

    "! Metodo para executar BAPI estorno
    "! @parameter p_task | Parâmetro standard
    METHODS task_finish_log
      IMPORTING
        !p_task TYPE clike .

    "! Seta os valores
    "! @parameter it_header    |Tabela de cabeçalho
    "! @parameter it_item      |Tabela de item
    "! @parameter iv_dtlanc    |Data de lançamento
    "! @parameter iv_dtestorno |Data de estorno
    "! @parameter iv_app       |Execução pelo APP
    METHODS set_ref_data
      IMPORTING
        it_header    TYPE ty_t_header   OPTIONAL
        it_item      TYPE ty_t_item     OPTIONAL
        iv_dtlanc    TYPE datum         OPTIONAL
        iv_dtestorno TYPE datum         OPTIONAL
        iv_app       TYPE abap_bool     OPTIONAL.


    METHODS save.
  PROTECTED SECTION.
private section.

  types:
*    DATA gs_documentheader TYPE bapiache09.
*    DATA gt_accountgl      TYPE bapiacgl09_tab.
*    DATA gt_currencyamount TYPE bapiaccr09_tab.
*    DATA gt_accountreceivable TYPE bapiacar09_tab.
    BEGIN OF ty_param,
        bukrs     TYPE ty_rang_bukrs,
        budat     TYPE ty_rang_budat,
        belnr     TYPE belnr_d,
        dtlanc    TYPE datum,
        dtestorno TYPE datum,
        app       TYPE abap_bool,
      END OF ty_param .
  types:
*      BEGIN OF ty_log,
*        bukrs    TYPE bukrs,
*        belnr    TYPE belnr_d,
*        gjahr    TYPE gjahr,
*        contador TYPE numc04,
*        tp_bapi  TYPE char20,
*        text     TYPE ze_descricao_status,
*      END OF ty_log,
    ty_t_log TYPE TABLE OF ztfi_log_dif_msg .
  types:
    BEGIN OF ty_log_impostos,
        bukrs      TYPE bukrs,
        hkont_from TYPE hkont,
        gsber      TYPE gsber,
        bupla      TYPE bupla,
        prctr      TYPE prctr,
        gjahr      TYPE gjahr,
        log        TYPE ztfi_log_dif_msg,
      END OF ty_log_impostos .
  types:
    BEGIN OF ty_log_receita,
        bukrs    TYPE bukrs,
        gjahr    TYPE gjahr,
        kunnr    TYPE kunnr,
        hkont_to TYPE hkont,
        gsber    TYPE gsber,
        bupla    TYPE bupla,
        prctr    TYPE prctr,
        log      TYPE ztfi_log_dif_msg,
      END OF ty_log_receita .
  types:
    BEGIN OF ty_cliente_receita,
        moeda    TYPE waers,
        kursf    TYPE char20,
        bukrs    TYPE bukrs,
        kunnr    TYPE kunnr,
        hkont_to TYPE hkont,
        gsber    TYPE gsber,
        bupla    TYPE bupla,
        prctr    TYPE prctr,
        dmbtr    TYPE dmbtr,
      END OF ty_cliente_receita .
  types:
    BEGIN OF ty_razao,
        moeda    TYPE waers,
        kursf    TYPE char20,
        bukrs    TYPE bukrs,
        hkont_to TYPE hkont,
        gsber    TYPE gsber,
        bupla    TYPE bupla,
        prctr    TYPE prctr,
        dmbtr    TYPE dmbtr,
      END OF ty_razao .
  types:
    BEGIN OF ty_cliente_receita_doc,
        moeda     TYPE waers,
        kursf     TYPE kursf,
        bukrs     TYPE bukrs,
        kunnr     TYPE kunnr,
        gsber     TYPE gsber,
        bupla     TYPE bupla,
        prctr     TYPE prctr,
        gjahr     TYPE gjahr,
        belnr     TYPE belnr_d,
        gjahr_rec TYPE gjahr,
        belnr_rec TYPE belnr_d,
      END OF ty_cliente_receita_doc .
  types:
    BEGIN OF ty_razao_doc,
        moeda      TYPE waers,
        kursf      TYPE kursf,
        bukrs      TYPE bukrs,
        hkont_from TYPE hkont,
        gsber      TYPE gsber,
        bupla      TYPE bupla,
        prctr      TYPE prctr,
        gjahr      TYPE gjahr,
        belnr      TYPE belnr_d,
        gjahr_raz  TYPE gjahr,
        belnr_raz  TYPE belnr_d,
      END OF ty_razao_doc .
  types:
    BEGIN OF ty_cliente_receita_ret,
        bukrs     TYPE bukrs,
        kunnr     TYPE kunnr,
        gsber     TYPE gsber,
        bupla     TYPE bupla,
        prctr     TYPE prctr,
        gjahr_rec TYPE gjahr,
        belnr_rec TYPE belnr_d,
      END OF ty_cliente_receita_ret .
  types:
    BEGIN OF ty_razao_ret,
        bukrs      TYPE bukrs,
        hkont_from TYPE hkont,
        gsber      TYPE gsber,
        bupla      TYPE bupla,
        prctr      TYPE prctr,
        gjahr_raz  TYPE gjahr,
        belnr_raz  TYPE belnr_d,
      END OF ty_razao_ret .
  types:
    BEGIN OF ty_sum_doc,
        bukrs TYPE bukrs,
        belnr TYPE belnr_d,
        gjahr TYPE gjahr,
      END OF ty_sum_doc .
  types:
    BEGIN OF ty_doc_proc,
        bukrs TYPE bukrs,
        belnr TYPE belnr_d,
        gjahr TYPE gjahr,
        moeda TYPE waers,
        kursf TYPE kursf,
      END OF ty_doc_proc .
  types:
    BEGIN OF ty_agrup,
        moeda      TYPE waers,
        kursf      TYPE kursf,
      end of ty_agrup .

  class-data GS_PARAM type TY_PARAM .
  class-data GO_INSTANCE type ref to ZCLFI_CONTABILIZACAO .
  class-data:
    gt_de_para_hkont TYPE SORTED TABLE OF ztfi_defrece_dep WITH UNIQUE KEY hkont_from .
  class-data:
    gt_de_para_hkont_con TYPE SORTED TABLE OF ztfi_defrece_con WITH UNIQUE KEY hkont_from hkont_contra .
  data GT_HEADER type TY_T_HEADER .
  data GT_ITEM type TY_T_ITEM .
  data GT_LOG_MSG type TY_T_LOG .
  data:
    gt_log_impostos TYPE TABLE OF ty_log_impostos .
  data:
    gt_log_receita  TYPE TABLE OF ty_log_receita .
  data GT_RETURN type BAPIRET2_TAB .
  data GT_RAZAO_RETURN type BAPIRET2_TAB .
  data GT_RECEITA_RETURN type BAPIRET2_TAB .
  data GT_ESTORNO_RETURN type BAPIRET2_TAB .
  data:
    gt_sum_cliente_receita TYPE TABLE OF ty_cliente_receita .
  data:
    gt_sum_razao           TYPE TABLE OF ty_razao .
  data:
    gt_sum_doc             TYPE TABLE OF ty_sum_doc .
  data:
    gt_cliente_receita_ret TYPE TABLE OF ty_cliente_receita_ret .
  data:
    gt_razao_ret           TYPE TABLE OF ty_razao_ret .
  data:
    gt_doc_proc            TYPE TABLE OF ty_doc_proc .
  data:
    gt_agrup               type table of ty_agrup .
  data GT_MSG_RETORNO type BAPIRET2_TAB .
  data GV_DOC_REV type BELNR_D .
  data GV_ANO_REV type GJAHR .

    "! Seleciona dados do mercado externo
  methods GET_DATA_MERC_EXT .
    "! Seleciona dados do mercado interno
  methods GET_DATA_MERC_INT .
    "! Sumariza itens
    "! @parameter rt_mensagens | Retorna mensagens
  methods SUMARIZA
    returning
      value(RT_MENSAGENS) type BAPIRET2_TAB .
    "! Processa contabilização
    "! @parameter iv_simular   | Botão simular?
    "! @parameter rt_mensagens | Retorna mensagens
  methods PROCESSA_CONTABILIZACAO
    importing
      !IV_SIMULAR type ABAP_BOOL optional
    returning
      value(RT_MENSAGENS) type BAPIRET2_TAB .
    "! Verifica se BAPI esta com erros
    "! @parameter is_documentheader    | Estrutura do header
    "! @parameter ct_accountgl         | Tabela inf. conta
    "! @parameter it_currencyamount    | Tabela inf. valor
    "! @parameter it_accountreceivable | Tabela inf. conta a receber
    "! @parameter ct_mensagens         | Retorna mensagens
  methods CHECK_BAPI
    importing
      !IS_DOCUMENTHEADER type BAPIACHE09 optional
      !IT_CURRENCYAMOUNT type BAPIACCR09_TAB optional
      !IT_ACCOUNTRECEIVABLE type BAPIACAR09_TAB optional
    changing
      !CT_ACCOUNTGL type BAPIACGL09_TAB optional
      !CT_MENSAGENS type BAPIRET2_TAB optional
      !CT_EXTENSION2 type T_BAPIPAREX optional .
    "! Processa BAPI document post
    "! @parameter is_documentheader    | Estrutura do header
    "! @parameter it_accountgl         | Tabela inf. conta
    "! @parameter it_currencyamount    | Tabela inf. valor
    "! @parameter it_accountreceivable | Tabela inf. conta a receber
  methods PROCESSA_BAPI_DOCUMENT
    importing
      !IS_DOCUMENTHEADER type BAPIACHE09
      !IT_ACCOUNTGL type BAPIACGL09_TAB optional
      !IT_CURRENCYAMOUNT type BAPIACCR09_TAB
      !IT_ACCOUNTRECEIVABLE type BAPIACAR09_TAB optional
      !IT_EXTENSION2 type T_BAPIPAREX optional
    exporting
      !ET_MENSAGENS type BAPIRET2_TAB .
    "! Processa BAPI retorno
    "! @parameter iv_empresa   | Empresa
    "! @parameter iv_doc       | Documento
    "! @parameter iv_ano       | Ano
    "! @parameter iv_dtestorno | Data estorno
    "! @parameter iv_periodo   | Periodo
  methods PROCESSA_BAPI_ESTORNO
    importing
      !IV_EMPRESA type BUKRS
      !IV_DOC type BELNR_D
      !IV_ANO type GJAHR
      !IV_DTESTORNO type DATUM
      !IV_PERIODO type MONAT
    exporting
      !EV_DOC_REV type BELNR_D
      !EV_ANO_REV type GJAHR .
    "! Prepara dados para execução das BAPI's
    "! @parameter iv_simular   | Botão Simular?
    "! @parameter rt_mensagens | Retorna mensagens
  methods PREPARA_DADOS
    importing
      !IV_SIMULAR type ABAP_BOOL optional
      !IV_MOEDA type WAERS
      !IV_KURSF type KURSF
    returning
      value(RT_MENSAGENS) type BAPIRET2_TAB .
  methods AGRUPADOR
    importing
      !IV_SIMULAR type ABAP_BOOL optional
    returning
      value(RT_MENSAGENS) type BAPIRET2_TAB .
    "! Salva Log
  methods SAVE_LOG .
    "! Busca unidade de frete
    "! @parameter rt_return | Retorna tabela com unidades de frete
  methods GET_UNID_FRETE
    returning
      value(RT_RETURN) type ZCTGFI_REM_UNID_FRETE .
    "! Cadastra deferimento
    "! @parameter iv_unid_frete |Unidade de frete
    "! @parameter iv_preventr   |Dias
    "! @parameter iv_doc_date   |Data do documento
  methods SET_DEFERIMENTO
    importing
      !IV_UNID_FRETE type VBELN
      !IV_PREVENTR type INT1
      !IV_DOC_DATE type DATUM .
    "! Formata as mensages de retorno
    "! @parameter ct_return | Mensagens de retorno
  methods FORMAT_MESSAGE
    changing
      !CT_RETURN type BAPIRET2_T .
ENDCLASS.



CLASS ZCLFI_CONTABILIZACAO IMPLEMENTATION.


  METHOD get_instance.
    IF ( go_instance IS INITIAL ).
      go_instance = NEW zclfi_contabilizacao( ).
    ENDIF.

    ro_instance    = go_instance.

  ENDMETHOD.


  METHOD build.
    CLEAR me->gt_return.

    IF gs_param-app IS INITIAL.
      me->get_data_merc_ext(  ).
    ENDIF.

    rt_mensagens = me->processa_contabilizacao( iv_simular ).


  ENDMETHOD.


  METHOD get_data_merc_ext.

    CLEAR: me->gt_header,
           me->gt_item.

    DATA: lt_header_aux TYPE TABLE OF zsfi_mercado_header WITH EMPTY KEY,
          lt_item_aux   TYPE TABLE OF zsfi_mercado_item.

    SELECT *
    FROM zi_fi_merc_ext_h
    WHERE empresa IN @gs_param-bukrs
    AND   datalancamento IN @gs_param-budat
    INTO TABLE @DATA(lt_header).              "#EC CI_ALL_FIELDS_NEEDED

    MOVE-CORRESPONDING lt_header   TO lt_header_aux.

    IF lt_header_aux IS NOT INITIAL.

      SELECT empresa, numdoc, ano,
             item, cliente, conta,
             divisao, atribuicao, textitem,
             creddeb, localnegocio, centrolucro,
             centrocusto, segmento, moeda, valor
      FROM zi_fi_merc_ext_i
      FOR ALL ENTRIES IN @lt_header_aux
      WHERE empresa = @lt_header_aux-empresa
      AND   numdoc  = @lt_header_aux-numdoc
      AND   ano     = @lt_header_aux-ano
      INTO TABLE @DATA(lt_item).

      MOVE-CORRESPONDING lt_item   TO lt_item_aux.

      APPEND LINES OF lt_header_aux TO me->gt_header.
      APPEND LINES OF lt_item_aux   TO me->gt_item.

    ENDIF.
  ENDMETHOD.


  METHOD processa_contabilizacao.

    rt_mensagens = me->sumariza(  ).

    CHECK NOT line_exists( rt_mensagens[ type = 'E' ] ). "#EC CI_STDSEQ

    IF iv_simular IS INITIAL.
      rt_mensagens = me->agrupador( abap_true ).
      CHECK NOT line_exists( rt_mensagens[ type = 'E' ] ).
      CLEAR rt_mensagens.
      rt_mensagens = me->agrupador( abap_false ).
    ELSE.
      rt_mensagens = me->agrupador( abap_true ).
    ENDIF.


  ENDMETHOD.


  METHOD sumariza.

    TYPES:
      BEGIN OF ty_kunnr_belnr,
        empresa TYPE bukrs,
        numdoc  TYPE belnr_d,
        ano     TYPE gjahr,
        cliente TYPE kunnr,
      END OF ty_kunnr_belnr,
      BEGIN OF ty_conta,
        conta TYPE hkont,
      END OF ty_conta,
      BEGIN OF ty_doc,
        empresa TYPE bukrs,
        numdoc  TYPE belnr_d,
        ano     TYPE gjahr,
      END OF ty_doc.      .

    DATA: lt_kunnr_belnr         TYPE SORTED TABLE OF ty_kunnr_belnr WITH UNIQUE KEY empresa numdoc ano cliente,
          ls_kunnr_belnr         TYPE ty_kunnr_belnr,
          ls_sum_razao           TYPE ty_razao,
          ls_sum_cliente_receita TYPE ty_cliente_receita,
          lt_conta               TYPE TABLE OF ty_conta,
          lt_doc                 TYPE TABLE OF ty_doc.

    IF gt_item IS NOT INITIAL.
      CLEAR: lt_conta, lt_doc.
      LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
        APPEND VALUE #( conta = <fs_item>-conta ) TO lt_conta.
        APPEND VALUE #( empresa = <fs_item>-empresa
                        numdoc  = <fs_item>-numdoc
                        ano     = <fs_item>-ano ) TO lt_doc.
      ENDLOOP.

      SORT lt_conta. DELETE ADJACENT DUPLICATES FROM lt_conta.
      SORT lt_doc. DELETE ADJACENT DUPLICATES FROM lt_doc.

      SELECT *
        FROM ztfi_defrece_dep
        FOR ALL ENTRIES IN @lt_conta
        WHERE hkont_from = @lt_conta-conta
        INTO TABLE @gt_de_para_hkont.

      SELECT hkont_contra
        FROM ztfi_defrece_con
        FOR ALL ENTRIES IN @lt_conta
        WHERE hkont_from = @lt_conta-conta
        INTO TABLE @DATA(lt_hkont_con).

      SELECT bukrs, belnr, gjahr, buzei, bschl, hkont, bupla, prctr, koart, dmbtr, gsber, wrbtr, pswsl, pswbt, kunnr
        FROM bseg
        FOR ALL ENTRIES IN @lt_doc
        WHERE bukrs = @lt_doc-empresa
          AND belnr = @lt_doc-numdoc
          AND gjahr = @lt_doc-ano
          INTO TABLE @DATA(lt_bseg).

      SELECT bukrs, belnr, gjahr, waers, kursf
        FROM bkpf
        FOR ALL ENTRIES IN @lt_doc
        WHERE bukrs = @lt_doc-empresa
          AND belnr = @lt_doc-numdoc
          AND gjahr = @lt_doc-ano
          INTO TABLE @DATA(lt_bkpf).


      SELECT rbukrs, docnr, ryear, buzei, bschl, racct, rbusa, prctr, wsl, docln
       FROM faglflexa
       FOR ALL ENTRIES IN  @lt_doc
         WHERE ryear = @lt_doc-ano
           AND docnr = @lt_doc-numdoc
           AND rldnr = '0L'
           AND rbukrs = @lt_doc-empresa
           INTO TABLE @DATA(lt_faglflexa).

      CLEAR: lt_conta.

      LOOP AT lt_faglflexa ASSIGNING FIELD-SYMBOL(<fs_fagl>).
        CHECK NOT line_exists( gt_de_para_hkont[ hkont_from = <fs_fagl>-racct ] ).
        APPEND <fs_fagl>-racct TO lt_conta.
      ENDLOOP.

      SORT lt_conta. DELETE ADJACENT DUPLICATES FROM lt_conta.

      IF lt_conta IS NOT INITIAL.
        SELECT *
        FROM ztfi_defrece_dep
        APPENDING TABLE gt_de_para_hkont
        FOR ALL ENTRIES IN lt_conta
        WHERE hkont_from = lt_conta-conta.
      ENDIF.

*      DELETE ADJACENT DUPLICATES FROM gt_de_para_hkont COMPARING ALL FIELDS.

      SORT lt_bkpf BY bukrs belnr gjahr.
      SORT lt_bseg BY bukrs belnr gjahr buzei.

    ENDIF.

    DATA(lt_item_aux) = gt_item.

    DELETE lt_item_aux WHERE cliente IS INITIAL.         "#EC CI_STDSEQ

    SORT lt_item_aux BY empresa numdoc ano cliente.

    LOOP AT lt_item_aux ASSIGNING FIELD-SYMBOL(<fs_item_aux>).
      READ TABLE lt_kunnr_belnr TRANSPORTING NO FIELDS WITH TABLE KEY empresa = <fs_item_aux>-empresa
                                                                      numdoc  = <fs_item_aux>-numdoc
                                                                      ano     = <fs_item_aux>-ano
                                                                      cliente = <fs_item_aux>-cliente.

      CHECK sy-subrc <> 0.

      ls_kunnr_belnr = CORRESPONDING #( <fs_item_aux> ).

      APPEND ls_kunnr_belnr TO lt_kunnr_belnr.
    ENDLOOP.

    LOOP AT lt_faglflexa ASSIGNING FIELD-SYMBOL(<fs_faglflexa>).


      READ TABLE lt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>) WITH KEY bukrs       = <fs_faglflexa>-rbukrs
                                                                    belnr       = <fs_faglflexa>-docnr
                                                                    gjahr       = <fs_faglflexa>-ryear BINARY SEARCH.

      READ TABLE lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>) WITH KEY bukrs       = <fs_faglflexa>-rbukrs
                                                                    belnr       = <fs_faglflexa>-docnr
                                                                    gjahr       = <fs_faglflexa>-ryear
                                                                    buzei       = <fs_faglflexa>-buzei BINARY SEARCH.
      IF <fs_bseg> IS NOT ASSIGNED.
        READ TABLE lt_bseg ASSIGNING <fs_bseg> WITH KEY bukrs       = <fs_faglflexa>-rbukrs
                                                        belnr       = <fs_faglflexa>-docnr
                                                        gjahr       = <fs_faglflexa>-ryear BINARY SEARCH.
      ENDIF.


      TRY.

*      if <fs_faglflexa>-bschl <> '50' and <fs_faglflexa>-bschl <> '40'.
*
*              ls_sum_cliente_receita-moeda    = <fs_bkpf>-waers.
*              ls_sum_cliente_receita-kursf    = <fs_bkpf>-kursf.
*              ls_sum_cliente_receita-bukrs    = <fs_bkpf>-bukrs.
*              ls_sum_cliente_receita-kunnr    = <fs_bseg>-kunnr.
*              if line_exists( gt_de_para_hkont[ hkont_from = <fs_faglflexa>-racct ] ).
*              ls_sum_cliente_receita-hkont_to = gt_de_para_hkont[ hkont_from = <fs_faglflexa>-racct ]-hkont_to.
*              else.
*              ls_sum_cliente_receita-hkont_to = <fs_faglflexa>-racct.
*              endif.
*              ls_sum_cliente_receita-gsber    = <fs_faglflexa>-rbusa.
*              ls_sum_cliente_receita-bupla    = <fs_bseg>-bupla.
*              ls_sum_cliente_receita-prctr    = <fs_faglflexa>-prctr.
*              ls_sum_cliente_receita-dmbtr    = <fs_faglflexa>-wsl.
*              COLLECT ls_sum_cliente_receita INTO gt_sum_cliente_receita.
*
*              APPEND VALUE #( moeda     = ls_sum_cliente_receita-moeda
*                  kursf     = ls_sum_cliente_receita-kursf
*                  bukrs     = <fs_bkpf>-bukrs
*                  gjahr      = <fs_bkpf>-gjahr
*                  belnr      = <fs_bkpf>-belnr
*                   ) TO gt_doc_proc.
*
*              append value #( moeda     = <fs_bkpf>-waers
*                           kursf     = <fs_bkpf>-kursf ) to gt_agrup.
*      else.

          ls_sum_razao-moeda        = <fs_bkpf>-waers.
          ls_sum_razao-kursf        = <fs_bkpf>-kursf.
          ls_sum_razao-bukrs        = <fs_bkpf>-bukrs.
          ls_sum_razao-hkont_to     = gt_de_para_hkont[ hkont_from = <fs_faglflexa>-racct ]-hkont_to.
          ls_sum_razao-gsber        = <fs_faglflexa>-rbusa.
          ls_sum_razao-bupla        = <fs_bseg>-bupla.
          ls_sum_razao-prctr        = <fs_faglflexa>-prctr.
          ls_sum_razao-dmbtr        = <fs_faglflexa>-wsl.
          COLLECT ls_sum_razao INTO gt_sum_razao.

          APPEND VALUE #( moeda     = <fs_bkpf>-waers
                       kursf     = <fs_bkpf>-kursf
                       bukrs     = <fs_bkpf>-bukrs
                       gjahr      = <fs_bkpf>-gjahr
                       belnr      = <fs_bkpf>-belnr
                        ) TO gt_doc_proc.

          APPEND VALUE #( moeda     = <fs_bkpf>-waers
                       kursf     = <fs_bkpf>-kursf ) TO gt_agrup.

*      endif.
        CATCH cx_sy_itab_line_not_found.
          rt_mensagens = VALUE #( BASE rt_mensagens ( message_v1 = <fs_faglflexa>-racct type = 'E' id = 'ZFI_DEFERIMENTO' number = '000' ) ).
          me->format_message( CHANGING ct_return = rt_mensagens[] ).
          RETURN.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.


  METHOD check_bapi.
*    CLEAR me->gt_return.


    IF ct_accountgl IS INITIAL.
    if it_accountreceivable is not initial.
*      CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK' "#EC CI_SEL_NESTED
*        EXPORTING
*          documentheader    = is_documentheader
*        TABLES
*          currencyamount    = it_currencyamount
*          accountreceivable = it_accountreceivable
*          extension2        = ct_extension2
*          return            = me->gt_return.
     endif.
    ELSE.
    if it_accountreceivable is not initial.
*      CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK' "#EC CI_SEL_NESTED
*        EXPORTING
*          documentheader = is_documentheader
*        TABLES
*          accountgl      = ct_accountgl
*          accountreceivable = it_accountreceivable
*          currencyamount = it_currencyamount
*          extension2     = ct_extension2
*          return         = me->gt_return.
    else.
      CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK' "#EC CI_SEL_NESTED
        EXPORTING
          documentheader = is_documentheader
        TABLES
          accountgl      = ct_accountgl
          currencyamount = it_currencyamount
          extension2     = ct_extension2
          return         = me->gt_return.
    ENDIF.
    ENDIF.

    APPEND LINES OF me->gt_return TO ct_mensagens.
  ENDMETHOD.


  METHOD processa_bapi_estorno.
*    CLEAR me->gt_return.
*    DATA lt_return TYPE bapiret2_t.

    CLEAR gv_endfunction.

    add 1 to gv_ZFMFI_ESTORNO_DOC.

    data(lv_taks) = |ZFMFI_ESTORNO_DOC{ gv_ZFMFI_ESTORNO_DOC }|.

    CALL FUNCTION 'ZFMFI_ESTORNO_DOC'
      STARTING NEW TASK lv_taks CALLING task_finish_est ON END OF TASK
      EXPORTING
        iv_empresa   = iv_empresa
        iv_doc       = iv_doc
        iv_ano       = iv_ano
        iv_dtestorno = iv_dtestorno
        iv_periodo   = iv_periodo
        iv_cod       = gc_cod.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL gv_endfunction IS NOT INITIAL.
  ENDMETHOD.


  METHOD processa_bapi_document.
    CLEAR me->gt_return.

    CLEAR gv_endfunction.

    add 1 to gv_ZFMFI_CONTABILIZACAO.
    data(lv_taks) = |ZFMFI_CONTABILIZACAO{ gv_ZFMFI_CONTABILIZACAO }|.

    CALL FUNCTION 'ZFMFI_CONTABILIZACAO'
      STARTING NEW TASK lv_taks CALLING task_finish_cont ON END OF TASK
      EXPORTING
        is_documentheader    = is_documentheader
        it_accountgl         = it_accountgl
        it_currencyamount    = it_currencyamount
        it_accountreceivable = it_accountreceivable
        it_extension2        = it_extension2.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL gv_endfunction IS NOT INITIAL.
    APPEND LINES OF me->gt_return TO et_mensagens.
  ENDMETHOD.


  METHOD prepara_dados.

    TYPES: BEGIN OF ty_log_int,
             moeda      TYPE waers,
             kursf      TYPE kursf,
             tp_bapi    TYPE char20,
             bukrs_cont TYPE bukrs,
             belnr_cont TYPE belnr_d,
             gjahr_cont TYPE gjahr,
             bukrs_est  TYPE bukrs,
             belnr_est  TYPE belnr_d,
             gjahr_est  TYPE gjahr,
             text       TYPE ze_descricao_status,
           END OF ty_log_int.

    DATA: lt_accountgl         TYPE bapiacgl09_tab,
          lt_currencyamount    TYPE bapiaccr09_tab,
          lt_accountreceivable TYPE bapiacar09_tab,
          lt_log_aux           TYPE ty_t_log,
          lt_extension2        TYPE t_bapiparex,
          lt_mensagens         TYPE bapiret2_tab,
          lt_log_int           TYPE TABLE OF ty_log_int.

    DATA: lt_accouable_aux  TYPE bapiacar09_tab,
          lt_curramount_aux TYPE bapiaccr09_tab,
          lt_accountgl_aux  TYPE bapiacgl09_tab.

    DATA: ls_documentheader TYPE bapiache09,
          ls_log            TYPE ztfi_log_dif_msg,
          ls_log_int        TYPE ty_log_int,
          ls_currencyamount TYPE bapiaccr09,
          ls_header_aux     TYPE bapiache09.

    DATA: lv_itemno_acc TYPE posnr_acc,
          lv_msg_ret    TYPE char50,
          lv_empresa    TYPE bukrs,
          lv_doc        TYPE belnr_d,
          lv_ano        TYPE gjahr,
          lv_dtestorno  TYPE datum,
          lv_periodo    TYPE monat,
          lv_moeda      TYPE waers,
          lv_kursf      TYPE kursf,
          lv_error.

    CONSTANTS: lc_id_rw(2)       TYPE c     VALUE 'RW',
               lc_msg_rw(3)      TYPE c     VALUE '605',
               lc_doc_type_ab(2) TYPE c     VALUE 'AB',
               lc_doc_type_sa(2) TYPE c     VALUE 'SA',
               lc_curr_type      TYPE curtp VALUE '10'.

    SORT gt_sum_cliente_receita BY moeda
                                   kursf.
    SORT gt_sum_razao BY moeda
                         kursf.

*    DATA(lt_sum_cliente_receita) = gt_sum_cliente_receita.
    DATA(lt_sum_razao)           = gt_sum_razao.

    CLEAR: me->gt_return,
           rt_mensagens.

    CLEAR: "lt_extension2[],
           lt_accountgl[],
           lt_currencyamount[],
           lt_accountreceivable[],
           ls_documentheader,
           ls_log,
           me->gv_ano_rev,
           me->gv_doc_rev,
           lv_itemno_acc,
           lv_msg_ret,
           lv_moeda,
           lv_kursf,
           lv_error.

*    LOOP AT lt_sum_cliente_receita ASSIGNING FIELD-SYMBOL(<fs_sum_cliente_receita>).
*
*      CHECK <fs_sum_cliente_receita>-moeda = iv_moeda
*        AND <fs_sum_cliente_receita>-kursf = iv_kursf.
*
*      IF ls_documentheader IS INITIAL.
*        ls_documentheader = VALUE bapiache09( comp_code  = gt_sum_cliente_receita[ 1 ]-bukrs
*                                              doc_date   = gs_param-dtlanc
*                                              pstng_date = gs_param-dtlanc
*                                              doc_type   = lc_doc_type_sa
*                                              username   = sy-uname
*                                               "ref_doc_no  =
*                                              header_txt = TEXT-t01 ). " Rateio Assis. Médica
*      ENDIF.
*
*      ADD 1 TO lv_itemno_acc.
*      APPEND VALUE #( itemno_acc = lv_itemno_acc
*                      customer   = <fs_sum_cliente_receita>-kunnr
*                      comp_code  = <fs_sum_cliente_receita>-bukrs
*                      bus_area   = <fs_sum_cliente_receita>-gsber
*                      item_text  = TEXT-t02
*                      profit_ctr = <fs_sum_cliente_receita>-prctr
*                    ) TO lt_accountreceivable.
*
*      APPEND VALUE #( itemno_acc = lv_itemno_acc
*                      currency   = <fs_sum_cliente_receita>-moeda
*                      amt_doccur = <fs_sum_cliente_receita>-dmbtr * -1
*                      exch_rate  = <fs_sum_cliente_receita>-kursf
*                    ) TO lt_currencyamount.
*
*      APPEND VALUE #( structure  = 'BUPLA'
*                      valuepart1 = lv_itemno_acc
*                      valuepart2 = <fs_sum_cliente_receita>-bupla ) TO lt_extension2.
*
*    ENDLOOP.

    SORT lt_sum_razao BY bukrs
                         prctr
                         gsber.

    DATA(lt_sum_key) = lt_sum_razao[].

    DELETE ADJACENT DUPLICATES FROM lt_sum_key COMPARING bukrs
                                                         prctr
                                                         gsber.

    LOOP AT lt_sum_key ASSIGNING FIELD-SYMBOL(<fs_sum_key>).

      CHECK <fs_sum_key>-moeda = iv_moeda
        AND <fs_sum_key>-kursf = iv_kursf.

      IF ls_documentheader IS INITIAL.
        ls_documentheader = VALUE bapiache09( comp_code  = <fs_sum_key>-bukrs
                                              doc_date   = gs_param-dtlanc
                                              pstng_date = gs_param-dtlanc
                                              doc_type   = lc_doc_type_sa
                                              username   = sy-uname
                                              header_txt = COND #( WHEN gs_param-app = abap_true
                                                                     THEN TEXT-t06
                                                                   ELSE TEXT-t05  ) ). " Rateio Assis. Médica'
      ENDIF.

      READ TABLE lt_sum_razao TRANSPORTING NO FIELDS
                                            WITH KEY bukrs = <fs_sum_key>-bukrs
                                                     prctr = <fs_sum_key>-prctr
                                                     gsber = <fs_sum_key>-gsber
                                                     BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        LOOP AT lt_sum_razao ASSIGNING FIELD-SYMBOL(<fs_sum_razao>) FROM sy-tabix.
          IF <fs_sum_razao>-bukrs NE <fs_sum_key>-bukrs
          OR <fs_sum_razao>-prctr NE <fs_sum_key>-prctr
          OR <fs_sum_razao>-gsber NE <fs_sum_key>-gsber.
            EXIT.
          ENDIF.

          CHECK <fs_sum_key>-moeda = iv_moeda
            AND <fs_sum_key>-kursf = iv_kursf.

          ADD 1 TO lv_itemno_acc.
          APPEND VALUE #( itemno_acc = lv_itemno_acc
                          alloc_nmbr = COND #( WHEN gs_param-app = abap_true
                                                 THEN TEXT-t06
                                               ELSE TEXT-t05  )
                          gl_account = <fs_sum_razao>-hkont_to
                          bus_area   = <fs_sum_razao>-gsber
                          profit_ctr = <fs_sum_razao>-prctr " COSTCENTER
                          item_text  = COND #( WHEN gs_param-app = abap_true
                                                 THEN TEXT-t06
                                               ELSE TEXT-t05  )
                         ) TO lt_accountgl_aux.

          APPEND VALUE #( itemno_acc = lv_itemno_acc
                          currency   = <fs_sum_razao>-moeda
                          amt_doccur = <fs_sum_razao>-dmbtr * -1
                          exch_rate  = <fs_sum_razao>-kursf
                         ) TO lt_curramount_aux.

        ENDLOOP.

        IF lt_accountgl_aux[] IS NOT INITIAL.

          IF ( lines( lt_accountgl ) + lines( lt_accountgl_aux ) ) LE 900.

            APPEND LINES OF lt_accountgl_aux TO lt_accountgl.
            APPEND LINES OF lt_curramount_aux TO lt_currencyamount.

            FREE: lt_accountgl_aux[],
                  lt_curramount_aux[].

          ELSE.

            IF ls_documentheader IS NOT INITIAL.

              FREE lt_mensagens[].

              IF iv_simular = abap_true.

                me->check_bapi( EXPORTING is_documentheader    = ls_documentheader
                                          it_currencyamount    = lt_currencyamount
                                 CHANGING ct_accountgl         = lt_accountgl
                                          ct_mensagens         = lt_mensagens ).

                APPEND LINES OF lt_mensagens TO rt_mensagens.

              ELSE.

                me->processa_bapi_document( EXPORTING is_documentheader    = ls_documentheader
                                                      it_accountgl         = lt_accountgl
                                                      it_currencyamount    = lt_currencyamount
                                            IMPORTING et_mensagens         = lt_mensagens ).

                APPEND LINES OF lt_mensagens TO rt_mensagens.

                TRY.
                    lv_msg_ret =  lt_mensagens[ id     = lc_id_rw
                                                number = lc_msg_rw ]-message_v2.
                  CATCH cx_sy_itab_line_not_found.
                ENDTRY.

                " Executa BAPI Estorno
                me->processa_bapi_estorno( EXPORTING iv_empresa   = lv_msg_ret+10(4)
                                                     iv_doc       = lv_msg_ret(10)
                                                     iv_ano       = CONV #( lv_msg_ret+14(4) )
                                                     iv_dtestorno = gs_param-dtestorno
                                                     iv_periodo   = lv_periodo ).

                LOOP AT me->gt_msg_retorno ASSIGNING FIELD-SYMBOL(<fs_msg_retorno>).

                  APPEND VALUE #( message_v1 = <fs_msg_retorno>-message_v1
                                  message_v2 = <fs_msg_retorno>-message_v2
                                  message_v3 = <fs_msg_retorno>-message_v3
                                  message_v4 = <fs_msg_retorno>-message_v4
                                  type       = <fs_msg_retorno>-type
                                  id         = <fs_msg_retorno>-id
                                  number     = <fs_msg_retorno>-number ) TO rt_mensagens.
                ENDLOOP.

                IF sy-subrc = 4.
                  rt_mensagens = VALUE #( BASE rt_mensagens ( message_v1 = |{ me->gv_doc_rev  }{ <fs_sum_razao>-bukrs }{ me->gv_ano_rev }| type = 'S' id = 'ZFI_DEFERIMENTO' number = '003' ) ).
                ENDIF.

                ls_log_int-moeda      = iv_moeda.
                ls_log_int-kursf      = iv_kursf.
                ls_log_int-tp_bapi    = 2. "Imposto
                ls_log_int-bukrs_cont = lv_msg_ret+10(4).
                ls_log_int-belnr_cont = lv_msg_ret(10).
                ls_log_int-gjahr_cont = lv_msg_ret+14(4).
                ls_log_int-bukrs_est  = lv_msg_ret+10(4).
                ls_log_int-belnr_est  = me->gv_doc_rev.
                ls_log_int-gjahr_est  = me->gv_ano_rev.
                APPEND ls_log_int TO lt_log_int.
                CLEAR ls_log_int.

              ENDIF.
            ENDIF.

            IF iv_simular IS NOT SUPPLIED
            OR iv_simular IS INITIAL.

              SORT gt_doc_proc. DELETE ADJACENT DUPLICATES FROM gt_doc_proc.
              SORT lt_log_int BY moeda
                                 kursf
                                 tp_bapi.

              LOOP AT gt_doc_proc ASSIGNING FIELD-SYMBOL(<fs_doc_proc>).

                DATA(ls_log_dif_msg) = VALUE ztfi_log_dif_msg( bukrs = <fs_doc_proc>-bukrs
                                                               belnr = <fs_doc_proc>-belnr
                                                               gjahr = <fs_doc_proc>-gjahr ).

                ls_log_dif_msg-contador = 0.

                READ TABLE lt_log_int INTO ls_log_int WITH KEY moeda   = <fs_doc_proc>-moeda
                                                               kursf   = <fs_doc_proc>-kursf
                                                               tp_bapi = 2 BINARY SEARCH.

                IF sy-subrc = 0.
                  ls_log_dif_msg-tp_bapi    =  TEXT-002.
                  ls_log_dif_msg-bukrs_cont = ls_log_int-bukrs_cont.
                  ls_log_dif_msg-belnr_cont = ls_log_int-belnr_cont.
                  ls_log_dif_msg-gjahr_cont = ls_log_int-gjahr_cont.
                  ls_log_dif_msg-bukrs_est  = ls_log_int-bukrs_est.
                  ls_log_dif_msg-belnr_est  = ls_log_int-belnr_est.
                  ls_log_dif_msg-gjahr_est  = ls_log_int-gjahr_est.
                  ADD 1 TO ls_log_dif_msg-contador.
                  APPEND ls_log_dif_msg TO gt_log_msg.
                ENDIF.
              ENDLOOP.
            ENDIF.

            CLEAR: lv_itemno_acc,
                   ls_documentheader,
                   lv_msg_ret.

            FREE: lt_currencyamount[],
                  lt_accountgl[],
                  lt_log_int[].

            APPEND LINES OF lt_accountgl_aux TO lt_accountgl.
            APPEND LINES OF lt_curramount_aux TO lt_currencyamount.

            FREE: lt_accountgl_aux[],
                  lt_curramount_aux[].

          ENDIF.

        ENDIF.
      ENDIF.
    ENDLOOP.

    IF lt_accountgl[] IS NOT INITIAL.

      FREE lt_mensagens[].

      IF iv_simular = abap_true.

        me->check_bapi( EXPORTING is_documentheader    = ls_documentheader
                                  it_currencyamount    = lt_currencyamount
                         CHANGING ct_accountgl         = lt_accountgl
                                  ct_mensagens         = lt_mensagens ).

        APPEND LINES OF lt_mensagens TO rt_mensagens.

      ELSE.

        me->processa_bapi_document( EXPORTING is_documentheader    = ls_documentheader
                                              it_accountgl         = lt_accountgl
                                              it_currencyamount    = lt_currencyamount
                                    IMPORTING et_mensagens         = lt_mensagens ).

        APPEND LINES OF lt_mensagens TO rt_mensagens.

        TRY.
            lv_msg_ret =  lt_mensagens[ id     = lc_id_rw
                                        number = lc_msg_rw ]-message_v2.
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

        " Executa BAPI Estorno
        me->processa_bapi_estorno( EXPORTING iv_empresa   = lv_msg_ret+10(4)
                                             iv_doc       = lv_msg_ret(10)
                                             iv_ano       = CONV #( lv_msg_ret+14(4) )
                                             iv_dtestorno = gs_param-dtestorno
                                             iv_periodo   = lv_periodo ).

        LOOP AT me->gt_msg_retorno ASSIGNING <fs_msg_retorno>.

          APPEND VALUE #( message_v1 = <fs_msg_retorno>-message_v1
                          message_v2 = <fs_msg_retorno>-message_v2
                          message_v3 = <fs_msg_retorno>-message_v3
                          message_v4 = <fs_msg_retorno>-message_v4
                          type       = <fs_msg_retorno>-type
                          id         = <fs_msg_retorno>-id
                          number     = <fs_msg_retorno>-number ) TO rt_mensagens.
        ENDLOOP.

        IF sy-subrc = 4.
          rt_mensagens = VALUE #( BASE rt_mensagens ( message_v1 = |{ me->gv_doc_rev  }{ <fs_sum_razao>-bukrs }{ me->gv_ano_rev }| type = 'S' id = 'ZFI_DEFERIMENTO' number = '003' ) ).
        ENDIF.

        ls_log_int-moeda      = iv_moeda.
        ls_log_int-kursf      = iv_kursf.
        ls_log_int-tp_bapi    = 2. "Imposto
        ls_log_int-bukrs_cont = lv_msg_ret+10(4).
        ls_log_int-belnr_cont = lv_msg_ret(10).
        ls_log_int-gjahr_cont = lv_msg_ret+14(4).
        ls_log_int-bukrs_est  = lv_msg_ret+10(4).
        ls_log_int-belnr_est  = me->gv_doc_rev.
        ls_log_int-gjahr_est  = me->gv_ano_rev.
        APPEND ls_log_int TO lt_log_int.
        CLEAR ls_log_int.

      ENDIF.

      IF iv_simular IS NOT SUPPLIED
      OR iv_simular IS INITIAL.

        SORT gt_doc_proc. DELETE ADJACENT DUPLICATES FROM gt_doc_proc.
        SORT lt_log_int BY moeda
                           kursf
                           tp_bapi.

        LOOP AT gt_doc_proc ASSIGNING <fs_doc_proc>.

          ls_log_dif_msg = VALUE ztfi_log_dif_msg( bukrs = <fs_doc_proc>-bukrs
                                                   belnr = <fs_doc_proc>-belnr
                                                   gjahr = <fs_doc_proc>-gjahr ).

          ls_log_dif_msg-contador = 0.

          READ TABLE lt_log_int INTO ls_log_int WITH KEY moeda   = <fs_doc_proc>-moeda
                                                         kursf   = <fs_doc_proc>-kursf
                                                         tp_bapi = 2 BINARY SEARCH.

          IF sy-subrc = 0.
            ls_log_dif_msg-tp_bapi    =  TEXT-002.
            ls_log_dif_msg-bukrs_cont = ls_log_int-bukrs_cont.
            ls_log_dif_msg-belnr_cont = ls_log_int-belnr_cont.
            ls_log_dif_msg-gjahr_cont = ls_log_int-gjahr_cont.
            ls_log_dif_msg-bukrs_est  = ls_log_int-bukrs_est.
            ls_log_dif_msg-belnr_est  = ls_log_int-belnr_est.
            ls_log_dif_msg-gjahr_est  = ls_log_int-gjahr_est.
            ADD 1 TO ls_log_dif_msg-contador.
            APPEND ls_log_dif_msg TO gt_log_msg.
          ENDIF.
        ENDLOOP.
      ENDIF.

      CLEAR: lv_itemno_acc,
             ls_documentheader,
             lv_msg_ret.

      FREE: lt_currencyamount[],
            lt_accountgl[],
            lt_log_int[].

      APPEND LINES OF lt_accountgl_aux TO lt_accountgl.
      APPEND LINES OF lt_curramount_aux TO lt_currencyamount.

      FREE: lt_accountgl_aux[],
            lt_curramount_aux[].

    ENDIF.

*    CLEAR lt_mensagens.
*
*    IF ls_documentheader IS NOT INITIAL.
*
*      CLEAR lt_mensagens.
*
*      IF iv_simular = abap_true.
*
*        me->check_bapi( EXPORTING is_documentheader    = ls_documentheader
*                                  it_currencyamount    = lt_currencyamount
*                                  it_accountreceivable = lt_accountreceivable
*                         CHANGING ct_accountgl         = lt_accountgl
*                                  ct_mensagens         = lt_mensagens
*                                  ct_extension2        = lt_extension2 ).
*
*        APPEND LINES OF lt_mensagens TO rt_mensagens.
*
*        IF  line_exists( rt_mensagens[ type = 'E' ] ).   "#EC CI_STDSEQ
*          lv_error = abap_true.
*          EXIT.
*        ENDIF.
*
*      ELSE.
*
*        me->processa_bapi_document( EXPORTING is_documentheader    = ls_documentheader
*                                              it_accountgl         = lt_accountgl
*                                              it_currencyamount    = lt_currencyamount
*                                              it_accountreceivable = lt_accountreceivable
*                                              it_extension2        = lt_extension2
*                                    IMPORTING et_mensagens         = lt_mensagens ).
*
*        APPEND LINES OF lt_mensagens TO rt_mensagens.
*
*        TRY.
*            lv_msg_ret =  lt_mensagens[ id = lc_id_rw number = lc_msg_rw ]-message_v2.
*          CATCH cx_sy_itab_line_not_found.
*        ENDTRY.
*
*        "EXECUTA BAPI ESTORNO
**        lv_periodo = gs_param-dtestorno+4(2).
*        me->processa_bapi_estorno( EXPORTING iv_empresa   = lv_msg_ret+10(4)
*                                             iv_doc       = lv_msg_ret(10)
*                                             iv_ano       = CONV #( lv_msg_ret+14(4) )
*                                             iv_dtestorno = gs_param-dtestorno
*                                             iv_periodo   = lv_periodo ).
*
*
*        LOOP AT me->gt_msg_retorno ASSIGNING FIELD-SYMBOL(<fs_msg_retorno>).
*
*          APPEND VALUE #( message_v1 = <fs_msg_retorno>-message_v1
*                          message_v2 = <fs_msg_retorno>-message_v2
*                          message_v3 = <fs_msg_retorno>-message_v3
*                          message_v4 = <fs_msg_retorno>-message_v4
*                          type       = <fs_msg_retorno>-type
*                          id         = <fs_msg_retorno>-id
*                          number     = <fs_msg_retorno>-number ) TO rt_mensagens.
*        ENDLOOP.
*
*        IF sy-subrc = 4.
*          rt_mensagens = VALUE #( BASE rt_mensagens ( message_v1 = |{ me->gv_doc_rev  }{ <fs_sum_razao>-bukrs }{ me->gv_ano_rev }| type = 'S' id = 'ZFI_DEFERIMENTO' number = '003' ) ).
*        ENDIF.
*
*        ls_log_int-moeda   =  iv_moeda.
*        ls_log_int-kursf   =  iv_kursf.
*        ls_log_int-tp_bapi =  2. "Imposto
*        ls_log_int-bukrs_cont = lv_msg_ret+10(4).
*        ls_log_int-belnr_cont = lv_msg_ret(10).
*        ls_log_int-gjahr_cont = lv_msg_ret+14(4).
*        ls_log_int-bukrs_est = lv_msg_ret+10(4).
*        ls_log_int-belnr_est = me->gv_doc_rev.
*        ls_log_int-gjahr_est = me->gv_ano_rev.
*        APPEND ls_log_int TO lt_log_int.
*
*      ENDIF.
*    ENDIF.
*
*    CHECK iv_simular IS NOT SUPPLIED
*       OR iv_simular IS INITIAL.
*
*    SORT gt_doc_proc. DELETE ADJACENT DUPLICATES FROM gt_doc_proc.
*    SORT lt_log_int BY moeda
*                       kursf
*                       tp_bapi.
*
*    LOOP AT gt_doc_proc ASSIGNING FIELD-SYMBOL(<fs_doc_proc>).
*
*      DATA(ls_log_dif_msg) = VALUE ztfi_log_dif_msg( bukrs = <fs_doc_proc>-bukrs
*                                                     belnr = <fs_doc_proc>-belnr
*                                                     gjahr = <fs_doc_proc>-gjahr ).
*
*      ls_log_dif_msg-contador = 0.
*
*      READ TABLE lt_log_int INTO ls_log_int WITH KEY moeda   = <fs_doc_proc>-moeda
*                                                     kursf   = <fs_doc_proc>-kursf
*                                                     tp_bapi = 2 BINARY SEARCH.
*
*      IF sy-subrc = 0.
*        ls_log_dif_msg-tp_bapi    =  TEXT-002.
*        ls_log_dif_msg-bukrs_cont = ls_log_int-bukrs_cont.
*        ls_log_dif_msg-belnr_cont = ls_log_int-belnr_cont.
*        ls_log_dif_msg-gjahr_cont = ls_log_int-gjahr_cont.
*        ls_log_dif_msg-bukrs_est  = ls_log_int-bukrs_est.
*        ls_log_dif_msg-belnr_est  = ls_log_int-belnr_est.
*        ls_log_dif_msg-gjahr_est  = ls_log_int-gjahr_est.
*        ADD 1 TO ls_log_dif_msg-contador.
*        APPEND ls_log_dif_msg TO gt_log_msg.
*      ENDIF.
*    ENDLOOP.

    IF iv_simular IS NOT SUPPLIED
    OR iv_simular IS INITIAL.
      me->save_log( ).
    ENDIF.

  ENDMETHOD.


  METHOD task_finish_cont.
    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_CONTABILIZACAO'
      TABLES
        t_mensagens = me->gt_return.

      gv_endfunction = abap_true.
    RETURN.
  ENDMETHOD.


  METHOD save_log.
    DATA: ls_log TYPE ztfi_log_dif,
          lt_log TYPE TABLE OF ztfi_log_dif.

    LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
      ls_log-bukrs   = <fs_header>-empresa.
      ls_log-belnr   = <fs_header>-numdoc.
      ls_log-gjahr   = <fs_header>-ano.
      ls_log-status  = 'S'.
      ls_log-usuario = sy-uname.
      ls_log-dt_exec = sy-datum.
      ls_log-hr_exec = sy-uzeit.
      ls_log-text    = TEXT-001.

      APPEND ls_log TO lt_log.
    ENDLOOP.

    CLEAR gv_endfunction.

    add 1 to gv_ZFMFI_ZTFI_LOG_DIF.
    data(lv_taks) = |ZFMFI_ZTFI_LOG_DIF{ gv_ZFMFI_ZTFI_LOG_DIF }|.

    CALL FUNCTION 'ZFMFI_ZTFI_LOG_DIF'
      STARTING NEW TASK lv_taks CALLING task_finish_log ON END OF TASK
      EXPORTING
        it_ztfi_log_dif     = lt_log
        it_ztfi_log_dif_msg = gt_log_msg.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL gv_endfunction IS NOT INITIAL.

  ENDMETHOD.


  METHOD task_finish_est.
    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_ESTORNO_DOC'
      CHANGING
        cv_doc_rev = me->gv_doc_rev
        cv_ano_rev = me->gv_ano_rev
        ct_mensagens = me->gt_msg_retorno.
        gv_endfunction = abap_true.

    RETURN.
  ENDMETHOD.


  METHOD task_finish_log.
    RECEIVE RESULTS FROM FUNCTION 'ZFGFI_ZTFI_LOG_DIF'.

    gv_endfunction = abap_true.
    RETURN.
  ENDMETHOD.


  METHOD diferimento.
    DATA lt_remessa TYPE vbeln_vl_t.

    SORT gt_header BY empresa numdoc ano.

    IF gs_param-app IS INITIAL.
      me->get_data_merc_int(  ).
    ENDIF.

*    DATA(lt_unid_frete) = me->get_unid_frete(  ).

    LOOP AT gt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
*      READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_header>) WITH KEY Empresa = <fs_itens>-Empresa
*                                                                        NumDoc  = <fs_itens>-NumDoc
*                                                                        Ano     = <fs_itens>-Ano
*                                                                        BINARY SEARCH.
*      IF sy-subrc = 0.
      TRY.
*            DATA(ls_unid_frete) = lt_unid_frete[ remessa = <fs_header>-referencesddocument ]. "#EC CI_STDSEQ


          me->set_deferimento( iv_unid_frete = <fs_header>-ordemfrete+10(10) "ls_unid_frete-unid_frete
                               iv_preventr   = <fs_header>-dias
                               iv_doc_date   = <fs_header>-dataremessa ).

*            APPEND <fs_header> TO rt_return.

        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

*      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_unid_frete.
    DATA: lt_docflow TYPE tdt_docflow.

    check gt_header is not INITIAL.
    sort gt_header by EMPRESA NUMDOC ANO.
    delete ADJACENT DUPLICATES FROM gt_header COMPARING EMPRESA NUMDOC ANO.

    SELECT remessa, ordemfrete
    FROM zi_fi_ordem_frete
    FOR ALL ENTRIES IN @gt_header
    WHERE remessa = @gt_header-referencesddocument
    INTO TABLE @DATA(lt_return)."rt_return.

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<fs_return>).
      APPEND VALUE #( remessa = <fs_return>-remessa
                      unid_frete = <fs_return>-ordemfrete+10(10) ) TO rt_return.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_deferimento.

    CLEAR gv_endfunction.

    add 1 to gv_ZFMFI_ATUALIZA_TM.
    data(lv_taks) = |ZFMFI_ATUALIZA_TM{ gv_ZFMFI_ATUALIZA_TM }|.

    CALL FUNCTION 'ZFMFI_ATUALIZA_DADOS_TM'
      STARTING NEW TASK lv_taks CALLING task_finish_tm ON END OF TASK
      EXPORTING
        iv_unid_frete = iv_unid_frete
        iv_preventr   = iv_preventr
        iv_doc_date   = iv_doc_date.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL gv_endfunction IS NOT INITIAL.

*    CONSTANTS: lc_option TYPE char2 VALUE 'EQ',
*               lc_sign   TYPE char2 VALUE 'I'.
*
*    DATA: ls_selpar TYPE /bobf/s_frw_query_selparam,
*          lt_selpar TYPE /bobf/t_frw_query_selparam.
*
*    DATA: lt_root TYPE /scmtms/t_tor_root_k,
*          lt_exec TYPE /scmtms/t_tor_exec_k,
*          ls_exec TYPE /scmtms/s_tor_exec_k.
*
*    DATA: lo_message2  TYPE REF TO /bobf/if_frw_message,
*          lv_rejected  TYPE boole_d,
*          lv_date_char TYPE string,
*          lv_date      TYPE datum,
*          lv_uzeit     TYPE uzeit,
*          lv_timestamp TYPE tzonref-tstamps.
*
*    DATA(lo_svc_mngr) = /bobf/cl_tra_serv_mgr_factory=>get_service_manager( /scmtms/if_tor_c=>sc_bo_key ).
*
*    APPEND VALUE #( attribute_name = /scmtms/if_tor_c=>sc_query_attribute-root-root_elements-tor_id
*                    option         = lc_option
*                    sign           = lc_sign
*                    low            = iv_unid_frete
*                  ) TO lt_selpar.
*
*    TRY.
*        lo_svc_mngr->query(  EXPORTING
*                                iv_query_key            = /scmtms/if_tor_c=>sc_query-root-root_elements
*                                it_selection_parameters = lt_selpar
*                                iv_fill_data            = abap_true
*                             IMPORTING
*                                eo_message              = DATA(lo_message)
*                                et_data                 = lt_root  ) .
*
*      CATCH /bobf/cx_frw_contrct_violation.
*    ENDTRY.
*
*    IF lt_root IS NOT INITIAL.
*
*      "Definição das chaves do ROOT
*      "==============================
*      DATA(lt_keys) = VALUE /bobf/t_frw_key( FOR ls_root IN lt_root ( key = ls_root-key ) ).
*
*      "Obter remessas
*      "========================
*      lo_svc_mngr->retrieve_by_association( EXPORTING iv_node_key   = /scmtms/if_tor_c=>sc_node-root
*                                                     it_key         = lt_keys
*                                                     iv_association = /scmtms/if_tor_c=>sc_association-root-exec
*                                                     iv_fill_data   = abap_true
*                                           IMPORTING et_data        = lt_exec  ).
*
*      TRY.
*
*          DATA(lv_consigneeid) = lt_root[ 1 ]-consigneeid.
*
*        CATCH cx_sy_itab_line_not_found.
*      ENDTRY.
*
*
*      ASSIGN lt_exec[ ext_loc_id = lv_consigneeid       "#EC CI_SORTSEQ
*                      event_code = gc_entr_cli ] TO FIELD-SYMBOL(<fs_exec>).
*
*      IF sy-subrc  IS INITIAL.
*
*        ls_exec-torstopuuid = <fs_exec>-torstopuuid.
*        ls_exec-actual_date = <fs_exec>-actual_date.
*        ls_exec-event_code  = gc_dif.
*        ls_exec-ext_loc_id  = lv_consigneeid.
*
*      ELSE.
*
*        lv_date = iv_doc_date + iv_preventr.
*
*        CALL FUNCTION 'CONVERT_INTO_TIMESTAMP'
*          EXPORTING
*            i_datlo     = lv_date
*            i_timlo     = lv_uzeit
*          IMPORTING
*            e_timestamp = lv_timestamp.
*
*        ls_exec-actual_date = lv_timestamp.
*        ls_exec-event_code  = gc_dif.
*        ls_exec-ext_loc_id  = lv_consigneeid.
*
*      ENDIF.
*
*
*      DATA: lo_exec TYPE REF TO data.
*      CREATE DATA lo_exec LIKE ls_exec.
*
*      ASSIGN ('lo_exec->*') TO <fs_exec>.
*
*      IF <fs_exec> IS ASSIGNED.
*
*        <fs_exec> = ls_exec.
*
*        DATA(lo_txn_mngr) = /bobf/cl_tra_trans_mgr_factory=>get_transaction_manager( ).
*
*
*
*        lo_svc_mngr->modify( EXPORTING it_modification = VALUE #( ( node           = /scmtms/if_tor_c=>sc_node-executioninformation
*                                                                    change_mode    = /bobf/if_frw_c=>sc_modify_create
*                                                                    source_node    = /scmtms/if_tor_c=>sc_node-root
*                                                                    source_key     = lt_keys[ 1 ]-key
*                                                                    association    = /scmtms/if_tor_c=>sc_association-root-exec
*                                                                    data           =  lo_exec ) )
*                               IMPORTING eo_change = DATA(lo_change)
*                                         eo_message = DATA(lo_msg) ).
*
*        " Salva valores modificados
*        "=================================
*        lo_txn_mngr->save( IMPORTING ev_rejected = lv_rejected
*                                     eo_message  = lo_message2 ).
*
*      ENDIF.
*    ENDIF.

  ENDMETHOD.


  METHOD format_message.

    DATA: ls_return_format TYPE bapiret2.

    LOOP AT ct_return REFERENCE INTO DATA(ls_return).

      CHECK ls_return->message IS INITIAL.

      TRY.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = ls_return->id
              lang      = sy-langu
              no        = ls_return->number
              v1        = ls_return->message_v1
              v2        = ls_return->message_v2
              v3        = ls_return->message_v3
              v4        = ls_return->message_v4
            IMPORTING
              msg       = ls_return->message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.

          IF sy-subrc <> 0.
            CLEAR ls_return->message.
          ENDIF.

        CATCH cx_root INTO DATA(lo_root).
          DATA(lv_message) = lo_root->get_longtext( ).
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD set_ref_data.
    IF iv_app IS INITIAL.
      ASSIGN gr_bukrs->*  TO FIELD-SYMBOL(<fs_bukrs>).
      ASSIGN gr_dtsel->*  TO FIELD-SYMBOL(<fs_dtsel>).

      gs_param-bukrs[]   = <fs_bukrs>.
      gs_param-budat[]   = <fs_dtsel>.

      UNASSIGN <fs_bukrs>.
      UNASSIGN <fs_dtsel>.
    ENDIF.
    gs_param-app       = iv_app.
    gs_param-dtlanc    = iv_dtlanc.
    gs_param-dtestorno = iv_dtestorno.
    gt_header          = it_header.
    gt_item            = it_item.
  ENDMETHOD.


  METHOD get_data_merc_int.
    DATA: lt_header_aux TYPE TABLE OF zsfi_mercado_header WITH EMPTY KEY,
          lt_item_aux   TYPE TABLE OF zsfi_mercado_item.

    SELECT empresa, numdoc, ano,
           datadocumento, datalancamento, mes,
           tipodocumento, moeda, referencia,
           textocab, datalanc, dataestorno,
           dias, remessa, dataremessa
    FROM zi_fi_merc_int_h
    WHERE empresa IN @gs_param-bukrs
    AND   datalancamento IN @gs_param-budat
    INTO TABLE @DATA(lt_header).

    MOVE-CORRESPONDING lt_header TO lt_header_aux.

    IF lt_header_aux IS NOT INITIAL.
      SELECT empresa, numdoc, ano,
             item, cliente, conta,
             divisao, atribuicao, textitem,
             creddeb, localnegocio, centrolucro,
             centrocusto, segmento, moeda, valor
      FROM zi_fi_merc_int_i
      FOR ALL ENTRIES IN @lt_header_aux
      WHERE empresa = @lt_header_aux-empresa
      AND   numdoc  = @lt_header_aux-numdoc
      AND   ano     = @lt_header_aux-ano
      INTO TABLE @DATA(lt_item).

      MOVE-CORRESPONDING lt_item   TO lt_item_aux.


      APPEND LINES OF lt_header_aux TO me->gt_header.
      APPEND LINES OF lt_item_aux   TO me->gt_item.

    ENDIF.
  ENDMETHOD.


  METHOD save.
    DATA: lo_message2 TYPE REF TO /bobf/if_frw_message,
          lv_rejected TYPE boole_d.

    exit.


  ENDMETHOD.


  METHOD task_finish_tm.
    RECEIVE RESULTS FROM FUNCTION 'ZFMFI_ATUALIZA_DADOS_TM'.

    gv_endfunction = abap_true.

    RETURN.
  ENDMETHOD.


  METHOD agrupador.

    data: lt_mensagens TYPE bapiret2_tab.
    sort gt_agrup by moeda kursf.
    delete adjacent duplicates from gt_agrup comparing all fields.

    loop at gt_agrup assigning field-symbol(<fs_agrup>).
       clear lt_mensagens.
        lt_mensagens = prepara_dados(
          EXPORTING
            iv_simular   = iv_simular
            iv_moeda     = <fs_agrup>-moeda
            iv_kursf     = <fs_agrup>-kursf ).

        append lines of lt_mensagens to rt_mensagens.

        if line_exists( rt_mensagens[ type = 'E' ] ).
           exit.
        endif.
    endloop.

  ENDMETHOD.
ENDCLASS.
