CLASS zclfi_auto_txt_contab DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      "! Separador de texto
      gc_separa_texto(1)      TYPE c VALUE '-',
      "! Tipo documento Lançamento Pagto
      gc_tipodoc_lancto_pagto TYPE zi_fi_autotxt_documentos-blart VALUE 'ZP'.

    TYPES:
      "! Documentos contábeis que terão os textos atualizados
      BEGIN OF ty_documentos_contab,
        bukrs      TYPE zi_fi_cfg_auto_textos_regras-bukrs,
        belnr      TYPE zi_fi_autotxt_documentos-belnr,
        gjahr      TYPE zi_fi_autotxt_documentos-gjahr,
        buzei      TYPE zi_fi_autotxt_documentos-buzei,
        monat      TYPE zi_fi_autotxt_documentos-monat,
        kostl      TYPE zi_fi_autotxt_documentos-kostl,
        lifnr      TYPE zi_fi_autotxt_documentos-lifnr,
        kunnr      TYPE zi_fi_autotxt_documentos-kunnr,
        awkey      TYPE zi_fi_autotxt_documentos-awkey,
        sgtxt      TYPE zi_fi_autotxt_documentos-sgtxt,
        ebeln      TYPE zi_fi_autotxt_documentos-ebeln,
        LifnrName  TYPE zi_fi_autotxt_documentos-LifnrName,
        KunnrName  TYPE zi_fi_autotxt_documentos-KunnrName,
        hkonttxt   TYPE zi_fi_autotxt_documentos-Hkonttxt,
        xblnr      TYPE zi_fi_autotxt_documentos-xblnr,
        budat      TYPE zi_fi_autotxt_documentos-budat,
        PoNumber   TYPE bstnr,
        DocNumber  TYPE vbeln,
        blart      TYPE zi_fi_autotxt_documentos-blart,
        hkont      TYPE zi_fi_autotxt_documentos-hkont,
        bschl      TYPE zi_fi_autotxt_documentos-bschl,
        Dis_flowty TYPE zi_fi_autotxt_documentos-Dis_flowty,
        Gsart      TYPE zi_fi_autotxt_documentos-Gsart,
        processado TYPE abap_bool,
        bktxt      TYPE zi_fi_autotxt_documentos-bktxt,
        projk      TYPE zi_fi_autotxt_documentos-projk,
        aufnr      TYPE zi_fi_autotxt_documentos-aufnr,
      END OF ty_documentos_contab.

    TYPES:
      "! Categ. tabela Doc. contábeis que terão os textos atualizados
      ty_documentos_contab_t TYPE SORTED TABLE OF ty_documentos_contab
        WITH NON-UNIQUE KEY bukrs belnr gjahr buzei,

      "! Categ. tabela Doc. contábeis processados
      ty_documentos_proc_t   TYPE SORTED TABLE OF ty_documentos_contab
        WITH NON-UNIQUE KEY processado bukrs belnr gjahr buzei.

    TYPES:
      "! Regras de preenchimento automático do texto de item
      BEGIN OF ty_regras,
        IdRegra   TYPE zi_fi_cfg_auto_textos_regras-IdRegra,
        Regra     TYPE zi_fi_cfg_auto_textos_regras-Regra,
        Descricao TYPE zi_fi_cfg_auto_textos_regras-Descricao,
        TextoFixo TYPE zi_fi_cfg_auto_textos_regras-TextoFixo,
      END OF ty_regras.

    TYPES:
      "! Categ. Tabela Regras p/ preenchimento automático dos textos
      ty_regras_t TYPE SORTED TABLE OF ty_regras
        WITH NON-UNIQUE KEY IdRegra.

    METHODS:
      "! Inicializa o objeto
      "! @parameter it_bukrs | Range Cód. Empresa
      "! @parameter it_gjahr | Range Exercício
      "! @parameter it_budat | Range data lançamento
      "! @parameter it_belnr | Range documentos
      constructor
        IMPORTING
          it_bukrs TYPE fagl_range_t_bukrs
          it_gjahr TYPE /bglocs/fi_range_gjahr OPTIONAL
          it_budat TYPE t_range_sdate OPTIONAL
          it_belnr TYPE farr_tt_sel_belnr OPTIONAL,

      "! Atualiza os textos contábeis
      execute.

    CLASS-METHODS:

      "! Preenche texto de item de documento tipo AF
      "! @parameter is_bseg   | Segmento contáb.
      "! @parameter is_bkpf   | Cabeçalho doc contáb.
      "! @parameter cv_sgtxt | Texto do item
      preenche_texto_doc_af
        IMPORTING
                  is_bseg  TYPE bseg
                  is_bkpf  TYPE bkpf
        CHANGING  cv_sgtxt TYPE bseg-sgtxt.

  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      "! Categ. tabela para instâncias das regras de preenchimento automático
      ty_selecao_regras_t TYPE TABLE OF REF TO zclfi_autotxt_selecao_regras.

    DATA:
      "! Log de processamento
      go_log TYPE REF TO zclfi_auto_txt_log.

    DATA:
      "! Doc. contábeis que terão os textos atualizados
      gt_documentos_contab TYPE ty_documentos_contab_t,
      "! Regras p/ preenchimento automático dos textos
      gt_selecao_regras    TYPE ty_selecao_regras_t,
      "! Data de lançamento
      gt_sel_budat         TYPE t_range_sdate,
      "! Range Documentos
      gt_sel_belnr         TYPE farr_tt_sel_belnr,
      "! Range Cód. Empresa
      gt_sel_bukrs         TYPE fagl_range_t_bukrs,
      "! Ano Exercício
      gt_sel_gjahr         TYPE /bglocs/fi_range_gjahr.

    METHODS:

      "! Busca número de pedido
      "! @parameter iv_gjahr | Ano de exercício
      "! @parameter iv_ebeln | Num. pedido
      busca_pedido
        IMPORTING
                  iv_gjahr         TYPE gjahr
                  iv_ebeln         TYPE ebeln
        RETURNING VALUE(rv_result) TYPE bstnr,

      "! Busca número de documento de vendas
      "! @parameter iv_awkey | Ordem de venda
      busca_docvendas
        IMPORTING
                  iv_awkey         TYPE awkey
        RETURNING VALUE(rv_result) TYPE vbeln,

      "! Seleciona documentos para preencher os textos contábeis
      "! @parameter rt_result | Lista documentos
      seleciona_documentos
        RETURNING VALUE(rt_result) TYPE ty_documentos_contab_t,

      "! Seleciona regras para preenchimento dos textos contábeis
      seleciona_regras,
      trata_lancto_pagto
        CHANGING
          ct_documentos_contab TYPE zclfi_auto_txt_contab=>ty_documentos_contab_t.

ENDCLASS.



CLASS ZCLFI_AUTO_TXT_CONTAB IMPLEMENTATION.


  METHOD constructor.

    me->go_log = NEW zclfi_auto_txt_log(  ).

    me->gt_sel_bukrs = it_bukrs.

    me->gt_sel_gjahr = it_gjahr.

    me->gt_sel_belnr = it_belnr.

    me->gt_sel_budat = it_budat.

    me->seleciona_regras( ).

  ENDMETHOD.


  METHOD execute.

    TYPES:
      BEGIN OF ty_regras_sem_campos,
        idregra TYPE zi_fi_cfg_auto_textos_regras-IdRegra,
        regra   TYPE  zi_fi_cfg_auto_textos_regras-Regra,
      END OF ty_regras_sem_campos.

    DATA:
      lt_regras_sem_campos TYPE SORTED TABLE OF ty_regras_sem_campos WITH UNIQUE KEY idregra.

    DATA:
      lv_texto_contab TYPE bseg-sgtxt.

    DATA(lt_documentos) = me->seleciona_documentos( ).

    IF lt_documentos IS INITIAL.
      RETURN.
    ENDIF.

    IF me->gt_selecao_regras IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT me->gt_selecao_regras ASSIGNING FIELD-SYMBOL(<fs_regras>).

      <fs_regras>->executa(
        CHANGING
          ct_documentos = lt_documentos
      ).

    ENDLOOP.

    LOOP AT lt_documentos ASSIGNING FIELD-SYMBOL(<fs_documento>).

      IF <fs_documento>-processado EQ abap_true.
        CONTINUE.
      ENDIF.

      IF me->go_log IS BOUND.

        me->go_log->insert_log(
          EXPORTING
            is_message = VALUE #(
                            type = if_xo_const_message=>info
                            number = 020
                            message_v1 = CONV #( |{ <fs_documento>-belnr } { <fs_documento>-buzei }| )
                            message_v2 = CONV #( <fs_documento>-bukrs )
                            message_v3 = CONV #( <fs_documento>-gjahr ) )
        ).

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD seleciona_documentos.

    SELECT DISTINCT
        Doc~bukrs,
        Doc~belnr,
        Doc~gjahr,
        Doc~buzei,
        Doc~monat,
        Doc~kostl,
        Doc~lifnr,
        Doc~kunnr,
        Doc~awkey,
        Doc~sgtxt,
        Doc~ebeln,
        Doc~LifnrName,
        Doc~KunnrName,
        Doc~HkontTxt,
        Doc~xblnr,
        Doc~budat,
        Doc~blart,
        Doc~hkont,
        Doc~bschl,
        Doc~dis_flowty,
        Doc~gsart,
        Doc~bktxt,
        Doc~projk,
        Doc~aufnr
    FROM zi_fi_autotxt_documentos AS Doc
    WHERE Doc~bukrs IN @me->gt_sel_bukrs
        AND gjahr IN @me->gt_sel_gjahr
        AND budat IN @me->gt_sel_budat
        AND belnr IN @me->gt_sel_belnr
    INTO TABLE @DATA(lt_documentos).

    IF lt_documentos IS INITIAL.

      me->go_log->insert_log(
        EXPORTING
          is_message = VALUE #(
                          type = if_xo_const_message=>error
                          number = 007 )
      ).

      RETURN.

    ENDIF.

    me->gt_documentos_contab = VALUE #( FOR ls_documentos IN lt_documentos
        (   belnr                            = ls_documentos-belnr
            gjahr                            = ls_documentos-gjahr
            buzei                            = ls_documentos-buzei
            monat                            = ls_documentos-monat
            kostl                            = ls_documentos-kostl
            lifnr                            = ls_documentos-lifnr
            kunnr                            = ls_documentos-kunnr
            awkey                            = ls_documentos-awkey
            sgtxt                            = ls_documentos-sgtxt
            ebeln                            = ls_documentos-ebeln
            LifnrName                        = ls_documentos-LifnrName
            KunnrName                        = ls_documentos-KunnrName
            HkontTxt                         = ls_documentos-HkontTxt
            xblnr                            = ls_documentos-xblnr
            budat                            = ls_documentos-budat
            bukrs                            = ls_documentos-bukrs
            blart                            = ls_documentos-blart
            hkont                            = ls_documentos-hkont
            bschl                            = ls_documentos-bschl
            dis_flowty                       = ls_documentos-dis_flowty
            Gsart                            = ls_documentos-gsart
            ponumber                         = ls_documentos-ebeln
            docnumber                        = me->busca_docvendas( ls_documentos-awkey )
            bktxt                            = ls_documentos-bktxt
            projk                            = ls_documentos-projk
            aufnr                            = ls_documentos-aufnr
        )
    ).

    LOOP AT me->gt_documentos_contab REFERENCE INTO DATA(ls_contab).

      CHECK ls_contab->projk IS NOT INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
        EXPORTING
          input  = ls_contab->projk
        IMPORTING
          output = ls_contab->projk.

    ENDLOOP.


    me->trata_lancto_pagto( CHANGING ct_documentos_contab = me->gt_documentos_contab ).

    rt_result = me->gt_documentos_contab.


  ENDMETHOD.


  METHOD busca_docvendas.

    TYPES:
      ty_docflow_sort_t TYPE SORTED TABLE OF tds_docflow WITH UNIQUE KEY vbtyp.

    CONSTANTS:
      lc_tipo_ordem TYPE tds_docflow-vbtyp VALUE 'C'.

    DATA:
      lt_docflow      TYPE tdt_docflow,
      lt_docflow_sort TYPE ty_docflow_sort_t,
      lt_vbfa         TYPE STANDARD TABLE OF vbfas.

    DATA:
      ls_comwa TYPE vbco6.

    DATA:
      lv_docnum TYPE vbeln.

    IF iv_awkey IS INITIAL.
      RETURN.
    ENDIF.

    lv_docnum = iv_awkey.

    ls_comwa-vbeln = lv_docnum.

*    CALL FUNCTION 'SD_DOCUMENT_FLOW_GET'
*      EXPORTING
*        iv_docnum     = lv_docnum
*        iv_all_items  = abap_true
*      IMPORTING
*        et_docflow    = lt_docflow
*      EXCEPTIONS
*        error_message = 1
*        OTHERS        = 2.
*
*    lt_docflow_sort = lt_docflow.
*
*    TRY.
*
*        rv_result = lt_docflow_sort[ vbtyp = lc_tipo_ordem ]-docnum.
*
*      CATCH cx_sy_itab_line_not_found.
*        RETURN.
*    ENDTRY.


    CALL FUNCTION 'RV_ORDER_FLOW_INFORMATION'
      EXPORTING
        comwa         = ls_comwa
      TABLES
        vbfa_tab      = lt_vbfa
      EXCEPTIONS
        no_vbfa       = 1
        no_vbuk_found = 2
        OTHERS        = 3.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.


    SORT lt_vbfa BY vbtyp_n.
    READ TABLE lt_vbfa INTO DATA(ls_vbfa)
        WITH KEY vbtyp_n = lc_tipo_ordem
        BINARY SEARCH.
    IF sy-subrc EQ 0.
      rv_result = ls_vbfa-vbeln.
    ENDIF.

  ENDMETHOD.


  METHOD busca_pedido.

    DATA:
      lt_invoice_item TYPE STANDARD TABLE OF bapi_incinv_detail_item,
      lt_return       TYPE bapiret2_tab.

    DATA:
      lv_invoice    TYPE bapi_incinv_fld-inv_doc_no,
      lv_fiscalyear TYPE bapi_incinv_fld-fisc_year.


    IF iv_ebeln IS INITIAL
      OR iv_gjahr IS INITIAL.

      RETURN.

    ENDIF.

    lv_invoice    = iv_ebeln.
    lv_fiscalyear = iv_gjahr.

    CALL FUNCTION 'BAPI_INCOMINGINVOICE_GETDETAIL'
      EXPORTING
        invoicedocnumber = lv_invoice
        fiscalyear       = lv_fiscalyear
      TABLES
        itemdata         = lt_invoice_item
        return           = lt_return.

    TRY.

        rv_result = lt_invoice_item[ 1 ]-po_number.

      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.


  ENDMETHOD.


  METHOD seleciona_regras.

    SELECT
        IdRegra,
        Regra,
        Descricao,
        TextoFixo
    FROM zi_fi_cfg_auto_textos_regras
    WHERE Regra NE ''
    INTO TABLE @DATA(lt_regras).

    IF sy-subrc NE 0.
      " Erro
      RETURN.
    ENDIF.

    LOOP AT lt_regras ASSIGNING FIELD-SYMBOL(<fs_regras>).

      DATA(lo_regra) = NEW zclfi_autotxt_selecao_regras(
        is_regra = <fs_regras>
        io_log   = me->go_log
      ).
      APPEND lo_regra TO me->gt_selecao_regras.

    ENDLOOP.

  ENDMETHOD.


  METHOD preenche_texto_doc_af.

    CONSTANTS:
      lc_tipo_lanctos_deprec TYPE bkpf-blart VALUE 'AF',
      lc_texto_inicial(3)    TYPE c VALUE 'VR.',
      lc_separa_data(1)      TYPE c VALUE '/'.

    DATA:
      lv_texto_atualizado TYPE bseg-sgtxt.

    IF is_bkpf-blart NE lc_tipo_lanctos_deprec.
      RETURN.
    ENDIF.

    SELECT SINGLE glaccountname
      FROM p_glaccounttext AS account_txt
      INNER JOIN I_CompanyCode AS company
        ON account_txt~chartofaccounts = company~chartofaccounts
      WHERE account_txt~language  = @sy-langu
        AND account_txt~glaccount = @is_bseg-hkont
        AND company~companycode   = @is_bseg-bukrs
        INTO @DATA(lv_hkont_text).

    IF sy-subrc NE 0.
      CLEAR lv_hkont_text.
    ENDIF.

    lv_texto_atualizado = lc_texto_inicial && gc_separa_texto &&
                          |{ lv_hkont_text }| && gc_separa_texto &&
                          |{ sy-datum+4(2) }| && gc_separa_texto &&
                          lc_separa_data && gc_separa_texto &&
                          |{ sy-datum(4) }|.

    cv_sgtxt = lv_texto_atualizado.

  ENDMETHOD.


  METHOD trata_lancto_pagto.

    DATA: lt_partida_fornecedor TYPE STANDARD TABLE OF ty_documentos_contab.

    FREE lt_partida_fornecedor[].

    lt_partida_fornecedor = me->gt_documentos_contab.
    SORT lt_partida_fornecedor BY blart.

    READ TABLE lt_partida_fornecedor TRANSPORTING NO FIELDS
                                                   WITH KEY blart = gc_tipodoc_lancto_pagto
                                                   BINARY SEARCH.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    " Mantém somente partidas de fornecedor para tipo de documento ZP
    FREE lt_partida_fornecedor.
    lt_partida_fornecedor = me->gt_documentos_contab.

    LOOP AT lt_partida_fornecedor ASSIGNING FIELD-SYMBOL(<fs_partida_fornecedor>).

      DATA(lv_partida_tabix) = sy-tabix.

      IF <fs_partida_fornecedor>-blart NE gc_tipodoc_lancto_pagto.
        DELETE lt_partida_fornecedor INDEX lv_partida_tabix.
        CONTINUE.
      ENDIF.

      IF <fs_partida_fornecedor>-lifnr IS INITIAL.
        DELETE lt_partida_fornecedor INDEX lv_partida_tabix.
        CONTINUE.
      ENDIF.

    ENDLOOP.

    SORT lt_partida_fornecedor BY bukrs belnr gjahr blart.

    LOOP AT me->gt_documentos_contab ASSIGNING FIELD-SYMBOL(<fs_doc_contab>).

      IF <fs_doc_contab>-blart NE gc_tipodoc_lancto_pagto.
        CONTINUE.
      ENDIF.

      IF <fs_doc_contab>-lifnr IS INITIAL.

        READ TABLE lt_partida_fornecedor ASSIGNING <fs_partida_fornecedor>
            WITH KEY bukrs = <fs_doc_contab>-bukrs
                     belnr = <fs_doc_contab>-belnr
                     gjahr = <fs_doc_contab>-gjahr BINARY SEARCH.

        IF sy-subrc EQ 0.

          <fs_doc_contab>-lifnr = <fs_partida_fornecedor>-lifnr.
          <fs_doc_contab>-lifnrname = <fs_partida_fornecedor>-lifnrname.

        ENDIF.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
