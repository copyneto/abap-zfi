class ZCLFI_RELAT_FISCAL definition
  public
  final
  create public .

public section.

  interfaces IF_RAP_QUERY_PROVIDER .
  interfaces IF_RAP_QUERY_FILTER .
protected section.
PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_filters, " Tipo para ranges
      BRANCH        TYPE if_rap_query_filter=>tt_range_option,
      pstdat        TYPE if_rap_query_filter=>tt_range_option,
      docnum        TYPE if_rap_query_filter=>tt_range_option,
      nfnum         TYPE if_rap_query_filter=>tt_range_option,
      nfenum        TYPE if_rap_query_filter=>tt_range_option,
      material      TYPE if_rap_query_filter=>tt_range_option,
      valuationarea TYPE if_rap_query_filter=>tt_range_option,
      valuationtype TYPE if_rap_query_filter=>tt_range_option,
      cfop          TYPE if_rap_query_filter=>tt_range_option,
      bukrs         TYPE if_rap_query_filter=>tt_range_option,
      vkorg         TYPE if_rap_query_filter=>tt_range_option,
      vtweg         TYPE if_rap_query_filter=>tt_range_option,
      spart         TYPE if_rap_query_filter=>tt_range_option,
      txjcd         TYPE if_rap_query_filter=>tt_range_option,
      parid         TYPE if_rap_query_filter=>tt_range_option,
      printd        TYPE if_rap_query_filter=>tt_range_option,
      tpdoc         TYPE if_rap_query_filter=>tt_range_option,
      tpnf          TYPE if_rap_query_filter=>tt_range_option,
      BaseUnit      type if_rap_query_filter=>tt_range_option,
    END OF ty_filters .
  TYPES:
  " Tipo de retorno de dados à custom entity
    ty_relat TYPE STANDARD TABLE OF zc_fi_relatorio_fiscal WITH EMPTY KEY .

  DATA gs_range TYPE ty_filters .

  METHODS set_filters
    IMPORTING
      !it_filters TYPE if_rap_query_filter=>tt_name_range_pairs .
  METHODS build
    EXPORTING
      !et_relat TYPE ty_relat .
ENDCLASS.



CLASS ZCLFI_RELAT_FISCAL IMPLEMENTATION.


  METHOD build.

    TYPES: BEGIN OF ty_collect,
             branch        TYPE j_1bbranc_,
             vkorg         TYPE vkorg,
             material      TYPE matnr,
             ncmcode       TYPE steuc,
             cfop          TYPE char10,
             materialname  TYPE maktx,
             qtdunit       TYPE f,
             baseunit      TYPE j_1bnetunt,
             quantidade2   TYPE f,
             unitkg        TYPE lrmei,
             frete         TYPE f,
             vlrsemfrete   TYPE f,
             icms_base     TYPE f,
             icms_valor    TYPE f,
             ipi_base      TYPE f,
             ipi_valor     TYPE f,
             subst_base    TYPE f,
             subs_valor    TYPE f,
             pis_valor     TYPE f,
             cofins_valor  TYPE f,
             valuationarea TYPE bwkey,
             valuationtype TYPE bwtar_d,
             segment       TYPE fb_segment,
             sakn1         TYPE j_1b_gl_account,
             sakntext      TYPE txt50_skat,
             orgvendastext TYPE vtxtk,
           END OF ty_collect.

    DATA: lt_collect TYPE STANDARD TABLE OF ty_collect,
          lr_printd  TYPE RANGE OF zc_fi_relatorio_fiscal-printd.

    DATA: ls_collect TYPE ty_collect,
          ls_relat   TYPE zc_fi_relatorio_fiscal.

*    IF gs_range-printd IS NOT INITIAL.
*      lr_printd = VALUE #( BASE lr_printd ( sign   = 'I'
*                                            option = 'EQ'
*                                            low    = gs_range-printd ) ).
*    ENDIF.

    SELECT branch,
           vkorg,
           material,
           ncmcode,
           cfop,
           materialname,
           qtdunit,
           baseunit,
           quantidade2,
           unitkg,
           frete,
           printd,
           tpdoc,
           tpnf,
           vlrsemfrete,
           waerk,
           icms_base,
           icms_valor,
           ipi_base,
           ipi_valor,
           subst_base,
           subs_valor,
           pis_valor,
           cofins_valor,
           valuationarea,
           valuationtype,
           segment,
           sakn1,
           sakntext,
           pstdat,
           nfnum,
           nfenum,
           bukrs,
           vtweg,
           spart,
           txjcd,
           parid,
           orgvendastext,
           docnum,
           itmnum
      FROM zi_fi_filtro_relatorio_fiscal
     WHERE branch        IN @gs_range-branch
       AND pstdat        IN @gs_range-pstdat
       AND docnum        IN @gs_range-docnum
       AND nfnum         IN @gs_range-nfnum
       AND nfenum        IN @gs_range-nfenum
       AND material      IN @gs_range-material
       AND valuationarea IN @gs_range-valuationarea
       AND valuationtype IN @gs_range-valuationtype
       AND cfop          IN @gs_range-cfop
       AND bukrs         IN @gs_range-bukrs
       AND vkorg         IN @gs_range-vkorg
       AND vtweg         IN @gs_range-vtweg
       AND spart         IN @gs_range-spart
       AND txjcd         IN @gs_range-txjcd
       AND parid         IN @gs_range-parid
       AND printd        IN @gs_range-printd
       AND tpdoc         IN @gs_range-tpdoc
       AND tpnf          IN @gs_range-tpnf
       AND baseunit      IN @gs_range-baseunit
      INTO TABLE @DATA(lt_itens).

    LOOP AT lt_itens ASSIGNING FIELD-SYMBOL(<fs_itens>).
      ls_collect-branch        = <fs_itens>-branch.
      ls_collect-vkorg         = <fs_itens>-vkorg.
      ls_collect-material      = <fs_itens>-material.
      ls_collect-ncmcode       = <fs_itens>-ncmcode.
      ls_collect-cfop          = <fs_itens>-cfop.
      ls_collect-materialname  = <fs_itens>-materialname.
      ls_collect-qtdunit       = <fs_itens>-qtdunit.
      ls_collect-baseunit      = <fs_itens>-baseunit.
      ls_collect-quantidade2   = <fs_itens>-quantidade2.
      ls_collect-unitkg        = <fs_itens>-unitkg.
      ls_collect-frete         = <fs_itens>-frete.
      ls_collect-vlrsemfrete   = <fs_itens>-vlrsemfrete.
      ls_collect-icms_base     = <fs_itens>-icms_base.
      ls_collect-icms_valor    = <fs_itens>-icms_valor.
      ls_collect-ipi_base      = <fs_itens>-ipi_base.
      ls_collect-ipi_valor     = <fs_itens>-ipi_valor.
      ls_collect-subst_base    = <fs_itens>-subst_base.
      ls_collect-subs_valor    = <fs_itens>-subs_valor.
      ls_collect-pis_valor     = <fs_itens>-pis_valor.
      ls_collect-cofins_valor  = <fs_itens>-cofins_valor.
      ls_collect-valuationarea = <fs_itens>-valuationarea.
      ls_collect-valuationtype = <fs_itens>-valuationtype.
      ls_collect-segment       = <fs_itens>-segment.
      ls_collect-sakn1         = <fs_itens>-sakn1.
      ls_collect-sakntext      = <fs_itens>-sakntext.
      ls_collect-orgvendastext = <fs_itens>-orgvendastext.

      COLLECT ls_collect INTO lt_collect.
      CLEAR ls_collect.
    ENDLOOP.

    IF lt_collect[] IS NOT INITIAL.

      IF sy-subrc IS INITIAL.
        SORT lt_collect BY branch
                           vkorg
                           material
                           ncmcode
                           cfop
                           qtdunit
                           baseunit
                           unitkg
                           frete
                           vlrsemfrete.
      ENDIF.

      LOOP AT lt_collect ASSIGNING FIELD-SYMBOL(<fs_collect>).

        ls_relat-branch        = <fs_collect>-branch.
        ls_relat-vkorg         = <fs_collect>-vkorg.
        ls_relat-material      = <fs_collect>-material.
        ls_relat-ncmcode       = <fs_collect>-ncmcode.
        ls_relat-cfop          = <fs_collect>-cfop.
        ls_relat-materialname  = <fs_collect>-materialname.
        ls_relat-qtdunit       = <fs_collect>-qtdunit.
        ls_relat-baseunit      = <fs_collect>-baseunit.
        ls_relat-quantidade2   = <fs_collect>-quantidade2.
        ls_relat-unitkg        = <fs_collect>-unitkg.
        ls_relat-frete         = <fs_collect>-frete.
        ls_relat-vlrsemfrete   = <fs_collect>-vlrsemfrete.
        ls_relat-icms_base     = <fs_collect>-icms_base.
        ls_relat-icms_valor    = <fs_collect>-icms_valor.
        ls_relat-ipi_base      = <fs_collect>-ipi_base.
        ls_relat-ipi_valor     = <fs_collect>-ipi_valor.
        ls_relat-subst_base    = <fs_collect>-subst_base.
        ls_relat-subs_valor    = <fs_collect>-subs_valor.
        ls_relat-pis_valor     = <fs_collect>-pis_valor.
        ls_relat-cofins_valor  = <fs_collect>-cofins_valor.
        ls_relat-valuationarea = <fs_collect>-valuationarea.
        ls_relat-valuationtype = <fs_collect>-valuationtype.
        ls_relat-segment       = <fs_collect>-segment.
        ls_relat-sakn1         = <fs_collect>-sakn1.
        ls_relat-sakntext      = <fs_collect>-sakntext.
        ls_relat-orgvendastext = <fs_collect>-orgvendastext.

        APPEND ls_relat TO et_relat.
        CLEAR ls_relat.

      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD if_rap_query_filter~get_as_ranges.
    RETURN.
  ENDMETHOD.


  METHOD if_rap_query_filter~get_as_sql_string.
    RETURN.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

* ---------------------------------------------------------------------------
* Verifica se informação foi solicitada
* ---------------------------------------------------------------------------
    TRY.
        CHECK io_request->is_data_requested( ).
      CATCH cx_rfc_dest_provider_error  INTO DATA(lo_ex_dest).
        DATA(lv_exp_msg) = lo_ex_dest->get_longtext( ).
        RETURN.
    ENDTRY.

* ---------------------------------------------------------------------------
* Recupera informações de entidade, paginação, etc
* ---------------------------------------------------------------------------
    DATA(lv_top)      = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)     = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

* ---------------------------------------------------------------------------
* Recupera e seta filtros de seleção
* ---------------------------------------------------------------------------
    TRY.
        me->set_filters( EXPORTING it_filters = io_request->get_filter( )->get_as_ranges( ) ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lo_ex_filter).
        lv_exp_msg = lo_ex_filter->get_longtext( ).
    ENDTRY.

* ---------------------------------------------------------------------------
* Monta relatório
* ---------------------------------------------------------------------------
    DATA lt_result TYPE STANDARD TABLE OF zc_fi_relatorio_fiscal WITH EMPTY KEY.
    me->build( IMPORTING et_relat = lt_result ).

* ---------------------------------------------------------------------------
* Realiza ordenação de acordo com parâmetros de entrada
* ---------------------------------------------------------------------------
    DATA(lt_requested_sort) = io_request->get_sort_elements( ).
    IF lines( lt_requested_sort ) > 0.
      DATA(lt_sort) = VALUE abap_sortorder_tab( FOR ls_sort IN lt_requested_sort ( name = ls_sort-element_name descending = ls_sort-descending ) ).
      SORT lt_result BY (lt_sort).
    ENDIF.

*** ---------------------------------------------------------------------------
*** Realiza as agregações de acordo com as annotatios na custom entity
*** ---------------------------------------------------------------------------
*    DATA(lt_req_elements) = io_request->get_requested_elements( ).
*
*    DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).
*    IF lt_aggr_element IS NOT INITIAL.
*      LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<fs_aggr_element>).
*        DELETE lt_req_elements WHERE table_line = <fs_aggr_element>-result_element.
*        DATA(lv_aggregation) = |{ <fs_aggr_element>-aggregation_method }( { <fs_aggr_element>-input_element } ) as { <fs_aggr_element>-result_element }|.
*        APPEND lv_aggregation TO lt_req_elements.
*      ENDLOOP.
*    ENDIF.
*
*    DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = ',' ).
*
*    DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
*    DATA(lv_grouping) = concat_lines_of(  table = lt_grouped_element sep = ',' ).
*
*    SELECT (lv_req_elements) FROM @lt_result AS dados
*                             GROUP BY (lv_grouping)
*                             INTO CORRESPONDING FIELDS OF TABLE @lt_result.

* ---------------------------------------------------------------------------
* Controla paginação (Adiciona registros de 20 em 20 )
* ---------------------------------------------------------------------------
    DATA(lt_result_page) = lt_result[].
    lt_result_page = VALUE #( FOR ls_result IN lt_result FROM ( lv_skip + 1 ) TO ( lv_skip + lv_max_rows ) ( ls_result ) ).

* ---------------------------------------------------------------------------
* Exibe registros
* ---------------------------------------------------------------------------
    io_response->set_total_number_of_records( CONV #( lines( lt_result[] ) ) ).
    io_response->set_data( lt_result_page[] ).

  ENDMETHOD.


  METHOD set_filters.

    CHECK it_filters[] IS NOT INITIAL.

    LOOP AT it_filters ASSIGNING FIELD-SYMBOL(<fs_filters>).

      CASE <fs_filters>-name.
        WHEN 'BRANCH'.
          gs_range-branch = VALUE #( BASE gs_range-branch ( LINES OF <fs_filters>-range ) ).

        WHEN 'PSTDAT'.
          gs_range-pstdat = VALUE #( BASE gs_range-pstdat ( LINES OF <fs_filters>-range ) ).

        WHEN 'DOCNUM'.
          gs_range-docnum = VALUE #( BASE gs_range-docnum ( LINES OF <fs_filters>-range ) ).

        WHEN 'NFNUM'.
          gs_range-nfnum = VALUE #( BASE gs_range-nfnum ( LINES OF <fs_filters>-range ) ).

        WHEN 'NFENUM'.
          gs_range-nfenum = VALUE #( BASE gs_range-nfenum ( LINES OF <fs_filters>-range ) ).

        WHEN 'MATERIAL'.
          gs_range-material = VALUE #( BASE gs_range-material ( LINES OF <fs_filters>-range ) ).

        WHEN 'VALUATIONAREA'.
          gs_range-valuationarea = VALUE #( BASE gs_range-valuationarea ( LINES OF <fs_filters>-range ) ).

        WHEN 'VALUATIONTYPE'.
          gs_range-valuationtype = VALUE #( BASE gs_range-valuationtype ( LINES OF <fs_filters>-range ) ).

        WHEN 'CFOP'.
          gs_range-cfop = VALUE #( BASE gs_range-cfop ( LINES OF <fs_filters>-range ) ).

        WHEN 'BUKRS'.
          gs_range-bukrs = VALUE #( BASE gs_range-bukrs ( LINES OF <fs_filters>-range ) ).

        WHEN 'VKORG'.
          gs_range-vkorg = VALUE #( BASE gs_range-vkorg ( LINES OF <fs_filters>-range ) ).

        WHEN 'VTWEG'.
          gs_range-vtweg = VALUE #( BASE gs_range-vtweg ( LINES OF <fs_filters>-range ) ).

        WHEN 'SPART'.
          gs_range-spart = VALUE #( BASE gs_range-spart ( LINES OF <fs_filters>-range ) ).

        WHEN 'TXJCD'.
          gs_range-txjcd = VALUE #( BASE gs_range-txjcd ( LINES OF <fs_filters>-range ) ).

        WHEN 'PARID'.
          gs_range-parid = VALUE #( BASE gs_range-parid ( LINES OF <fs_filters>-range ) ).

        WHEN 'PRINTD'.
          gs_range-printd = VALUE #( BASE gs_range-printd ( LINES OF <fs_filters>-range ) ).

        WHEN 'TPDOC'.
          gs_range-tpdoc = VALUE #( BASE gs_range-tpdoc ( LINES OF <fs_filters>-range ) ).

        WHEN 'TPNF'.
          gs_range-tpnf = VALUE #( BASE gs_range-tpnf ( LINES OF <fs_filters>-range ) ).

        WHEN 'BASEUNIT'.
          gs_range-baseunit = VALUE #( BASE gs_range-baseunit ( LINES OF <fs_filters>-range ) ).

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.

    ENDLOOP.

    IF gs_range-cfop[] IS NOT INITIAL.
      SORT gs_range-cfop BY low.
      DELETE ADJACENT DUPLICATES FROM gs_range-cfop COMPARING low.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
