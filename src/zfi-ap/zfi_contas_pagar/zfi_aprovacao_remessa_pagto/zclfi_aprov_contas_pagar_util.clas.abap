"! <p class="shorttext synchronized">Classe Aprovação de Contas a Pagar</p>
"! Autor: Jefferson Fujii
"! <br>Data: 17/09/2021
"!
CLASS zclfi_aprov_contas_pagar_util DEFINITION PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: ty_xflag TYPE x LENGTH 1,

           BEGIN OF ty_bsak,
             companycode              TYPE i_paymentproposalheader-payingcompanycode,
             netduedate               TYPE datum,
             reptype                  TYPE string,
             cashplanninggroup        TYPE i_suppliercompany-cashplanninggroup,
             cashplanninggroupname    TYPE i_planninggrouptext-cashplanninggroupname,
             companycodename          TYPE i_companycode-companycodename,
             paidamountinpaytcurrency TYPE regut-rbetr,
             paymentcurrency          TYPE regut-waers,
             runhour                  TYPE regut-tstim,
             laufd                    TYPE i_paymentproposalheader-paymentrundate,
             laufi                    TYPE i_paymentproposalheader-paymentrunid,
             xvorl                    TYPE i_paymentproposalheader-paymentrunisproposal,
           END OF ty_bsak,

           BEGIN OF ty_regup,
             laufd TYPE laufd,
             laufi TYPE laufi,
             xvorl TYPE xvorl,
             zbukr TYPE dzbukr,
             zfbdt TYPE dzfbdt,
             hbkid TYPE reguh-hbkid,
             rzawe TYPE reguh-rzawe,
           END OF ty_regup,

           BEGIN OF ty_docs,
             companycode       TYPE bukrs,
             netduedate        TYPE netdt,
             cashplanninggroup TYPE fdgrv,
             paymentdocument   TYPE bseg-augbl,
             document          TYPE bseg-belnr,
             dmbtr             TYPE bseg-dmbtr,
             tipo              TYPE ze_tiporel,
             bstat             TYPE bseg-h_bstat,
             gjahr             TYPE gjahr,
           END OF ty_docs,

           ty_t_bsak  TYPE TABLE OF ty_bsak,
           ty_t_regup TYPE TABLE OF ty_regup,
           ty_t_docs  TYPE TABLE OF ty_docs.

    DATA:
      "! <p class="shorttext synchronized">Tabela de Contas</p>
      gt_aprov_contas_pagar TYPE TABLE OF zc_fi_aprov_contas_pagar,
      "! <p class="shorttext synchronized">Tabela de Documentos</p>
      gt_aprov_doc_pgto     TYPE TABLE OF zc_fi_aprov_doc_pgto.

    "! <p class="shorttext synchronized">Método Extrair Contas</p>
    "! @parameter rt_return | <p class="shorttext synchronized">Retorno</p>
    METHODS get_contas_pagar IMPORTING it_filtro_ranges TYPE if_rap_query_filter=>tt_name_range_pairs
                                       iv_filtro_aprov  TYPE abap_bool DEFAULT abap_true
                             RETURNING VALUE(rt_return) LIKE gt_aprov_contas_pagar.

    "! <p class="shorttext synchronized">Método Extrair Contas</p>
    "! @parameter rt_return | <p class="shorttext synchronized">Retorno</p>
    METHODS get_contas_pagar_2 IMPORTING it_filtro_ranges TYPE if_rap_query_filter=>tt_name_range_pairs
                                         iv_filtro_aprov  TYPE abap_bool DEFAULT abap_true
                               RETURNING VALUE(rt_return) LIKE gt_aprov_contas_pagar.

    "! <p class="shorttext synchronized">Método Extrair Documentos</p>
    "! @parameter rt_return | <p class="shorttext synchronized">Retorno</p>
    METHODS get_doc_pgto
      IMPORTING
        it_filtro_ranges TYPE if_rap_query_filter=>tt_name_range_pairs
      RETURNING
        VALUE(rt_return) LIKE gt_aprov_doc_pgto.

    METHODS get_doc_pgto2
      IMPORTING
        it_filtro_ranges TYPE if_rap_query_filter=>tt_name_range_pairs
      RETURNING
        VALUE(rt_return) LIKE gt_aprov_doc_pgto.

    "! <p class="shorttext synchronized">Método para Aprovação</p>
    "! @parameter ct_entity | <p class="shorttext synchronized">Entidade de entrada</p>
    METHODS approve
*      IMPORTING is_entity        TYPE zc_fi_aprov_contas_pagar
      CHANGING ct_entity TYPE zctgfi_aprov_remessa.
*      RETURNING VALUE(rs_return) TYPE zc_fi_aprov_contas_pagar.

    "! <p class="shorttext synchronized">Atualizada grupo tesouraria</p>
    "! @parameter it_doc_fdgrv | <p class="shorttext synchronized">Entidade de entrada</p>
    METHODS set_fdgrv
      IMPORTING it_doc_fdgrv TYPE zctgfi_doc_fdgrv.

    "! <p class="shorttext synchronized">Metodo para executar BAPI document post
    "! @parameter p_task | Parâmetro standard
    METHODS task_finish_grupoteso
      IMPORTING
        !p_task TYPE clike.

    "! <p class="shorttext synchronized">Método para features</p>
    "! @parameter iv_bukrs | <p class="shorttext synchronized">Empresa</p>
    "! @parameter iv_nivel | <p class="shorttext synchronized">Nível</p>
    "! @parameter rv_return | <p class="shorttext synchronized">Retorno</p>
    CLASS-METHODS get_features IMPORTING iv_bukrs         TYPE bukrs
                                         iv_nivel         TYPE ze_nivel_aprov
                               RETURNING VALUE(rv_return) TYPE ty_xflag.
  PROTECTED SECTION.

    DATA: gt_approver TYPE SORTED TABLE OF ty_approver WITH UNIQUE KEY bukrs uname nivel.

    DATA: gv_reptype     TYPE ze_tiporel,
          gv_endfunction.

  PRIVATE SECTION.

    DATA:
      "! Lista de filtros range da tela
      gt_filtro_ranges  TYPE if_rap_query_filter=>tt_name_range_pairs.

    "! <p class="shorttext synchronized">Método para buscar Range</p>
    "! @parameter iv_name | <p class="shorttext synchronized">Nome do parâmetro</p>
    "! @parameter rt_retorno | <p class="shorttext synchronized">Range</p>
    METHODS buscar_range_filtro
      IMPORTING
        iv_name           TYPE string
      RETURNING
        VALUE(rt_retorno) TYPE if_rap_query_filter=>tt_range_option.

    "! <p class="shorttext synchronized">Método para fazer o download do arquivo</p>
    "! @parameter it_entity | <p class="shorttext synchronized">Estrutura da entidade</p>
    METHODS download_file
*    IMPORTING is_entity         TYPE zc_fi_aprov_contas_pagar
      IMPORTING it_entity TYPE zctgfi_aprov_remessa.
*                          RETURNING VALUE(rs_message) TYPE bapiret2.

    "! <p class="shorttext synchronized">Método Busca Aprovadores.</p>
    METHODS get_aprovadores IMPORTING ir_bukrs        TYPE if_rap_query_filter=>tt_range_option
                                      ir_netdt        TYPE if_rap_query_filter=>tt_range_option
                                      iv_filtro_aprov TYPE abap_bool DEFAULT abap_true.

    METHODS get_pagamentos IMPORTING iv_filtro_aprov TYPE abap_bool DEFAULT abap_true
                                     it_regup        TYPE ty_t_regup
                           EXPORTING et_bsak         TYPE ty_t_bsak.
ENDCLASS.



CLASS ZCLFI_APROV_CONTAS_PAGAR_UTIL IMPLEMENTATION.


  METHOD buscar_range_filtro.

    rt_retorno = VALUE #( BASE rt_retorno FOR ls_range IN gt_filtro_ranges WHERE ( name = iv_name ) ( CORRESPONDING #( ls_range-range[ 1 ] ) ) ).

*    READ TABLE gt_filtro_ranges ASSIGNING FIELD-SYMBOL(<fs_filtro_ranges>) WITH KEY name = iv_name .
*    IF sy-subrc = 0.
*      rt_retorno = <fs_filtro_ranges>-range.
*    ENDIF.

  ENDMETHOD.


  METHOD get_contas_pagar.

    TYPES:
      BEGIN OF ty_approver,
        nivel TYPE ze_nivel_aprov,
      END OF ty_approver,

      BEGIN OF ty_authorization,
        is_enc TYPE xfeld,
        is_ap1 TYPE xfeld,
        is_ap2 TYPE xfeld,
        is_ap3 TYPE xfeld,
      END OF ty_authorization,

      BEGIN OF ty_bsik_sum,
        cashplanninggroup TYPE fdgrp,
        zlspr             TYPE bsik_view-zlspr,
        dmbtr             TYPE bsik_view-dmbtr,
      END OF ty_bsik_sum.


    DATA: lt_approver      TYPE SORTED TABLE OF ty_approver WITH UNIQUE KEY nivel,
*          lt_bsak          TYPE TABLE OF ty_bsak,
          lt_bsik_sum      TYPE TABLE OF ty_bsik_sum,
          ls_authorization TYPE ty_authorization.

    gt_filtro_ranges = CORRESPONDING #( it_filtro_ranges ).

    DATA(lr_bukrs)    = buscar_range_filtro( 'COMPANYCODE' ).
    DATA(lr_netdt)    = buscar_range_filtro( 'NETDUEDATE' ).
    DATA(lr_tiporel)  = buscar_range_filtro( 'REPTYPE' ).

    TRY.
        DATA(lv_reptype) = lr_tiporel[ 1 ]-low.
        DATA(lv_netduedate) = lr_netdt[ 1 ]-low.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    "//AuthorityCreate.
    DATA lv_bukrs TYPE bukrs.

    lv_bukrs = lr_bukrs[ 1 ]-low.

    CHECK zclfi_auth_zfibukrs=>check_custom(
              EXPORTING
                iv_bukrs = lv_bukrs
                iv_actvt = zclfi_auth_zfibukrs=>gc_actvt-exibir ).

    SELECT DISTINCT nivel
      FROM ztfi_apvdrs_pgto
      INTO TABLE @lt_approver
      WHERE bukrs IN @lr_bukrs
        AND uname EQ @sy-uname
        AND endda GE @sy-datum
        AND begda LE @sy-datum
    ORDER BY nivel.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    CLEAR ls_authorization.
    LOOP AT lt_approver ASSIGNING FIELD-SYMBOL(<fs_approver>).
      CASE <fs_approver>-nivel.
        WHEN '0'. " Encerrador
          ls_authorization-is_enc = abap_true.
        WHEN '1'. " Aprovador 1
          ls_authorization-is_ap1 = abap_true.
        WHEN '2'. " Aprovador 2
          ls_authorization-is_ap2 = abap_true.
        WHEN '3'. " Aprovador 3
          ls_authorization-is_ap3 = abap_true.
      ENDCASE.
    ENDLOOP.

    SELECT fdgrv,
           hora,
           tiporel,
           encerrador,
           aprov1,
           aprov2,
           aprov3
      FROM ztfi_log_apv_pgt
      INTO TABLE @DATA(lt_log)
      WHERE bukrs IN @lr_bukrs
        AND data  IN @lr_netdt.
    SORT lt_log BY fdgrv hora.

    SELECT SINGLE text
      FROM zi_fi_vh_tiporel AS reptypetext
      WHERE value = @lv_reptype
      INTO @DATA(lv_reptypetext).

    SELECT gup~laufd,
           gup~laufi,
           gup~xvorl,
           gup~zbukr,
           gup~zfbdt,
           guh~hbkid,
           guh~rzawe
      FROM regup AS gup
      INNER JOIN reguh AS guh ON
        guh~laufd = gup~laufd AND
        guh~laufi = gup~laufi AND
        guh~xvorl = gup~xvorl AND
        guh~zbukr = gup~zbukr AND
        guh~lifnr = gup~lifnr AND
        guh~kunnr = gup~kunnr AND
        guh~empfg = gup~empfg AND
        guh~vblnr = gup~vblnr
      WHERE gup~zbukr IN @lr_bukrs
        AND gup~laufd IN @lr_netdt
*        AND gup~zfbdt IN @lr_netdt
      INTO TABLE @DATA(lt_regup).
    SORT lt_regup BY laufd laufi xvorl zbukr.

    IF lt_regup IS NOT INITIAL.
*      SELECT i_paymentproposalheader~payingcompanycode AS companycode,
*             CAST( i_paymentproposalheader~paymentrundate  AS DATS ) AS netduedate,
*             @lv_reptype AS reptype,
*             i_suppliercompany~cashplanninggroup,
*             i_planninggrouptext~cashplanninggroupname,
*             i_companycode~companycodename,
*             regut~rbetr AS paidamountinpaytcurrency,
*             regut~waers AS paymentcurrency,
*             regut~tstim AS runhour
*        FROM regut
*        INNER JOIN i_paymentproposalheader
*          ON  i_paymentproposalheader~payingcompanycode EQ regut~zbukr
*          AND i_paymentproposalheader~paymentrundate EQ regut~laufd
*          AND i_paymentproposalheader~paymentrunid EQ regut~laufi
*          AND i_paymentproposalheader~paymentrunisproposal EQ regut~xvorl
*          AND i_paymentproposalheader~paymentorigin EQ regut~grpno
*        INNER JOIN i_companycode
*          ON  i_companycode~companycode EQ i_paymentproposalheader~payingcompanycode
*        INNER JOIN i_suppliercompany
*          ON  i_suppliercompany~supplier    EQ i_paymentproposalheader~supplier
*          AND i_suppliercompany~companycode EQ i_paymentproposalheader~payingcompanycode
*        LEFT OUTER JOIN i_planninggrouptext
*          ON  i_planninggrouptext~cashplanninggroup EQ i_suppliercompany~cashplanninggroup
*          AND i_planninggrouptext~language EQ @sy-langu
*        WHERE regut~zbukr IN @lr_bukrs
*          AND regut~lfdnr EQ 1
*          AND regut~dwdat IS INITIAL
*          AND regut~tsdat IN @lr_netdt
*        INTO TABLE @DATA(lt_bsak).

      me->get_pagamentos( EXPORTING iv_filtro_aprov = iv_filtro_aprov
                                    it_regup        = lt_regup
                          IMPORTING et_bsak         = DATA(lt_bsak) ).

*      SELECT i_paymentproposalheader~payingcompanycode AS companycode,
*             i_suppliercompany~cashplanninggroup,
*             i_planninggrouptext~cashplanninggroupname,
*             i_companycode~companycodename,
*             regut~rbetr AS paidamountinpaytcurrency,
*             regut~waers AS paymentcurrency,
*             regut~tstim AS runhour,
*             i_paymentproposalheader~paymentrundate AS laufd,
*             i_paymentproposalheader~paymentrunid AS laufi,
*             i_paymentproposalheader~paymentrunisproposal AS xvorl
*        FROM regut
*        INNER JOIN i_paymentproposalheader
*          ON  i_paymentproposalheader~payingcompanycode EQ regut~zbukr
*          AND i_paymentproposalheader~paymentrundate EQ regut~laufd
*          AND i_paymentproposalheader~paymentrunid EQ regut~laufi
*          AND i_paymentproposalheader~paymentrunisproposal EQ regut~xvorl
*          AND i_paymentproposalheader~paymentorigin EQ regut~grpno
*        INNER JOIN i_companycode
*          ON  i_companycode~companycode EQ i_paymentproposalheader~payingcompanycode
*        INNER JOIN i_suppliercompany
*          ON  i_suppliercompany~supplier    EQ i_paymentproposalheader~supplier
*          AND i_suppliercompany~companycode EQ i_paymentproposalheader~payingcompanycode
*        LEFT OUTER JOIN i_planninggrouptext
*          ON  i_planninggrouptext~cashplanninggroup EQ i_suppliercompany~cashplanninggroup
*          AND i_planninggrouptext~language EQ @sy-langu
*        FOR ALL ENTRIES IN @lt_regup
*        WHERE regut~zbukr EQ @lt_regup-zbukr
*          AND regut~laufd EQ @lt_regup-laufd
*          AND regut~laufi EQ @lt_regup-laufi
*          AND regut~xvorl EQ @lt_regup-xvorl
*          AND regut~lfdnr EQ 1
**          AND regut~dwdat IS INITIAL
*        INTO CORRESPONDING FIELDS OF TABLE @lt_bsak.
    ENDIF.

    IF sy-datum EQ lv_netduedate.
      DATA(lv_hora_atual) = sy-uzeit.
    ELSE.
      lv_hora_atual = '235959'.
    ENDIF.

    FREE rt_return.
    LOOP AT lt_bsak ASSIGNING FIELD-SYMBOL(<fs_bsak>).
      READ TABLE lt_regup INTO DATA(ls_regup)
        WITH KEY laufd = <fs_bsak>-laufd
                 laufi = <fs_bsak>-laufi
                 xvorl = <fs_bsak>-xvorl
                 zbukr = <fs_bsak>-companycode BINARY SEARCH.

      <fs_bsak>-netduedate = ls_regup-zfbdt.
      <fs_bsak>-reptype    = lv_reptype.

      DATA(ls_result) = CORRESPONDING zc_fi_aprov_contas_pagar( <fs_bsak> ).

      ls_result-reptype     = lv_reptype.
      ls_result-reptypetext = lv_reptypetext.

      CLEAR: ls_result-runhourfrom.
      ls_result-runhourto = lv_hora_atual.

      READ TABLE lt_log TRANSPORTING NO FIELDS
        WITH KEY fdgrv = <fs_bsak>-cashplanninggroup BINARY SEARCH.
      IF sy-subrc NE 0.
        CHECK lv_reptype EQ 'P'. " Pagamentos
      ELSE.
        READ TABLE lt_log TRANSPORTING NO FIELDS
          WITH KEY fdgrv = <fs_bsak>-cashplanninggroup
                   hora  = <fs_bsak>-runhour BINARY SEARCH.
        DATA(lv_tabix) = sy-tabix.

        READ TABLE lt_log INTO DATA(ls_log) INDEX lv_tabix.
        IF  sy-subrc     EQ 0
        AND ls_log-fdgrv EQ <fs_bsak>-cashplanninggroup.

          ls_result-runhourto   = ls_log-hora.

          CHECK lv_reptype EQ ls_log-tiporel.

          IF ls_log-tiporel EQ 'E'.
            READ TABLE lt_log INTO DATA(ls_log_anterior) INDEX lv_tabix - 1.
            IF  sy-subrc              EQ 0
            AND ls_log_anterior-fdgrv EQ <fs_bsak>-cashplanninggroup.
              ls_result-runhourfrom = ls_log_anterior-hora.
            ENDIF.
          ENDIF.

          ls_result-encerrador = ls_log-encerrador.
          ls_result-aprov1     = ls_log-aprov1.
          ls_result-aprov2     = ls_log-aprov2.
          ls_result-aprov3     = ls_log-aprov3.
        ENDIF.
      ENDIF.

      CASE space.
        WHEN ls_result-encerrador.
          CHECK ls_authorization-is_enc EQ abap_true.
        WHEN ls_result-aprov1.
          CHECK ls_authorization-is_ap1 EQ abap_true.
        WHEN ls_result-aprov2.
          CHECK ls_authorization-is_ap2 EQ abap_true.
        WHEN ls_result-aprov3.
          CHECK ls_authorization-is_ap3 EQ abap_true.
      ENDCASE.

      COLLECT ls_result INTO rt_return.
      FREE: ls_result.
    ENDLOOP.

    SELECT  bsik~bukrs,
            bsik~belnr,
            bsik~gjahr,
            bsik~buzei,
            i_suppliercompany~cashplanninggroup,
            bsik~zlspr,
            bsik~dmbtr
      FROM bsik_view AS bsik
      INNER JOIN bseg
        ON  bseg~bukrs EQ bsik~bukrs
        AND bseg~belnr EQ bsik~belnr
        AND bseg~gjahr EQ bsik~gjahr
        AND bseg~buzei EQ bsik~buzei
      INNER JOIN i_suppliercompany
        ON  i_suppliercompany~supplier    EQ bsik~lifnr
        AND i_suppliercompany~companycode EQ bsik~bukrs
      WHERE bsik~bukrs IN @lr_bukrs
        AND bsik~bschl IN ('31','39')
        AND bsik~shkzg EQ 'H'
        AND bsik~umskz NE 'F'
        AND bseg~netdt IN @lr_netdt
      ORDER BY cashplanninggroup, bsik~zlspr
      INTO TABLE @DATA(lt_bsik).

    FREE lt_bsik_sum.
    LOOP AT lt_bsik ASSIGNING FIELD-SYMBOL(<fs_bsik>).
      DATA(ls_bsik_sum) = VALUE ty_bsik_sum(
        cashplanninggroup = <fs_bsik>-cashplanninggroup
        zlspr             = COND #( WHEN <fs_bsik>-zlspr = abap_false THEN abap_false ELSE abap_true )
        dmbtr             = <fs_bsik>-dmbtr ).
      COLLECT ls_bsik_sum INTO lt_bsik_sum.
      FREE ls_bsik_sum.
    ENDLOOP.
    SORT lt_bsik_sum BY cashplanninggroup zlspr.


    LOOP AT rt_return ASSIGNING FIELD-SYMBOL(<fs_result>).
      READ TABLE lt_bsik_sum INTO ls_bsik_sum
        WITH KEY cashplanninggroup = <fs_result>-cashplanninggroup
                 zlspr             = abap_false BINARY SEARCH.
      IF sy-subrc EQ 0.
        <fs_result>-openamount = ls_bsik_sum-dmbtr.
      ENDIF.

      READ TABLE lt_bsik_sum INTO ls_bsik_sum
        WITH KEY cashplanninggroup = <fs_result>-cashplanninggroup
                 zlspr             = abap_true BINARY SEARCH.
      IF sy-subrc EQ 0.
        <fs_result>-blockedamount = ls_bsik_sum-dmbtr.
      ENDIF.

      <fs_result>-encerradorcrit = COND #( WHEN <fs_result>-encerrador = abap_true THEN 3 ELSE 0 ).
      <fs_result>-encerradortext = COND #( WHEN <fs_result>-encerrador = abap_true THEN TEXT-apv  ELSE TEXT-pdt ).

      <fs_result>-aprov1crit = COND #( WHEN <fs_result>-aprov1 = abap_true THEN 3 ELSE 0 ).
      <fs_result>-aprov1text = COND #( WHEN <fs_result>-aprov1 = abap_true THEN TEXT-apv ELSE TEXT-pdt ).

      <fs_result>-aprov2crit = COND #( WHEN <fs_result>-aprov2 = abap_true THEN 3 ELSE 0 ).
      <fs_result>-aprov2text = COND #( WHEN <fs_result>-aprov2 = abap_true THEN TEXT-apv ELSE TEXT-pdt ).

      <fs_result>-aprov3crit = COND #( WHEN <fs_result>-aprov3 = abap_true THEN 3 ELSE 0 ).
      <fs_result>-aprov3text = COND #( WHEN <fs_result>-aprov3 = abap_true THEN TEXT-apv ELSE TEXT-pdt ).

    ENDLOOP.

  ENDMETHOD.


  METHOD get_doc_pgto.

    TYPES: BEGIN OF ty_filter,
             name_runhourto         TYPE char10,
             runhourto              TYPE uzeit,
             name_runhourfrom       TYPE char15,
             runhourfrom            TYPE uzeit,
             name_netduedate        TYPE char14,
             netduedate             TYPE datum,
             name_companycode       TYPE char15,
             companycode            TYPE bukrs,
             name_cashplanninggroup TYPE char21,
             cashplanninggroup      TYPE fdgrv,
           END OF ty_filter,


           BEGIN OF ty_payment_sel,
             companycode       TYPE i_paymentproposalheader-payingcompanycode,
             netduedate        TYPE datum,
             cashplanninggroup TYPE i_suppliercompany-cashplanninggroup,
             runhour           TYPE regut-tstim,
             paymentdocument   TYPE bsak_view-augbl,
             laufd             TYPE i_paymentproposalheader-paymentrundate,
             laufi             TYPE i_paymentproposalheader-paymentrunid,
             xvorl             TYPE i_paymentproposalheader-paymentrunisproposal,
           END OF ty_payment_sel.

    DATA: lt_filter      TYPE TABLE OF ty_filter,
          lt_payment_sel TYPE TABLE OF ty_payment_sel,
          lt_url         LIKE rt_return,
          lv_apost       TYPE char2.

    gt_filtro_ranges = CORRESPONDING #( it_filtro_ranges ).
    DATA(lr_bukrs)    = buscar_range_filtro( 'COMPANYCODE' ).
    DATA(lr_netdt)    = buscar_range_filtro( 'NETDUEDATE' ).
    DATA(lr_cashplanninggroup) = buscar_range_filtro( 'CASHPLANNINGGROUP' ).
    DATA(lr_runhour)  = buscar_range_filtro( 'RUNHOUR' ).

    APPEND VALUE #(
      companycode = VALUE #( lr_bukrs[ 1 ]-low OPTIONAL )
      netduedate  = VALUE #( lr_netdt[ 1 ]-low OPTIONAL )
      cashplanninggroup = VALUE #( lr_cashplanninggroup[ 1 ]-low OPTIONAL )
      runhourfrom = VALUE #( lr_runhour[ 1 ]-low OPTIONAL )
    ) TO rt_return .

*    DATA(lv_filter) = iv_filter.
*
*    lv_apost = TEXT-001.
*
*    TRANSLATE lv_filter USING '( ) '.
*    TRANSLATE lv_filter USING lv_apost.
*
*    IF lv_filter CS 'OR'.
*      SPLIT lv_filter AT 'OR' INTO TABLE DATA(lt_split_or).
*    ELSE.
*      SPLIT lv_filter AT 'AND' INTO TABLE lt_split_or.
*    ENDIF.

*    LOOP AT lt_split_or ASSIGNING FIELD-SYMBOL(<fs_split_or>).
*      CONDENSE <fs_split_or> NO-GAPS.
*      APPEND <fs_split_or> TO lt_filter.
*    ENDLOOP.

*    rt_return = CORRESPONDING #( lt_filter ).
    SORT rt_return BY companycode netduedate cashplanninggroup runhourfrom runhourto.

    TRY.
        DATA(lv_companycode) = rt_return[ 1 ]-companycode.
        DATA(lv_netduedate)  = rt_return[ 1 ]-netduedate.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    SELECT gup~laufd,
           gup~laufi,
           gup~xvorl,
           gup~zbukr,
           gup~zfbdt,
           guh~hbkid,
           guh~rzawe
      FROM regup AS gup
     INNER JOIN reguh AS guh
        ON guh~laufd = gup~laufd
       AND guh~laufi = gup~laufi
       AND guh~xvorl = gup~xvorl
       AND guh~zbukr = gup~zbukr
       AND guh~lifnr = gup~lifnr
       AND guh~kunnr = gup~kunnr
       AND guh~empfg = gup~empfg
       AND guh~vblnr = gup~vblnr
     WHERE gup~zbukr EQ @lv_companycode
       AND gup~laufd EQ @lv_netduedate
*        AND zfbdt EQ @lv_netduedate
      INTO TABLE @DATA(lt_regup).
    SORT lt_regup BY laufd laufi xvorl zbukr.

    IF lt_regup IS NOT INITIAL.
*      SELECT i_paymentproposalheader~payingcompanycode AS companycode,
*             CAST( i_paymentproposalheader~paymentrundate  AS DATS ) AS netduedate,
*             i_suppliercompany~cashplanninggroup AS cashplanninggroup,
*             regut~tstim AS runhour,
*             bsak~augbl AS paymentdocument
*        FROM regut
*        INNER JOIN i_paymentproposalheader
*          ON  i_paymentproposalheader~payingcompanycode EQ regut~zbukr
*          AND i_paymentproposalheader~paymentrundate EQ regut~laufd
*          AND i_paymentproposalheader~paymentrunid EQ regut~laufi
*          AND i_paymentproposalheader~paymentrunisproposal EQ regut~xvorl
*          AND i_paymentproposalheader~paymentorigin EQ regut~grpno
*        INNER JOIN i_suppliercompany
*          ON  i_suppliercompany~supplier    EQ i_paymentproposalheader~supplier
*          AND i_suppliercompany~companycode EQ i_paymentproposalheader~payingcompanycode
*        INNER JOIN bsak_view AS bsak
*          ON  bsak~bukrs EQ i_paymentproposalheader~payingcompanycode
*          AND bsak~belnr EQ i_paymentproposalheader~paymentdocument
*          AND bsak~gjahr EQ @lv_netduedate(4)
*        WHERE regut~zbukr EQ @lv_companycode
*          AND regut~laufd EQ @lv_netduedate
*          AND regut~lfdnr EQ 1
**        AND regut~dwdat IS INITIAL
*        ORDER BY companycode, netduedate, cashplanninggroup, runhour
*        INTO TABLE @DATA(lt_payment_sel).

      SELECT i_paymentproposalheader~payingcompanycode AS companycode,
             i_suppliercompany~cashplanninggroup AS cashplanninggroup,
             regut~tstim AS runhour,
             bsak~augbl AS paymentdocument,
             i_paymentproposalheader~paymentrundate AS laufd,
             i_paymentproposalheader~paymentrunid AS laufi,
             i_paymentproposalheader~paymentrunisproposal AS xvorl
        FROM regut
        INNER JOIN i_paymentproposalheader
          ON  i_paymentproposalheader~payingcompanycode EQ regut~zbukr
          AND i_paymentproposalheader~paymentrundate EQ regut~laufd
          AND i_paymentproposalheader~paymentrunid EQ regut~laufi
          AND i_paymentproposalheader~paymentrunisproposal EQ regut~xvorl
          AND i_paymentproposalheader~paymentorigin EQ regut~grpno
        INNER JOIN i_suppliercompany
          ON  i_suppliercompany~supplier    EQ i_paymentproposalheader~supplier
          AND i_suppliercompany~companycode EQ i_paymentproposalheader~payingcompanycode
        INNER JOIN bsik_view AS bsak
          ON  bsak~bukrs EQ i_paymentproposalheader~payingcompanycode
          AND bsak~belnr EQ i_paymentproposalheader~paymentdocument
          AND bsak~gjahr EQ @lv_netduedate(4)
        FOR ALL ENTRIES IN @lt_regup
        WHERE regut~zbukr EQ @lt_regup-zbukr
          AND regut~laufd EQ @lt_regup-laufd
          AND regut~laufi EQ @lt_regup-laufi
          AND regut~xvorl EQ @lt_regup-xvorl
          AND regut~lfdnr EQ 1
*        AND regut~dwdat IS INITIAL
        INTO CORRESPONDING FIELDS OF TABLE @lt_payment_sel.

      IF line_exists( rt_return[ cashplanninggroup = 'ZZ' ] ). "#EC CI_STDSEQ
        LOOP AT lt_payment_sel ASSIGNING FIELD-SYMBOL(<fs_payment_sel>).
          <fs_payment_sel>-cashplanninggroup = 'ZZ'.
        ENDLOOP.
      ENDIF.
      SORT lt_payment_sel BY companycode netduedate cashplanninggroup runhour.
    ENDIF.

    DATA lt_payment LIKE lt_payment_sel.
    LOOP AT lt_payment_sel ASSIGNING FIELD-SYMBOL(<fs_payment>).
      READ TABLE lt_regup INTO DATA(ls_regup)
        WITH KEY laufd = <fs_payment>-laufd
                 laufi = <fs_payment>-laufi
                 xvorl = <fs_payment>-xvorl
                 zbukr = <fs_payment>-companycode BINARY SEARCH.

      <fs_payment>-netduedate = ls_regup-laufd.
*      <fs_payment>-netduedate = ls_regup-zfbdt.

      READ TABLE rt_return INTO DATA(ls_return)
        WITH KEY companycode       = <fs_payment>-companycode
                 netduedate        = <fs_payment>-netduedate
                 cashplanninggroup = <fs_payment>-cashplanninggroup
*                 runhourfrom       = <fs_payment>-runhour BINARY SEARCH.
                  BINARY SEARCH.
      IF sy-subrc NE 0.
        IF sy-tabix LE 1.
          CONTINUE.
        ENDIF.

        DATA(lv_indice) = sy-tabix - 1.

        READ TABLE rt_return INTO ls_return INDEX lv_indice.
      ENDIF.

      IF  <fs_payment>-companycode        = ls_return-companycode
      AND <fs_payment>-netduedate         = ls_return-netduedate
      AND <fs_payment>-cashplanninggroup  = ls_return-cashplanninggroup.
*      AND <fs_payment>-runhour            BETWEEN ls_return-runhourfrom AND ls_return-runhourto.
        <fs_payment>-runhour = ls_return-runhourfrom.
      ELSE.
        CONTINUE.
      ENDIF.
      APPEND <fs_payment> TO lt_payment.
    ENDLOOP.

    SORT lt_payment BY companycode netduedate cashplanninggroup runhour.

    DATA(lt_parameters) = VALUE tihttpnvp( ).
    LOOP AT lt_payment ASSIGNING FIELD-SYMBOL(<fs_payment_key>)
      GROUP BY ( companycode       = <fs_payment_key>-companycode
                 netduedate        = <fs_payment_key>-netduedate
                 cachplanninggroup = <fs_payment_key>-cashplanninggroup )
*                 runhour           = <fs_payment_key>-runhour )
      ASSIGNING FIELD-SYMBOL(<fs_group_payment>).

      FREE lt_parameters.
      LOOP AT GROUP <fs_group_payment> ASSIGNING <fs_payment>.
        APPEND VALUE #( name = 'AccountingDocument'(004) value = <fs_payment>-paymentdocument ) TO lt_parameters.
      ENDLOOP.

      READ TABLE rt_return ASSIGNING FIELD-SYMBOL(<fs_return>)
        WITH KEY companycode       = <fs_group_payment>-companycode
                 netduedate        = <fs_group_payment>-netduedate
                 cashplanninggroup = <fs_group_payment>-cachplanninggroup
*                 runhourfrom       = <fs_group_payment>-runhour BINARY SEARCH.
                 BINARY SEARCH.
      CHECK sy-subrc EQ 0.

      APPEND VALUE #( name = 'CustomClearingStatus'(005) value = 'A' ) TO lt_parameters.
      APPEND VALUE #( name = 'KeyDate'(006) value = space ) TO lt_parameters.
      APPEND VALUE #( name = 'CompanyCode'(007) value = <fs_group_payment>-companycode ) TO lt_parameters.

      <fs_return>-paymentdocument = cl_lsapi_manager=>create_flp_url( object     = 'Supplier'(002)
                                                                      action     = 'manageLineItems'(003)
                                                                      parameters = lt_parameters ).

    ENDLOOP.



    SELECT  bsik~bukrs AS companycode,
            bseg~netdt AS netduedate,
            i_suppliercompany~cashplanninggroup,
            bsik~belnr AS document,
            bsik~gjahr AS year,
            bsik~buzei AS item,
            bsik~zlspr AS blocked
      FROM bsik_view AS bsik
      INNER JOIN bseg
        ON  bseg~bukrs EQ bsik~bukrs
        AND bseg~belnr EQ bsik~belnr
        AND bseg~gjahr EQ bsik~gjahr
        AND bseg~buzei EQ bsik~buzei
      INNER JOIN i_suppliercompany
        ON  i_suppliercompany~supplier    EQ bsik~lifnr
        AND i_suppliercompany~companycode EQ bsik~bukrs
      WHERE bsik~bukrs EQ @lv_companycode
        AND bsik~bschl IN ('31','39')
        AND bsik~shkzg EQ 'H'
        AND bsik~umskz NE 'F'
        AND bseg~netdt EQ @lv_netduedate
      ORDER BY companycode, netduedate, cashplanninggroup, blocked
      INTO TABLE @DATA(lt_bsik).

    IF line_exists( rt_return[ cashplanninggroup = 'ZZ' ] ). "#EC CI_STDSEQ
      LOOP AT lt_bsik ASSIGNING FIELD-SYMBOL(<fs_bsik_aux>).
        <fs_bsik_aux>-cashplanninggroup = 'ZZ'.
      ENDLOOP.
    ENDIF.
    SORT lt_bsik BY companycode netduedate cashplanninggroup blocked.

    DATA(lt_parameters_open) = VALUE tihttpnvp( ).
    DATA(lt_parameters_blocked) = VALUE tihttpnvp( ).
    LOOP AT lt_bsik ASSIGNING FIELD-SYMBOL(<fs_bsik_key>)
      GROUP BY ( companycode       = <fs_bsik_key>-companycode
                 netduedate        = <fs_bsik_key>-netduedate
                 cashplanninggroup = <fs_bsik_key>-cashplanninggroup )
      ASSIGNING FIELD-SYMBOL(<fs_group_bsik>).

      FREE: lt_parameters_open,
            lt_parameters_blocked.
      LOOP AT GROUP <fs_group_bsik> ASSIGNING FIELD-SYMBOL(<fs_bsik>).
        IF <fs_bsik>-blocked IS INITIAL.
          APPEND VALUE #( name = 'AccountingDocument'(004) value = <fs_bsik>-document ) TO lt_parameters_open.
        ELSE.
          APPEND VALUE #( name = 'AccountingDocument'(004) value = <fs_bsik>-document ) TO lt_parameters_blocked.
        ENDIF.
      ENDLOOP.

      IF lt_parameters_open IS NOT INITIAL.
        APPEND VALUE #( name = 'CustomClearingStatus'(005) value = 'A' ) TO lt_parameters_open.
        APPEND VALUE #( name = 'KeyDate'(006) value = space ) TO lt_parameters_open.
        APPEND VALUE #( name = 'CompanyCode'(007) value = <fs_group_bsik>-companycode ) TO lt_parameters_open.
      ENDIF.

      IF lt_parameters_blocked IS NOT INITIAL.
        APPEND VALUE #( name = 'CustomClearingStatus'(005) value = 'A' ) TO lt_parameters_blocked.
        APPEND VALUE #( name = 'KeyDate'(006) value = space ) TO lt_parameters_blocked.
        APPEND VALUE #( name = 'CompanyCode'(007) value = <fs_group_bsik>-companycode ) TO lt_parameters_blocked.
      ENDIF.

      APPEND VALUE #( companycode       = <fs_group_bsik>-companycode
                      netduedate        = <fs_group_bsik>-netduedate
                      cashplanninggroup = <fs_group_bsik>-cashplanninggroup

                      opendocument      = COND #( WHEN lines( lt_parameters_open ) = 0 THEN space
                                                  ELSE cl_lsapi_manager=>create_flp_url( object     = 'Supplier'(002)
                                                                                         action     = 'manageLineItems'(003)
                                                                                         parameters = lt_parameters_open ) )

                      blockeddocument   = COND #( WHEN lines( lt_parameters_blocked ) = 0 THEN space
                                                  ELSE cl_lsapi_manager=>create_flp_url( object     = 'Supplier'(002)
                                                                                         action     = 'manageLineItems'(003)
                                                                                         parameters = lt_parameters_blocked ) )
                      ) TO lt_url.
    ENDLOOP.

    SORT lt_url BY companycode netduedate cashplanninggroup.

    LOOP AT rt_return ASSIGNING <fs_return>.
      READ TABLE lt_url INTO DATA(ls_url)
        WITH KEY companycode       = <fs_return>-companycode
                 netduedate        = <fs_return>-netduedate
                 cashplanninggroup = <fs_return>-cashplanninggroup BINARY SEARCH.
      CHECK sy-subrc EQ 0.
      <fs_return>-opendocument    = ls_url-opendocument.
      <fs_return>-blockeddocument = ls_url-blockeddocument.
    ENDLOOP.


  ENDMETHOD.


  METHOD approve.

    DATA: lv_download TYPE boolean.

    LOOP AT ct_entity ASSIGNING FIELD-SYMBOL(<fs_entity>).


      DATA(ls_table) = VALUE ztfi_log_apv_pgt( bukrs   = <fs_entity>-companycode
                                               fdgrv   = <fs_entity>-cashplanninggroup
                                               data    = <fs_entity>-netduedate
*                                             hora    = rs_return-runhourto
                                               tiporel = <fs_entity>-reptype
                                               valor   = <fs_entity>-paidamountinpaytcurrency
                                               hbkid   = <fs_entity>-hbkid ).

      SELECT SINGLE *
        FROM ztfi_log_apv_pgt
       WHERE bukrs   = @ls_table-bukrs
         AND fdgrv   = @ls_table-fdgrv
         AND data    = @ls_table-data
*       AND hora    = @ls_table-hora
         AND tiporel = @ls_table-tiporel
        INTO @ls_table.                            "#EC CI_SROFC_NESTED

      IF sy-subrc EQ 0.
        ls_table-hbkid = <fs_entity>-hbkid.
      ENDIF.

      SELECT SINGLE paidamountinpaytcurrency
        FROM zi_fi_aprov_temse
       WHERE companycode       = @ls_table-bukrs
         AND netduedate        = @ls_table-data
         AND cashplanninggroup = @ls_table-fdgrv
         AND reptype           = @ls_table-tiporel
        INTO @DATA(lv_val).

      IF sy-subrc IS INITIAL.
        ls_table-valor = lv_val.
      ENDIF.

      ls_table-nao_pago = COND #( WHEN <fs_entity>-paidamountinpaytcurrency = 0
                                    THEN abap_true
                                    ELSE abap_false
                                ).

      CASE abap_false.
        WHEN <fs_entity>-encerrador.
          ls_table-encerrador = abap_true.
          ls_table-enc_user   = sy-uname.
          ls_table-enc_data   = sy-datum.
          ls_table-enc_hora   = sy-uzeit.
*        et_message = VALUE #( BASE et_message ( id = gc_mg_id number = gc_msg_no-m_001 type = CONV #( if_abap_behv_message=>severity-success ) message_v1 = 1 message_v2 = sy-uname ) ).
        WHEN <fs_entity>-aprov1.
          ls_table-aprov1   = abap_true.
          ls_table-ap1_user = sy-uname.
          ls_table-ap1_data = sy-datum.
          ls_table-ap1_hora = sy-uzeit.
*        et_message = VALUE #( BASE et_message ( id = gc_mg_id number = gc_msg_no-m_001 type = CONV #( if_abap_behv_message=>severity-success ) message_v1 = 2 message_v2 = sy-uname ) ).
        WHEN <fs_entity>-aprov2.
          ls_table-aprov2   = abap_true.
          ls_table-ap2_user = sy-uname.
          ls_table-ap2_data = sy-datum.
          ls_table-ap2_hora = sy-uzeit.
*        et_message = VALUE #( BASE et_message ( id = gc_mg_id number = gc_msg_no-m_001 type = CONV #( if_abap_behv_message=>severity-success ) message_v1 = 3 message_v2 = sy-uname ) ).
        WHEN <fs_entity>-aprov3.
          ls_table-aprov3   = abap_true.
          ls_table-ap3_user = sy-uname.
          ls_table-ap3_data = sy-datum.
          ls_table-ap3_hora = sy-uzeit.
*        et_message = VALUE #( BASE et_message ( id = gc_mg_id number = gc_msg_no-m_001 type = CONV #( if_abap_behv_message=>severity-success ) message_v1 = 4 message_v2 = sy-uname ) ).

          lv_download = abap_true.
*        IF is_entity-rzawe NA 'RCNVXP'.

*        ENDIF.

      ENDCASE.

*    ls_table-valor = rs_return-paidamountinpaytcurrency.
*    ls_table-valor = rs_return-OpenAmount.
      MODIFY ztfi_log_apv_pgt FROM ls_table.        "#EC CI_IMUD_NESTED
      IF sy-subrc EQ 0.
        <fs_entity>-encerrador = ls_table-encerrador.
        <fs_entity>-encerradorcrit = COND #( WHEN <fs_entity>-encerrador = abap_true THEN 3        ELSE 0 ).
        <fs_entity>-encerradortext = COND #( WHEN <fs_entity>-encerrador = abap_true THEN TEXT-apv ELSE TEXT-pdt ).

        <fs_entity>-aprov1     = ls_table-aprov1.
        <fs_entity>-aprov1crit = COND #( WHEN <fs_entity>-aprov1 = abap_true THEN 3        ELSE 0 ).
        <fs_entity>-aprov1text = COND #( WHEN <fs_entity>-aprov1 = abap_true THEN TEXT-apv ELSE TEXT-pdt ).

        <fs_entity>-aprov2     = ls_table-aprov2.
        <fs_entity>-aprov2crit = COND #( WHEN <fs_entity>-aprov2 = abap_true THEN 3        ELSE 0 ).
        <fs_entity>-aprov2text = COND #( WHEN <fs_entity>-aprov2 = abap_true THEN TEXT-apv ELSE TEXT-pdt ).

        <fs_entity>-aprov3     = ls_table-aprov3.
        <fs_entity>-aprov3crit = COND #( WHEN <fs_entity>-aprov3 = abap_true THEN 3        ELSE 0 ).
        <fs_entity>-aprov3text = COND #( WHEN <fs_entity>-aprov3 = abap_true THEN TEXT-apv ELSE TEXT-pdt ).
      ENDIF.


    ENDLOOP.

    IF lv_download = abap_true.
      download_file( ct_entity ).
    ENDIF.

*    rs_return = is_entity.
*
*    DATA(ls_table) = VALUE ztfi_log_apv_pgt( bukrs   = rs_return-companycode
*                                             fdgrv   = rs_return-cashplanninggroup
*                                             data    = rs_return-netduedate
**                                             hora    = rs_return-runhourto
*                                             tiporel = rs_return-reptype
*                                             valor   = rs_return-paidamountinpaytcurrency
*                                             hbkid   = rs_return-hbkid ).
*
*    SELECT SINGLE *
*      FROM ztfi_log_apv_pgt
*     WHERE bukrs   = @ls_table-bukrs
*       AND fdgrv   = @ls_table-fdgrv
*       AND data    = @ls_table-data
**       AND hora    = @ls_table-hora
*       AND tiporel = @ls_table-tiporel
*      INTO @ls_table.                              "#EC CI_SROFC_NESTED
*
*    IF sy-subrc EQ 0.
*      ls_table-hbkid = rs_return-hbkid.
*    ENDIF.
*
*    SELECT SINGLE paidamountinpaytcurrency
*      FROM zi_fi_aprov_temse
*     WHERE companycode       = @ls_table-bukrs
*       AND netduedate        = @ls_table-data
*       AND cashplanninggroup = @ls_table-fdgrv
*       AND reptype           = @ls_table-tiporel
*      INTO @DATA(lv_val).
*
*    IF sy-subrc IS INITIAL.
*      ls_table-valor = lv_val.
*    ENDIF.
*
*    ls_table-nao_pago = COND #( WHEN rs_return-paidamountinpaytcurrency = 0
*                                  THEN abap_true
*                                  ELSE abap_false
*                              ).
*
*    CASE abap_false.
*      WHEN rs_return-encerrador.
*        ls_table-encerrador = abap_true.
*        ls_table-enc_user   = sy-uname.
*        ls_table-enc_data   = sy-datum.
*        ls_table-enc_hora   = sy-uzeit.
**        et_message = VALUE #( BASE et_message ( id = gc_mg_id number = gc_msg_no-m_001 type = CONV #( if_abap_behv_message=>severity-success ) message_v1 = 1 message_v2 = sy-uname ) ).
*      WHEN rs_return-aprov1.
*        ls_table-aprov1   = abap_true.
*        ls_table-ap1_user = sy-uname.
*        ls_table-ap1_data = sy-datum.
*        ls_table-ap1_hora = sy-uzeit.
**        et_message = VALUE #( BASE et_message ( id = gc_mg_id number = gc_msg_no-m_001 type = CONV #( if_abap_behv_message=>severity-success ) message_v1 = 2 message_v2 = sy-uname ) ).
*      WHEN rs_return-aprov2.
*        ls_table-aprov2   = abap_true.
*        ls_table-ap2_user = sy-uname.
*        ls_table-ap2_data = sy-datum.
*        ls_table-ap2_hora = sy-uzeit.
**        et_message = VALUE #( BASE et_message ( id = gc_mg_id number = gc_msg_no-m_001 type = CONV #( if_abap_behv_message=>severity-success ) message_v1 = 3 message_v2 = sy-uname ) ).
*      WHEN rs_return-aprov3.
*        ls_table-aprov3   = abap_true.
*        ls_table-ap3_user = sy-uname.
*        ls_table-ap3_data = sy-datum.
*        ls_table-ap3_hora = sy-uzeit.
**        et_message = VALUE #( BASE et_message ( id = gc_mg_id number = gc_msg_no-m_001 type = CONV #( if_abap_behv_message=>severity-success ) message_v1 = 4 message_v2 = sy-uname ) ).
*
**        IF is_entity-rzawe NA 'RCNVXP'.
*        download_file( is_entity ).
**        ENDIF.
*
*    ENDCASE.
*
**    ls_table-valor = rs_return-paidamountinpaytcurrency.
**    ls_table-valor = rs_return-OpenAmount.
*    MODIFY ztfi_log_apv_pgt FROM ls_table.          "#EC CI_IMUD_NESTED
*    IF sy-subrc EQ 0.
*      rs_return-encerrador = ls_table-encerrador.
*      rs_return-encerradorcrit = COND #( WHEN rs_return-encerrador = abap_true THEN 3        ELSE 0 ).
*      rs_return-encerradortext = COND #( WHEN rs_return-encerrador = abap_true THEN TEXT-apv ELSE TEXT-pdt ).
*
*      rs_return-aprov1     = ls_table-aprov1.
*      rs_return-aprov1crit = COND #( WHEN rs_return-aprov1 = abap_true THEN 3        ELSE 0 ).
*      rs_return-aprov1text = COND #( WHEN rs_return-aprov1 = abap_true THEN TEXT-apv ELSE TEXT-pdt ).
*
*      rs_return-aprov2     = ls_table-aprov2.
*      rs_return-aprov2crit = COND #( WHEN rs_return-aprov2 = abap_true THEN 3        ELSE 0 ).
*      rs_return-aprov2text = COND #( WHEN rs_return-aprov2 = abap_true THEN TEXT-apv ELSE TEXT-pdt ).
*
*      rs_return-aprov3     = ls_table-aprov3.
*      rs_return-aprov3crit = COND #( WHEN rs_return-aprov3 = abap_true THEN 3        ELSE 0 ).
*      rs_return-aprov3text = COND #( WHEN rs_return-aprov3 = abap_true THEN TEXT-apv ELSE TEXT-pdt ).
*    ENDIF.

  ENDMETHOD.


  METHOD get_features.
    SELECT COUNT( * )
      FROM ztfi_apvdrs_pgto
      UP TO 1 ROWS
      WHERE bukrs EQ @iv_bukrs
        AND uname EQ @sy-uname
        AND endda GE @sy-datum
        AND begda LE @sy-datum
        AND nivel EQ @iv_nivel.
    IF sy-subrc EQ 0.
      rv_return = if_abap_behv=>fc-o-enabled.
    ELSE.
      rv_return = if_abap_behv=>fc-o-disabled.
    ENDIF.

  ENDMETHOD.


  METHOD download_file.

    DATA lr_zlcsh TYPE RANGE OF regup-zlsch.

    SELECT DISTINCT companycode, netduedate, paymentrunid
      FROM zi_fi_prog_pagamento_p
      FOR ALL ENTRIES IN @it_entity
      WHERE companycode     = @it_entity-companycode
      AND netduedate        = @it_entity-netduedate
      AND cashplanninggroup = @it_entity-cashplanninggroup
      AND reptype           = @it_entity-reptype
      INTO TABLE @DATA(lt_paymentrunid).
    IF sy-subrc = 0.
      SELECT * FROM regut
        FOR ALL ENTRIES IN @lt_paymentrunid
        WHERE zbukr = @lt_paymentrunid-companycode
         AND laufd  = @lt_paymentrunid-netduedate
         AND laufi  = @lt_paymentrunid-paymentrunid
         AND status <> '010'
         INTO TABLE @DATA(lt_regut).
      IF sy-subrc = 0.
        SELECT DISTINCT zbukr,laufd, laufi,xvorl, zlsch
          FROM regup
          FOR ALL ENTRIES IN @lt_regut
          WHERE zbukr = @lt_regut-zbukr
            AND laufd = @lt_regut-laufd
            AND laufi = @lt_regut-laufi
            AND xvorl = @lt_regut-xvorl
          INTO TABLE @DATA(lt_regup).

        IF sy-subrc IS INITIAL.
          SORT lt_regup BY zbukr
                           laufd
                           laufi
                           xvorl.
        ENDIF.

      ENDIF.
    ENDIF.

    TRY.
        NEW  zclca_tabela_parametros( )->m_get_range(
          EXPORTING
            iv_modulo = 'FI-AP'
            iv_chave1 = 'NAOARQUIVO'
            iv_chave2 = 'FORMAPGTO'
          IMPORTING
            et_range  = lr_zlcsh
        ).
      CATCH zcxca_tabela_parametros INTO DATA(lo_erro).
*        rs_message-message = lo_erro->get_text( ).
    ENDTRY.


    DATA lt_regut_aux TYPE epic_t_regut.
    LOOP AT lt_regut ASSIGNING FIELD-SYMBOL(<fs_regut>).
      READ TABLE lt_regup ASSIGNING FIELD-SYMBOL(<fs_regup>)
                                        WITH KEY zbukr = <fs_regut>-zbukr
                                                 laufd = <fs_regut>-laufd
                                                 laufi = <fs_regut>-laufi
                                                 xvorl = <fs_regut>-xvorl
                                                 BINARY SEARCH.
      IF sy-subrc = 0 AND <fs_regup>-zlsch NOT IN lr_zlcsh .
        APPEND <fs_regut> TO lt_regut_aux.
      ENDIF.
    ENDLOOP.

    SORT: lt_regut_aux BY zbukr
                          banks
                          laufd
                          laufi
                          xvorl
                          dtkey
                          lfdnr.

    DELETE ADJACENT DUPLICATES FROM lt_regut_aux COMPARING zbukr
                          banks
                          laufd
                          laufi
                          xvorl
                          dtkey
                          lfdnr.

    IF lt_regut_aux IS NOT INITIAL.
      CALL FUNCTION 'ZFMFI_DOWNLOAD_FILE_FDTA'
        STARTING NEW TASK 'BACKGROUND'
        EXPORTING
          it_regut = lt_regut_aux.
    ENDIF.

** DATA lr_zlcsh TYPE RANGE OF regup-zlsch.
**
**    SELECT DISTINCT companycode, netduedate, paymentrunid
**      FROM zi_fi_prog_pagamento_p
**      FOR ALL ENTRIES IN @ct_entity
**      WHERE companycode     = @is_entity-companycode
**      AND netduedate        = @is_entity-netduedate
**      AND cashplanninggroup = @is_entity-cashplanninggroup
**      AND reptype           = @is_entity-reptype
**      INTO TABLE @DATA(lt_paymentrunid).
**    IF sy-subrc = 0.
**      SELECT * FROM regut
**        FOR ALL ENTRIES IN @lt_paymentrunid
**        WHERE zbukr = @lt_paymentrunid-companycode
**         AND laufd  = @lt_paymentrunid-netduedate
**         AND laufi  = @lt_paymentrunid-paymentrunid
**         AND status <> '010'
**         INTO TABLE @DATA(lt_regut).
**      IF sy-subrc = 0.
**        SELECT DISTINCT zbukr,laufd, laufi,xvorl, zlsch
**          FROM regup
**          FOR ALL ENTRIES IN @lt_regut
**          WHERE zbukr = @lt_regut-zbukr
**            AND laufd = @lt_regut-laufd
**            AND laufi = @lt_regut-laufi
**            AND xvorl = @lt_regut-xvorl
**          INTO TABLE @DATA(lt_regup).
**
**        IF sy-subrc IS INITIAL.
**          SORT lt_regup BY zbukr
**                           laufd
**                           laufi
**                           xvorl.
**        ENDIF.
**
**      ENDIF.
**    ENDIF.
**
**    TRY.
**        NEW  zclca_tabela_parametros( )->m_get_range(
**          EXPORTING
**            iv_modulo = 'FI-AP'
**            iv_chave1 = 'NAOARQUIVO'
**            iv_chave2 = 'FORMAPGTO'
**          IMPORTING
**            et_range  = lr_zlcsh
**        ).
**      CATCH zcxca_tabela_parametros INTO DATA(lo_erro).
**        rs_message-message = lo_erro->get_text( ).
**    ENDTRY.
**
**
**    DATA lt_regut_aux TYPE epic_t_regut.
**    LOOP AT lt_regut ASSIGNING FIELD-SYMBOL(<fs_regut>).
**      READ TABLE lt_regup ASSIGNING FIELD-SYMBOL(<fs_regup>)
**                                        WITH KEY zbukr = <fs_regut>-zbukr
**                                                 laufd = <fs_regut>-laufd
**                                                 laufi = <fs_regut>-laufi
**                                                 xvorl = <fs_regut>-xvorl
**                                                 BINARY SEARCH.
**      IF sy-subrc = 0 AND <fs_regup>-zlsch NOT IN lr_zlcsh .
**        APPEND <fs_regut> TO lt_regut_aux.
**      ENDIF.
**    ENDLOOP.
**
**    IF lt_regut_aux IS NOT INITIAL.
**      WAIT UP TO 1 SECONDS.
**      CALL FUNCTION 'ZFMFI_DOWNLOAD_FILE_FDTA'
**        STARTING NEW TASK 'BACKGROUND'
**        EXPORTING
**          it_regut = lt_regut_aux.
**    ENDIF.
  ENDMETHOD.


  METHOD get_contas_pagar_2.

    DATA: lt_itens TYPE TABLE OF zc_fi_prog_pag_doc_itens.

    gt_filtro_ranges = CORRESPONDING #( it_filtro_ranges ).

    DATA(lr_bukrs)    = buscar_range_filtro( 'COMPANYCODE' ).
    DATA(lr_netdt)    = buscar_range_filtro( 'NETDUEDATE' ).
    DATA(lr_tiporel)  = buscar_range_filtro( 'REPTYPE' ).
    DATA(lr_fdgrv)    = buscar_range_filtro( 'CASHPLANNINGGROUP' ).
    DATA(lr_nethr)    = buscar_range_filtro( 'RUNHOURTO' ).

    TRY.
        gv_reptype          = lr_tiporel[ 1 ]-low.
        DATA(lv_netduedate) = lr_netdt[ 1 ]-low.
        DATA(lv_bukrs)      = lr_bukrs[ 1 ]-low.
      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    DELETE lr_nethr WHERE low = '000000'.

    CHECK zclfi_auth_zfibukrs=>check_custom( EXPORTING iv_bukrs = CONV #( lv_bukrs ) iv_actvt = zclfi_auth_zfibukrs=>gc_actvt-exibir ).

    SELECT SINGLE text
      FROM zi_fi_vh_tiporel AS reptypetext
     WHERE value = @gv_reptype
      INTO @DATA(lv_reptypetext).

*    me->get_aprovadores( EXPORTING ir_bukrs = lr_bukrs ir_netdt = lr_netdt ).

    SELECT DISTINCT
           zi_fi_prog_pagamento_p~companycode,
           zi_fi_prog_pagamento_p~paymentrunid,
           zi_fi_prog_pagamento_p~netduedate,
           zi_fi_prog_pagamento_p~runhourto,
           zi_fi_prog_pagamento_p~cashplanninggroup,
           zi_fi_prog_pagamento_p~supplier,
           zi_fi_prog_pagamento_p~paidamountinpaytcurrency,
           zi_fi_prog_pagamento_p~paymentcurrency,
           zi_fi_prog_pagamento_p~reptype,
*          zi_fi_prog_pagamento_p~OpenAmount,
*          zi_fi_prog_pagamento_p~BlockedAmount,
           zi_fi_prog_pagamento_p~encerrador,
           zi_fi_prog_pagamento_p~encerradorcrit,
           zi_fi_prog_pagamento_p~encerradortext,
           zi_fi_prog_pagamento_p~aprov1,
           zi_fi_prog_pagamento_p~aprov1crit,
           zi_fi_prog_pagamento_p~aprov1text,
           zi_fi_prog_pagamento_p~aprov2,
           zi_fi_prog_pagamento_p~aprov2crit,
           zi_fi_prog_pagamento_p~aprov2text,
           zi_fi_prog_pagamento_p~aprov3,
           zi_fi_prog_pagamento_p~aprov3crit,
           zi_fi_prog_pagamento_p~aprov3text,
           zi_fi_prog_pagamento_p~nivelatual,
           regup~hbkid,
           regup~zlsch AS rzawe,
           regut~tsdat,
           ' ' AS username
      FROM zi_fi_prog_pagamento_p
*     INNER JOIN regut
     LEFT OUTER JOIN regut
        ON companycode  = regut~zbukr
       AND netduedate   = regut~laufd
       AND paymentrunid = regut~laufi
       AND regut~xvorl  = @abap_false
*     INNER JOIN regup
     LEFT OUTER JOIN regup
        ON regup~zbukr = regut~zbukr
       AND regup~laufd = regut~laufd
       AND regup~laufi = regut~laufi
       AND regup~xvorl = regut~xvorl
     WHERE companycode       IN @lr_bukrs
       AND netduedate        IN @lr_netdt
       AND runhourto         IN @lr_nethr
       AND cashplanninggroup IN @lr_fdgrv
       AND reptype           IN @lr_tiporel
*       AND paidamountinpaytcurrency <> 0
      INTO TABLE @DATA(lt_return2).

    CHECK sy-subrc EQ 0.

    DATA(lt_return_aux) = lt_return2[].

    SORT lt_return_aux BY companycode
                          netduedate
                          cashplanninggroup.

    DELETE ADJACENT DUPLICATES FROM lt_return_aux COMPARING companycode
                                                            netduedate
                                                            cashplanninggroup.

    LOOP AT lt_return_aux ASSIGNING FIELD-SYMBOL(<fs_return2>).

      APPEND INITIAL LINE TO rt_return ASSIGNING FIELD-SYMBOL(<fs_return>).
      MOVE-CORRESPONDING <fs_return2> TO <fs_return>.

      <fs_return>-username = sy-uname.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_aprovadores.

    SELECT DISTINCT
           log~bukrs,
           fdgrv,
           uname,
           nivel,
           data,
           hora,
           tiporel,
           encerrador,
           CASE WHEN encerrador = 'X' THEN '3'
                ELSE '0' END AS encerradorcrit,
           CASE WHEN encerrador = 'X' THEN 'Aprovado'
                ELSE 'Pendente' END AS encerradortext,
           aprov1,
           CASE WHEN aprov1 = 'X' THEN '3'
                ELSE '0' END AS aprov1crit,
           CASE WHEN aprov1 = 'X' THEN 'Aprovado'
                ELSE 'Pendente' END AS aprov1text,
           aprov2,
           CASE WHEN aprov2 = 'X' THEN '3'
                ELSE '0' END AS aprov2crit,
           CASE WHEN aprov2 = 'X' THEN 'Aprovado'
                ELSE 'Pendente' END AS aprov2text,
           aprov3,
           CASE WHEN aprov3 = 'X' THEN '3'
                ELSE '0' END AS aprov3crit,
           CASE WHEN aprov3 = 'X' THEN 'Aprovado'
                ELSE 'Pendente' END AS aprov3text
      FROM ztfi_log_apv_pgt AS log
      LEFT OUTER JOIN ztfi_apvdrs_pgto AS pgto
        ON log~bukrs = pgto~bukrs
      INTO CORRESPONDING FIELDS OF TABLE @gt_approver
     WHERE log~bukrs  IN @ir_bukrs
       AND log~data   IN @ir_netdt
       AND pgto~endda GE @sy-datum
       AND pgto~begda LE @sy-datum
*       AND tiporel    EQ @gv_reptype
     ORDER BY log~bukrs, data, hora, nivel, uname.

*    CLEAR ls_authorization.
*    LOOP AT lt_approver ASSIGNING FIELD-SYMBOL(<fs_approver>).
*      CASE <fs_approver>-nivel.
*        WHEN '0'. " Encerrador
*          ls_authorization-is_enc = abap_true.
*        WHEN '1'. " Aprovador 1
*          ls_authorization-is_ap1 = abap_true.
*        WHEN '2'. " Aprovador 2
*          ls_authorization-is_ap2 = abap_true.
*        WHEN '3'. " Aprovador 3
*          ls_authorization-is_ap3 = abap_true.
*      ENDCASE.
*    ENDLOOP.

  ENDMETHOD.


  METHOD get_pagamentos.

    IF it_regup IS NOT INITIAL.
      IF iv_filtro_aprov IS INITIAL.

        "Busca todos os pagamentos
        SELECT i_paymentproposalheader~payingcompanycode AS companycode,
               i_suppliercompany~cashplanninggroup,
               i_planninggrouptext~cashplanninggroupname,
               i_companycode~companycodename,
               regut~rbetr AS paidamountinpaytcurrency,
               regut~waers AS paymentcurrency,
               regut~tstim AS runhour,
               i_paymentproposalheader~paymentrundate AS laufd,
               i_paymentproposalheader~paymentrunid AS laufi,
               i_paymentproposalheader~paymentrunisproposal AS xvorl
          FROM regut
          INNER JOIN i_paymentproposalheader
            ON  i_paymentproposalheader~payingcompanycode EQ regut~zbukr
            AND i_paymentproposalheader~paymentrundate EQ regut~laufd
            AND i_paymentproposalheader~paymentrunid EQ regut~laufi
            AND i_paymentproposalheader~paymentrunisproposal EQ regut~xvorl
            AND i_paymentproposalheader~paymentorigin EQ regut~grpno
          INNER JOIN i_companycode
            ON  i_companycode~companycode EQ i_paymentproposalheader~payingcompanycode
          INNER JOIN i_suppliercompany
            ON  i_suppliercompany~supplier    EQ i_paymentproposalheader~supplier
            AND i_suppliercompany~companycode EQ i_paymentproposalheader~payingcompanycode
          LEFT OUTER JOIN i_planninggrouptext
            ON  i_planninggrouptext~cashplanninggroup EQ i_suppliercompany~cashplanninggroup
            AND i_planninggrouptext~language EQ @sy-langu
          FOR ALL ENTRIES IN @it_regup
          WHERE regut~zbukr EQ @it_regup-zbukr
            AND regut~laufd EQ @it_regup-laufd
            AND regut~laufi EQ @it_regup-laufi
            AND regut~xvorl EQ @it_regup-xvorl
            AND regut~lfdnr EQ 1
          INTO CORRESPONDING FIELDS OF TABLE @et_bsak.

      ELSE.

        "Busca somente os pagamentos que ainda não estão aprovados
        SELECT i_paymentproposalheader~payingcompanycode AS companycode,
               i_suppliercompany~cashplanninggroup,
               i_planninggrouptext~cashplanninggroupname,
               i_companycode~companycodename,
               regut~rbetr AS paidamountinpaytcurrency,
               regut~waers AS paymentcurrency,
               regut~tstim AS runhour,
               i_paymentproposalheader~paymentrundate AS laufd,
               i_paymentproposalheader~paymentrunid AS laufi,
               i_paymentproposalheader~paymentrunisproposal AS xvorl
          FROM regut
          INNER JOIN i_paymentproposalheader
            ON  i_paymentproposalheader~payingcompanycode EQ regut~zbukr
            AND i_paymentproposalheader~paymentrundate EQ regut~laufd
            AND i_paymentproposalheader~paymentrunid EQ regut~laufi
            AND i_paymentproposalheader~paymentrunisproposal EQ regut~xvorl
            AND i_paymentproposalheader~paymentorigin EQ regut~grpno
          INNER JOIN i_companycode
            ON  i_companycode~companycode EQ i_paymentproposalheader~payingcompanycode
          INNER JOIN i_suppliercompany
            ON  i_suppliercompany~supplier    EQ i_paymentproposalheader~supplier
            AND i_suppliercompany~companycode EQ i_paymentproposalheader~payingcompanycode
          LEFT OUTER JOIN i_planninggrouptext
            ON  i_planninggrouptext~cashplanninggroup EQ i_suppliercompany~cashplanninggroup
            AND i_planninggrouptext~language EQ @sy-langu
          FOR ALL ENTRIES IN @it_regup
          WHERE regut~zbukr EQ @it_regup-zbukr
            AND regut~laufd EQ @it_regup-laufd
            AND regut~laufi EQ @it_regup-laufi
            AND regut~xvorl EQ @it_regup-xvorl
            AND regut~lfdnr EQ 1
*          AND regut~dwdat IS INITIAL
          INTO CORRESPONDING FIELDS OF TABLE @et_bsak.

      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_fdgrv.

    CLEAR gv_endfunction.

    CALL FUNCTION 'ZFMFI_GRUPO_TESOURARIA'
      STARTING NEW TASK 'GRUPOTESO' CALLING task_finish_grupoteso ON END OF TASK
      EXPORTING
        it_doc_fdgrv = it_doc_fdgrv.

    WAIT FOR ASYNCHRONOUS TASKS UNTIL gv_endfunction IS NOT INITIAL.

  ENDMETHOD.


  METHOD task_finish_grupoteso.

    gv_endfunction = abap_true.
    RETURN.

  ENDMETHOD.


  METHOD get_doc_pgto2.

    DATA(lt_paid) = VALUE tihttpnvp( ).
    DATA(lt_open) = VALUE tihttpnvp( ).
    DATA(lt_bloq) = VALUE tihttpnvp( ).
*    DATA lt_docs TYPE ty_t_docs.
    DATA lt_docs TYPE TABLE OF zc_fi_prog_pag_doc_itens.

    gt_filtro_ranges  = CORRESPONDING #( it_filtro_ranges ).

    DATA(lr_bukrs)             = buscar_range_filtro( 'COMPANYCODE' ).
    DATA(lr_netdt)             = buscar_range_filtro( 'NETDUEDATE' ).
    DATA(lr_cashplanninggroup) = buscar_range_filtro( 'CASHPLANNINGGROUP' ).
    DATA(lr_tipo)              = buscar_range_filtro( 'TIPO' ).
    DATA(lr_hbkid)             = buscar_range_filtro( 'HBKID' ).
    DATA(lr_rzawe)             = buscar_range_filtro( 'RZAWE' ).
    DATA(lr_reptype)           = buscar_range_filtro( 'REPTYPE' ).
    DATA(lr_paymentrunid)      = buscar_range_filtro( 'PAYMENTRUNID' ).

    LOOP AT lr_paymentrunid ASSIGNING FIELD-SYMBOL(<fs_paymentrunid>).
      IF <fs_paymentrunid>-low IS INITIAL.
        DELETE lr_paymentrunid FROM sy-tabix.
        CONTINUE.
      ENDIF.
    ENDLOOP.

    TRY.

        DATA(lv_tipo) = lr_tipo[ 1 ]-low.

      CATCH cx_root.
        lv_tipo = 0.
    ENDTRY.

**    CASE lv_tipo.
**      WHEN '1'.
**        SELECT DISTINCT
**               zc_fi_pgto_grp_tesouraria~companycode,
**               zc_fi_pgto_grp_tesouraria~netduedate,
**               zc_fi_pgto_grp_tesouraria~cashplanninggroup,
**               bsak~augbl AS paymentdocument,
**               bsak~belnr AS document,
**               bsak~dmbtr,
**               'P' AS tipo,
**               bsak~bstat,
**               bsak~gjahr
**          FROM zc_fi_pgto_grp_tesouraria
**         INNER JOIN zc_fi_prog_pag_doc_itens
**            ON zc_fi_pgto_grp_tesouraria~companycode       = zc_fi_prog_pag_doc_itens~companycode
**           AND zc_fi_pgto_grp_tesouraria~cashplanninggroup = zc_fi_prog_pag_doc_itens~cashplanninggroup
**           AND zc_fi_pgto_grp_tesouraria~netduedate        = zc_fi_prog_pag_doc_itens~netduedate
**         INNER JOIN bsak_view AS bsak
**            ON bsak~bukrs                EQ zc_fi_prog_pag_doc_itens~companycode
**           AND bsak~belnr                EQ zc_fi_prog_pag_doc_itens~accountingdocument
**           AND bsak~buzei                EQ zc_fi_prog_pag_doc_itens~accountingdocumentitem
**           AND bsak~gjahr                EQ zc_fi_prog_pag_doc_itens~fiscalyear
**           AND bsak~lifnr                EQ zc_fi_prog_pag_doc_itens~supplier
**         WHERE zc_fi_pgto_grp_tesouraria~companycode       IN @lr_bukrs
**           AND zc_fi_pgto_grp_tesouraria~netduedate        IN @lr_netdt
**         UNION
**        SELECT DISTINCT
**               zc_fi_pgto_grp_tesouraria~companycode,
**               zc_fi_pgto_grp_tesouraria~netduedate,
**               zc_fi_pgto_grp_tesouraria~cashplanninggroup,
**               '0' AS paymentdocument,
**               bsik~belnr AS document,
**               bsik~dmbtr,
**          CASE WHEN bsik~zlspr <> ' ' THEN 'B'
**               ELSE 'O'
**           END AS tipo,
**               bsik~bstat,
**               bsik~gjahr
**          FROM zc_fi_pgto_grp_tesouraria
**         INNER JOIN zc_fi_prog_pag_doc_itens
**            ON zc_fi_pgto_grp_tesouraria~companycode       = zc_fi_prog_pag_doc_itens~companycode
**           AND zc_fi_pgto_grp_tesouraria~cashplanninggroup = zc_fi_prog_pag_doc_itens~cashplanninggroup
**           AND zc_fi_pgto_grp_tesouraria~netduedate        = zc_fi_prog_pag_doc_itens~netduedate
**         INNER JOIN bsik_view AS bsik
**            ON bsik~bukrs                EQ zc_fi_prog_pag_doc_itens~companycode
***           AND bsik~belnr                EQ zc_fi_prog_pag_doc_itens~DocDocument
**           AND bsik~gjahr                EQ zc_fi_prog_pag_doc_itens~fiscalyear
**           AND bsik~lifnr                EQ zc_fi_prog_pag_doc_itens~supplier
**         WHERE zc_fi_pgto_grp_tesouraria~companycode       IN @lr_bukrs
**           AND zc_fi_pgto_grp_tesouraria~netduedate        IN @lr_netdt
**         ORDER BY companycode, netduedate, cashplanninggroup
**          INTO CORRESPONDING FIELDS OF TABLE @lt_docs.
**
**        DELETE lt_docs WHERE cashplanninggroup NOT IN lr_cashplanninggroup.
**
**      WHEN '2'.
**
**        SELECT DISTINCT
**               zi_fi_prog_pagamento_grp~companycode,
**               zi_fi_prog_pagamento_grp~netduedate,
**               bsak~augbl AS paymentdocument,
**               bsak~belnr AS document,
**               bsak~dmbtr,
**               'P' AS tipo,
**               bsak~bstat,
**               bsak~gjahr
**          FROM zi_fi_prog_pagamento_grp
**         INNER JOIN zc_fi_prog_pag_doc_itens
**            ON zi_fi_prog_pagamento_grp~bank          = zc_fi_prog_pag_doc_itens~housebank
**           AND zi_fi_prog_pagamento_grp~paymentmethod = zc_fi_prog_pag_doc_itens~paymentmethod
**           AND zi_fi_prog_pagamento_grp~companycode   = zc_fi_prog_pag_doc_itens~companycode
**           AND zi_fi_prog_pagamento_grp~supplier      = zc_fi_prog_pag_doc_itens~supplier
**           AND zi_fi_prog_pagamento_grp~netduedate    = zc_fi_prog_pag_doc_itens~netduedate
**         INNER JOIN bsak_view AS bsak
**            ON bsak~bukrs                EQ zc_fi_prog_pag_doc_itens~companycode
**           AND bsak~belnr                EQ zc_fi_prog_pag_doc_itens~accountingdocument
**           AND bsak~buzei                EQ zc_fi_prog_pag_doc_itens~accountingdocumentitem
**           AND bsak~gjahr                EQ zc_fi_prog_pag_doc_itens~fiscalyear
**           AND bsak~lifnr                EQ zc_fi_prog_pag_doc_itens~supplier
**         WHERE zi_fi_prog_pagamento_grp~companycode       IN @lr_bukrs
**           AND zi_fi_prog_pagamento_grp~netduedate        IN @lr_netdt
**           AND zi_fi_prog_pagamento_grp~bank              IN @lr_hbkid
**           AND zi_fi_prog_pagamento_grp~paymentmethod     IN @lr_rzawe
**         UNION
**        SELECT DISTINCT
**               zi_fi_prog_pagamento_grp~companycode,
**               zi_fi_prog_pagamento_grp~netduedate,
**               '0' AS paymentdocument,
**               bsik~belnr AS document,
**               bsik~dmbtr,
**          CASE WHEN bsik~zlspr <> ' ' THEN 'B'
**               ELSE 'O'
**           END AS tipo,
**               bsik~bstat,
**               bsik~gjahr
**          FROM zi_fi_prog_pagamento_grp
**         INNER JOIN zc_fi_prog_pag_doc_itens
**            ON zi_fi_prog_pagamento_grp~bank          = zc_fi_prog_pag_doc_itens~housebank
**           AND zi_fi_prog_pagamento_grp~paymentmethod = zc_fi_prog_pag_doc_itens~paymentmethod
**           AND zi_fi_prog_pagamento_grp~companycode   = zc_fi_prog_pag_doc_itens~companycode
**           AND zi_fi_prog_pagamento_grp~supplier      = zc_fi_prog_pag_doc_itens~supplier
**           AND zi_fi_prog_pagamento_grp~netduedate    = zc_fi_prog_pag_doc_itens~netduedate
**         INNER JOIN bsik_view AS bsik
**            ON bsik~bukrs                EQ zc_fi_prog_pag_doc_itens~companycode
**           AND bsik~gjahr                EQ zc_fi_prog_pag_doc_itens~fiscalyear
**           AND bsik~lifnr                EQ zc_fi_prog_pag_doc_itens~supplier
**         WHERE zi_fi_prog_pagamento_grp~companycode       IN @lr_bukrs
**           AND zi_fi_prog_pagamento_grp~netduedate        IN @lr_netdt
***           AND zi_fi_prog_pagamento_grp~bank              IN @lr_hbkid
***           AND zi_fi_prog_pagamento_grp~paymentmethod     IN @lr_rzawe
**         ORDER BY companycode, netduedate
**          INTO CORRESPONDING FIELDS OF TABLE @lt_docs.
**
**      WHEN OTHERS.

*        "Valores pagos
*        SELECT DISTINCT
*               zc_fi_aprov_temse~companycode,
*               zc_fi_aprov_temse~netduedate,
*               zc_fi_aprov_temse~cashplanninggroup,
*               bsak~augbl AS paymentdocument,
*               bsak~belnr AS document,
*               bsak~dmbtr,
*               'P' AS tipo,
*               bsak~bstat,
*               bsak~gjahr
*            FROM zc_fi_aprov_temse
*
*        INNER JOIN zc_fi_prog_pag_doc_itens
*           ON zc_fi_aprov_temse~companycode       = zc_fi_prog_pag_doc_itens~companycode
*          AND zc_fi_aprov_temse~cashplanninggroup = zc_fi_prog_pag_doc_itens~cashplanninggroup
*          AND zc_fi_aprov_temse~netduedate        = zc_fi_prog_pag_doc_itens~netduedate
*        INNER JOIN bsak_view AS bsak
*           ON bsak~bukrs                EQ zc_fi_prog_pag_doc_itens~companycode
*          AND bsak~belnr                EQ zc_fi_prog_pag_doc_itens~accountingdocument
*          AND bsak~buzei                EQ zc_fi_prog_pag_doc_itens~accountingdocumentitem
*          AND bsak~gjahr                EQ zc_fi_prog_pag_doc_itens~fiscalyear
*          AND bsak~lifnr                EQ zc_fi_prog_pag_doc_itens~supplier
*        WHERE zc_fi_aprov_temse~companycode          IN @lr_bukrs
*          AND zc_fi_aprov_temse~netduedate           IN @lr_netdt
*          AND zc_fi_prog_pag_doc_itens~paidamountinpaytcurrency IS NOT INITIAL
*
*        UNION
*        "Valores abertos e bloqueados
*        SELECT DISTINCT
*               zc_fi_aprov_temse~companycode,
*               zc_fi_aprov_temse~netduedate,
*               zc_fi_aprov_temse~cashplanninggroup,
*               '0' AS paymentdocument,
*               bsik~belnr AS document,
*               bsik~dmbtr,
*               CASE WHEN bsik~zlspr <> ' ' THEN 'B'
*                    ELSE 'O'
*               END AS tipo,
*               bsik~bstat,
*               bsik~gjahr
*          FROM zc_fi_aprov_temse
*         INNER JOIN zc_fi_prog_pag_doc_itens
*            ON zc_fi_aprov_temse~companycode       = zc_fi_prog_pag_doc_itens~companycode
*           AND zc_fi_aprov_temse~cashplanninggroup = zc_fi_prog_pag_doc_itens~cashplanninggroup
*           AND zc_fi_aprov_temse~netduedate        = zc_fi_prog_pag_doc_itens~netduedate
*         INNER JOIN bsik_view AS bsik
*            ON bsik~bukrs                EQ zc_fi_prog_pag_doc_itens~companycode
**           AND bsik~belnr                EQ zc_fi_prog_pag_doc_itens~DocDocument
*           AND bsik~gjahr                EQ zc_fi_prog_pag_doc_itens~fiscalyear
*           AND bsik~lifnr                EQ zc_fi_prog_pag_doc_itens~supplier
*           AND bsik~bschl IN ( '31', '39' )
*         WHERE zc_fi_aprov_temse~companycode       IN @lr_bukrs
*           AND zc_fi_aprov_temse~netduedate        IN @lr_netdt
*           AND zc_fi_prog_pag_doc_itens~paidamountinpaytcurrency IS INITIAL
*         ORDER BY companycode, netduedate, cashplanninggroup
*          INTO CORRESPONDING FIELDS OF TABLE @lt_docs.

***        SELECT DISTINCT
***               zc_fi_aprov_temse~companycode,
***               zc_fi_aprov_temse~netduedate,
***               zc_fi_aprov_temse~cashplanninggroup,
***               bsak~augbl AS paymentdocument,
***               bsak~belnr AS document,
***               bsak~dmbtr,
***               'P' AS tipo,
***               bsak~bstat,
***               bsak~gjahr
***            FROM zc_fi_aprov_temse
***           INNER JOIN zc_fi_prog_pag_doc_itens
***              ON zc_fi_aprov_temse~companycode       = zc_fi_prog_pag_doc_itens~companycode
***             AND zc_fi_aprov_temse~cashplanninggroup = zc_fi_prog_pag_doc_itens~cashplanninggroup
***             AND zc_fi_aprov_temse~netduedate        = zc_fi_prog_pag_doc_itens~netduedate
***           INNER JOIN bsak_view AS bsak
***              ON bsak~bukrs                EQ zc_fi_prog_pag_doc_itens~companycode
***             AND bsak~belnr                EQ zc_fi_prog_pag_doc_itens~accountingdocument
***             AND bsak~buzei                EQ zc_fi_prog_pag_doc_itens~accountingdocumentitem
***             AND bsak~gjahr                EQ zc_fi_prog_pag_doc_itens~fiscalyear
***             AND bsak~lifnr                EQ zc_fi_prog_pag_doc_itens~supplier
***           WHERE zc_fi_aprov_temse~companycode          IN @lr_bukrs
***             AND zc_fi_aprov_temse~netduedate           IN @lr_netdt
***             AND zc_fi_prog_pag_doc_itens~housebank     IN @lr_hbkid
***             AND zc_fi_prog_pag_doc_itens~paymentmethod IN @lr_rzawe
***        UNION
***        SELECT DISTINCT
***               zc_fi_aprov_temse~companycode,
***               zc_fi_aprov_temse~netduedate,
***               zc_fi_aprov_temse~cashplanninggroup,
***               '0' AS paymentdocument,
***               bsik~belnr AS document,
***               bsik~dmbtr,
***               CASE WHEN bsik~zlspr <> ' ' THEN 'B'
***                    ELSE 'O'
***               END AS tipo,
***               bsik~bstat,
***               bsik~gjahr
***          FROM zc_fi_aprov_temse
***         INNER JOIN zc_fi_prog_pag_doc_itens
***            ON zc_fi_aprov_temse~companycode       = zc_fi_prog_pag_doc_itens~companycode
***           AND zc_fi_aprov_temse~cashplanninggroup = zc_fi_prog_pag_doc_itens~cashplanninggroup
***           AND zc_fi_aprov_temse~netduedate        = zc_fi_prog_pag_doc_itens~netduedate
***         INNER JOIN bsik_view AS bsik
***            ON bsik~bukrs                EQ zc_fi_prog_pag_doc_itens~companycode
****           AND bsik~belnr                EQ zc_fi_prog_pag_doc_itens~DocDocument
***           AND bsik~gjahr                EQ zc_fi_prog_pag_doc_itens~fiscalyear
***           AND bsik~lifnr                EQ zc_fi_prog_pag_doc_itens~supplier
***           AND bsik~bschl IN ( '31', '39' )
***         WHERE zc_fi_aprov_temse~companycode       IN @lr_bukrs
***           AND zc_fi_aprov_temse~netduedate        IN @lr_netdt
***         ORDER BY companycode, netduedate, cashplanninggroup
***          INTO CORRESPONDING FIELDS OF TABLE @lt_docs.
*
*        DELETE lt_docs WHERE cashplanninggroup NOT IN lr_cashplanninggroup.
*
*    ENDCASE.

    SELECT *
      FROM zc_fi_prog_pag_doc_itens
      INTO TABLE @lt_docs
    WHERE companycode       IN @lr_bukrs
*      AND paymentrunid      IN @lr_paymentrunid
      AND netduedate        IN @lr_netdt.               "#EC CI_SEL_DEL

    IF lv_tipo = '2'.
      DELETE lt_docs WHERE housebank NOT IN lr_hbkid.   "#EC CI_SEL_DEL
      DELETE lt_docs WHERE paymentmethod NOT IN lr_rzawe. "#EC CI_SEL_DEL
    ELSE.
      DELETE lt_docs WHERE cashplanninggroup NOT IN lr_cashplanninggroup. "#EC CI_SEL_DEL
    ENDIF.

    DELETE lt_docs WHERE reptype NOT IN lr_reptype.     "#EC CI_SEL_DEL

**    "Dupla verificação, caso tenha trocado o grupo de tesouraria - Inicio
**    SELECT bukrs, belnr, gjahr, fdgrv
**        FROM ztfi_doc_fdgrv
**        INTO TABLE @DATA(lt_mod_grpteso)
**        FOR ALL ENTRIES IN @lt_docs
**        WHERE bukrs = @lt_docs-companycode
**          AND belnr = @lt_docs-document
**          AND gjahr = @lt_docs-gjahr.
**
**    LOOP AT lt_mod_grpteso ASSIGNING FIELD-SYMBOL(<fs_grpteso>).
**      READ TABLE lt_docs ASSIGNING FIELD-SYMBOL(<fs_docs_check>) WITH KEY companycode = <fs_grpteso>-bukrs
**                                                                    document = <fs_grpteso>-belnr
**                                                                    gjahr = <fs_grpteso>-gjahr.
**      IF sy-subrc = 0.
**        <fs_docs_check>-cashplanninggroup = <fs_grpteso>-fdgrv.
**      ENDIF.
**    ENDLOOP.
**
**    DELETE lt_docs WHERE cashplanninggroup NOT IN lr_cashplanninggroup.
**    "Dupla verificação, caso tenha trocado o grupo de tesouraria - Fim
    TYPES:
      BEGIN OF ty_bill,
        augbl   TYPE augbl,
        belnr   TYPE belnr_d,
        buzei   TYPE buzei,
        gjahr   TYPE gjahr,
        bstat   TYPE bseg-h_bstat,
        umskz   TYPE bseg-umskz,
        tipo(1) TYPE c,
      END OF ty_bill,

      ty_t_bill TYPE TABLE OF ty_bill.

    DATA lt_billing TYPE ty_t_bill.

    lt_billing = VALUE #( BASE lt_billing FOR ls_doc IN lt_docs ( augbl = ls_doc-paymentdocument
                                                                  belnr = ls_doc-accountingdocument
                                                                  buzei = ls_doc-accountingdocumentitem
                                                                  gjahr = ls_doc-fiscalyear
                                                                  bstat = ls_doc-bstat
                                                                  umskz = ls_doc-umskz
                                                                  tipo  = ls_doc-tipo ) ).

    SORT lt_billing BY augbl belnr buzei gjahr tipo.
    DELETE ADJACENT DUPLICATES FROM lt_billing COMPARING augbl belnr buzei gjahr tipo.

    LOOP AT lt_billing ASSIGNING FIELD-SYMBOL(<fs_billing>).

      CASE <fs_billing>-tipo.
          "pagos
        WHEN 'P'.
          APPEND VALUE #( name = 'ClearingAccountingDocument'(011) value = <fs_billing>-augbl ) TO lt_paid.
          APPEND VALUE #( name = 'AccountingDocument'(004) value = <fs_billing>-belnr ) TO lt_paid.
          APPEND VALUE #( name = 'AccountingDocumentItem'(010) value = <fs_billing>-buzei ) TO lt_paid.
          APPEND VALUE #( name = 'DueItemCategory'(012) value = SWITCH #( <fs_billing>-bstat WHEN 'S' THEN 'M' WHEN 'V' OR 'W' THEN 'P' ELSE COND #( WHEN <fs_billing>-umskz IS INITIAL THEN ' ' ELSE 'S' ) ) ) TO lt_paid.
          APPEND VALUE #( name = 'FiscalYear'(013) value = <fs_billing>-gjahr ) TO lt_paid.

          "Abertos
        WHEN 'O'.
          APPEND VALUE #( name = 'AccountingDocument'(004) value = <fs_billing>-belnr ) TO lt_open.
          APPEND VALUE #( name = 'AccountingDocumentItem'(010) value = <fs_billing>-buzei ) TO lt_open.
          APPEND VALUE #( name = 'DueItemCategory'(012) value = SWITCH #( <fs_billing>-bstat WHEN 'S' THEN 'M' WHEN 'V' OR 'W' THEN 'P' ELSE COND #( WHEN <fs_billing>-umskz IS INITIAL THEN ' ' ELSE 'S' ) ) ) TO lt_open.
          APPEND VALUE #( name = 'FiscalYear'(013) value = <fs_billing>-gjahr ) TO lt_open.


          "Bloqueados
        WHEN 'B'.
          APPEND VALUE #( name = 'AccountingDocument'(004) value = <fs_billing>-belnr ) TO lt_bloq.
          APPEND VALUE #( name = 'AccountingDocumentItem'(010) value = <fs_billing>-buzei ) TO lt_bloq.
          APPEND VALUE #( name = 'DueItemCategory'(012) value = SWITCH #( <fs_billing>-bstat WHEN 'S' THEN 'M' WHEN 'V' OR 'W' THEN 'P' ELSE COND #( WHEN <fs_billing>-umskz IS INITIAL THEN ' ' ELSE 'S' ) ) ) TO lt_bloq.
          APPEND VALUE #( name = 'FiscalYear'(013) value = <fs_billing>-gjahr ) TO lt_bloq.

        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

    APPEND VALUE #( name = 'ClearingStatus'(014) value = '1' ) TO lt_paid.
    APPEND VALUE #( name = 'ClearingStatus'(014) value = '2' ) TO lt_open.
    APPEND VALUE #( name = 'ClearingStatus'(014) value = '2' ) TO lt_bloq.

    SORT lt_paid BY name value.
    SORT lt_open BY name value.
    SORT lt_bloq BY name value.

    DELETE ADJACENT DUPLICATES FROM lt_paid COMPARING name value.
    DELETE ADJACENT DUPLICATES FROM lt_open COMPARING name value.
    DELETE ADJACENT DUPLICATES FROM lt_bloq COMPARING name value.


*    LOOP AT lt_docs INTO DATA(ls_docs)
*    GROUP BY ( companycode = ls_docs-companycode netduedate = ls_docs-netduedate cashplanninggrouptipo = ls_docs-cashplanninggroup tipo = ls_docs-tipo )
*    ASSIGNING FIELD-SYMBOL(<fs_docs>).
*
*      LOOP AT GROUP <fs_docs> INTO DATA(ls_doc).
*
*        CASE ls_doc-tipo.
*            "pagos
*          WHEN 'P'.
*            APPEND VALUE #( name = 'ClearingAccountingDocument'(011) value = ls_doc-paymentdocument ) TO lt_paid.
*            APPEND VALUE #( name = 'AccountingDocument'(004) value = ls_doc-accountingdocument ) TO lt_paid.
*            APPEND VALUE #( name = 'DueItemCategory'(012) value = ls_doc-bstat ) TO lt_paid.
*            APPEND VALUE #( name = 'FiscalYear'(013) value = ls_doc-fiscalyear ) TO lt_paid.
*            APPEND VALUE #( name = 'ClearingStatus'(014) value = '1' ) TO lt_paid.
*            APPEND VALUE #( name = 'HouseBank'(015) value = ls_doc-housebank ) TO lt_paid.
*            APPEND VALUE #( name = 'PaymentMethod'(016) value = ls_doc-paymentmethod ) TO lt_paid.
*
*            "Abertos
*          WHEN 'O'.
*            APPEND VALUE #( name = 'AccountingDocument'(004) value = ls_doc-accountingdocument ) TO lt_open.
*            APPEND VALUE #( name = 'DueItemCategory'(012) value = ls_doc-bstat ) TO lt_open.
*            APPEND VALUE #( name = 'FiscalYear'(013) value = ls_doc-fiscalyear ) TO lt_open.
*            APPEND VALUE #( name = 'ClearingStatus'(014) value = '2' ) TO lt_open.
*            APPEND VALUE #( name = 'HouseBank'(015) value = ls_doc-housebank ) TO lt_open.
*            APPEND VALUE #( name = 'PaymentMethod'(016) value = ls_doc-paymentmethod ) TO lt_open.
*
*            "Bloqueados
*          WHEN 'B'.
*            APPEND VALUE #( name = 'AccountingDocument'(004) value = ls_doc-accountingdocument ) TO lt_bloq.
*            APPEND VALUE #( name = 'DueItemCategory'(012) value = ls_doc-bstat ) TO lt_bloq.
*            APPEND VALUE #( name = 'FiscalYear'(013) value = ls_doc-fiscalyear ) TO lt_bloq.
*            APPEND VALUE #( name = 'ClearingStatus'(014) value = '2' ) TO lt_bloq.
*            APPEND VALUE #( name = 'HouseBank'(015) value = ls_doc-housebank ) TO lt_bloq.
*            APPEND VALUE #( name = 'PaymentMethod'(016) value = ls_doc-paymentmethod ) TO lt_bloq.
*
*          WHEN OTHERS.
*        ENDCASE.
*
*      ENDLOOP.
*
*    ENDLOOP.
*
*    SORT: lt_paid, lt_open, lt_bloq BY name value.
*
*    DELETE ADJACENT DUPLICATES FROM: lt_paid, lt_open, lt_bloq COMPARING value.
    DELETE ADJACENT DUPLICATES FROM lt_docs COMPARING companycode netduedate cashplanninggroup.

    APPEND VALUE #( name = 'CustomClearingStatus'(005) value = 'A' )      TO: lt_paid, lt_open, lt_bloq.
    APPEND VALUE #( name = 'KeyDate'(006) value = space )                 TO: lt_paid, lt_open, lt_bloq.
    APPEND VALUE #( name = 'PostingDate'(008) value = space )             TO: lt_paid, lt_open, lt_bloq.
    APPEND VALUE #( name = 'CompanyCode'(007) value = lr_bukrs[ 1 ]-low ) TO: lt_paid, lt_open, lt_bloq.

*    IF line_exists( lt_paid[ name = 'ClearingAccountingDocument'(011) ] ).
    DATA(lv_paymentdocument) = cl_lsapi_manager=>create_flp_url( object = 'Supplier'(002) action = 'manageLineItems'(003) parameters = lt_paid ).
*    ENDIF.

*    IF line_exists( lt_open[ name = 'AccountingDocument'(004) ] ).
    DATA(lv_opendocument) = cl_lsapi_manager=>create_flp_url( object = 'Supplier'(002) action = 'manageLineItems'(003) parameters = lt_open ).
*    ENDIF.

*    IF line_exists( lt_bloq[ name = 'AccountingDocument'(004) ] ).
    DATA(lv_blockeddocument) = cl_lsapi_manager=>create_flp_url( object = 'Supplier'(002) action = 'manageLineItems'(003) parameters = lt_bloq ).
*    ENDIF.

*    DELETE lt_docs WHERE CompanyCode NOT IN lr_bukrs OR NetDueDate NOT IN lr_netdt OR CashPlanningGroup NOT IN lr_cashplanninggroup.
*    DELETE lt_docs WHERE CashPlanningGroup NOT IN lr_cashplanninggroup.
    rt_return = CORRESPONDING #( lt_docs ).

    LOOP AT rt_return ASSIGNING FIELD-SYMBOL(<fs_return>).

      CASE <fs_return>-tipo.
        WHEN 'P'.
          <fs_return>-paymentdocument = lv_paymentdocument.

        WHEN 'O'.
          <fs_return>-opendocument = lv_opendocument.

        WHEN 'B'.
          <fs_return>-blockeddocument = lv_blockeddocument.

        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

    DELETE rt_return FROM 2.

  ENDMETHOD.
ENDCLASS.
