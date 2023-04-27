CLASS zclfi_dias_atraso DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
    INTERFACES if_rap_query_filter .

    TYPES:
      BEGIN OF ty_filters, " Tipo para ranges
        kunnr    TYPE if_rap_query_filter=>tt_range_option,
        belnr    TYPE if_rap_query_filter=>tt_range_option,
        buzei    TYPE if_rap_query_filter=>tt_range_option,
        gjahr    TYPE if_rap_query_filter=>tt_range_option,
        name1    TYPE if_rap_query_filter=>tt_range_option,
        bldat    TYPE if_rap_query_filter=>tt_range_option,
        bschl    TYPE if_rap_query_filter=>tt_range_option,
        blart    TYPE if_rap_query_filter=>tt_range_option,
        anfbn    TYPE if_rap_query_filter=>tt_range_option,
        zuonr    TYPE if_rap_query_filter=>tt_range_option,
        rebzg    TYPE if_rap_query_filter=>tt_range_option,
        dmbtr    TYPE if_rap_query_filter=>tt_range_option,
        xblnr    TYPE if_rap_query_filter=>tt_range_option,
        wrbtr    TYPE if_rap_query_filter=>tt_range_option,
        bukrs    TYPE if_rap_query_filter=>tt_range_option,
        hbkid    TYPE if_rap_query_filter=>tt_range_option,
        zlsch    TYPE if_rap_query_filter=>tt_range_option,
        waers    TYPE if_rap_query_filter=>tt_range_option,
        zfbdt    TYPE if_rap_query_filter=>tt_range_option,
        zbd1t    TYPE if_rap_query_filter=>tt_range_option,
        zbd2t    TYPE if_rap_query_filter=>tt_range_option,
        zbd3t    TYPE if_rap_query_filter=>tt_range_option,
        diasAtra TYPE if_rap_query_filter=>tt_range_option,
      END OF ty_filters .

    DATA gs_range TYPE ty_filters .

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS: gc_koart  TYPE koart VALUE 'D'.

    TYPES: ty_relat TYPE STANDARD TABLE OF zc_fi_canc_cli WITH EMPTY KEY.

    DATA: gt_fi_canc_cli TYPE ty_relat.

    METHODS:
      "! Verificar autorização para registros selecionados
      "! @parameter ct_relat |Lista de registros após verificação de autorização
      check_authorizations
        CHANGING
          ct_relat TYPE ty_relat,

      set_filters
        IMPORTING
          it_filters TYPE if_rap_query_filter=>tt_name_range_pairs,

      build
        EXPORTING
          et_relat TYPE ty_relat ,
      get_days
        CHANGING
          ct_canc_cli TYPE ty_relat.

ENDCLASS.



CLASS zclfi_dias_atraso IMPLEMENTATION.

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
        me->set_filters( EXPORTING it_filters = io_request->get_filter( )->get_as_ranges( ) ). "#EC CI_CONV_OK
      CATCH cx_rap_query_filter_no_range INTO DATA(lo_ex_filter).
        lv_exp_msg = lo_ex_filter->get_longtext( ).
    ENDTRY.

* ---------------------------------------------------------------------------
* Monta relatório
* ---------------------------------------------------------------------------
    DATA lt_result TYPE STANDARD TABLE OF zc_fi_canc_cli WITH EMPTY KEY.
    me->build( IMPORTING et_relat = lt_result ).

* ---------------------------------------------------------------------------
* Verifica objetos de autorização p/ seleção
* ---------------------------------------------------------------------------
    me->check_authorizations(  CHANGING ct_relat = lt_result ).

* ---------------------------------------------------------------------------
* Realiza ordenação de acordo com parâmetros de entrada
* ---------------------------------------------------------------------------
    DATA(lt_requested_sort) = io_request->get_sort_elements( ).
    IF lines( lt_requested_sort ) > 0.
      DATA(lt_sort) = VALUE abap_sortorder_tab( FOR ls_sort IN lt_requested_sort ( name = ls_sort-element_name descending = ls_sort-descending ) ).
      SORT lt_result BY (lt_sort).
    ENDIF.

** ---------------------------------------------------------------------------
** Realiza as agregações de acordo com as annotatios na custom entity
** ---------------------------------------------------------------------------
    DATA(lt_req_elements) = io_request->get_requested_elements( ).

    DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).
    IF lt_aggr_element IS NOT INITIAL.
      LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<fs_aggr_element>).
        DELETE lt_req_elements WHERE table_line = <fs_aggr_element>-result_element. "#EC CI_STDSEQ
        DATA(lv_aggregation) = |{ <fs_aggr_element>-aggregation_method }( { <fs_aggr_element>-input_element } ) as { <fs_aggr_element>-result_element }|.
        APPEND lv_aggregation TO lt_req_elements.
      ENDLOOP.
    ENDIF.

    DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = ',' ).

    DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
    DATA(lv_grouping) = concat_lines_of(  table = lt_grouped_element sep = ',' ).

    SELECT (lv_req_elements) FROM @lt_result AS dados
                             GROUP BY (lv_grouping)
                             INTO CORRESPONDING FIELDS OF TABLE @lt_result.

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

    TRY.
        gs_range-kunnr = it_filters[ name = 'KUNNR' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO DATA(lo_root).
        DATA(lv_exp_msg) = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-belnr = it_filters[ name = 'BELNR' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-buzei = it_filters[ name = 'BUZEI' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-gjahr = it_filters[ name = 'GJAHR' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-name1 = it_filters[ name = 'NAME1' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-bldat = it_filters[ name = 'BLDAT' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-bschl = it_filters[ name = 'BSCHL' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-blart = it_filters[ name = 'BLART' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-anfbn = it_filters[ name = 'ANFBN' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-zuonr = it_filters[ name = 'ZUONR' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-rebzg = it_filters[ name = 'REBZG' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-dmbtr = it_filters[ name = 'DMBTR' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-xblnr = it_filters[ name = 'XBLNR' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-wrbtr = it_filters[ name = 'WRBTR' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-bukrs = it_filters[ name = 'BUKRS' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-hbkid = it_filters[ name = 'HBKID' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-zlsch = it_filters[ name = 'ZLSCH' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-waers = it_filters[ name = 'WAERS' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-zfbdt = it_filters[ name = 'ZFBDT' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-zbd1t = it_filters[ name = 'ZBD1T' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-zbd2t = it_filters[ name = 'ZBD2T' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-zbd3t = it_filters[ name = 'ZBD3T' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

    TRY.
        gs_range-diasatra = it_filters[ name = 'DIASATRA' ]-range. "#EC CI_STDSEQ
      CATCH cx_root INTO lo_root.
        lv_exp_msg = lo_root->get_longtext( ).
    ENDTRY.

  ENDMETHOD.

  METHOD build.

    SELECT * FROM zi_fi_canc_cli
    WHERE   kunnr    IN @gs_range-kunnr  AND
            belnr    IN @gs_range-belnr  AND
            buzei    IN @gs_range-buzei  AND
            gjahr    IN @gs_range-gjahr  AND
            name1    IN @gs_range-name1  AND
            bldat    IN @gs_range-bldat  AND
            bschl    IN @gs_range-bschl  AND
            blart    IN @gs_range-blart  AND
            anfbn    IN @gs_range-anfbn  AND
            zuonr    IN @gs_range-zuonr  AND
            rebzg    IN @gs_range-rebzg  AND
            dmbtr    IN @gs_range-dmbtr  AND
            xblnr    IN @gs_range-xblnr  AND
            wrbtr    IN @gs_range-wrbtr  AND
            bukrs    IN @gs_range-bukrs  AND
            hbkid    IN @gs_range-hbkid  AND
            zlsch    IN @gs_range-zlsch  AND
            waers    IN @gs_range-waers  AND
            zfbdt    IN @gs_range-zfbdt  AND
            zbd1t    IN @gs_range-zbd1t  AND
            zbd2t    IN @gs_range-zbd2t  AND
            zbd3t    IN @gs_range-zbd3t
    INTO CORRESPONDING FIELDS OF TABLE @et_relat.

    IF sy-subrc EQ 0.

      me->get_days(
        CHANGING
            ct_canc_cli = et_relat ).

      IF gs_range-diasatra IS NOT INITIAL.

        SELECT * FROM @et_relat AS result
        WHERE diasAtra IN @gs_range-diasatra
                         INTO CORRESPONDING FIELDS OF TABLE @et_relat.

      ENDIF.

    ENDIF.


  ENDMETHOD.


  METHOD get_days.

    LOOP AT ct_canc_cli ASSIGNING FIELD-SYMBOL(<fs_result>).

      DATA(ls_item) = VALUE rfposxext( BASE CORRESPONDING #( <fs_result>
            MAPPING
              konto = kunnr
              dmshb = dmbtr
              wrshb = wrbtr
            )
            koart = gc_koart ).

      DATA(ls_t001) = VALUE t001( bukrs = <fs_result>-bukrs ).

      CALL FUNCTION 'ITEM_DERIVE_FIELDS'
        EXPORTING
          s_t001    = ls_t001
          key_date  = sy-datum
          xopvw     = abap_true
        CHANGING
          s_item    = ls_item
        EXCEPTIONS
          bad_input = 1
          OTHERS    = 2.

      IF sy-subrc EQ 0.

        <fs_result>-diasAtra = ls_item-verz1.

      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD check_authorizations.
    DATA lr_auth_bukrs TYPE if_rap_query_filter=>tt_range_option.
    CHECK ct_relat IS NOT INITIAL.

    SELECT bukrs
      FROM t001
      INTO @DATA(lv_bukrs).

      IF zclfi_auth_zfibukrs=>check_custom(
          iv_bukrs = lv_bukrs
          iv_actvt = zclfi_auth_zfibukrs=>gc_actvt-exibir
      ) = abap_true.

        APPEND VALUE #( sign = 'I' option = 'EQ' low = lv_bukrs ) TO lr_auth_bukrs.

      ENDIF.
    ENDSELECT.

    DELETE ct_relat WHERE bukrs NOT IN lr_auth_bukrs AND bukrs IS NOT INITIAL. "#EC CI_STDSEQ
  ENDMETHOD.

ENDCLASS.
