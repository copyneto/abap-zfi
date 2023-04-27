CLASS zclfi_calc_date DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
    INTERFACES if_rap_query_filter .

  PROTECTED SECTION.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF gc_value,
                 moeda      TYPE string      VALUE 'Moeda',
                 kurst      TYPE kurst_curr  VALUE 'Z',
                 tcurr      TYPE tcurr_curr  VALUE 'USD',
                 men        TYPE string VALUE 'Falta taxa de câmbio para o período do relatório.',
                 men2       TYPE string VALUE 'Inserir a "Data do relatório" para fazer os calculos com a taxa de câmbio.',
                 order_fixo TYPE string VALUE 'anln1 ASCENDING',
                 descending TYPE string VALUE 'DESCENDING',
                 ascending  TYPE string VALUE 'ASCENDING',
               END OF gc_value.

    TYPES:
      "! Tipo para ranges
      BEGIN OF ty_filters,
        anln1         TYPE if_rap_query_filter=>tt_range_option,
        anln2         TYPE if_rap_query_filter=>tt_range_option,
        bukrs         TYPE if_rap_query_filter=>tt_range_option,
        afabe         TYPE if_rap_query_filter=>tt_range_option,
        aktiv         TYPE if_rap_query_filter=>tt_range_option,
        anlkl         TYPE if_rap_query_filter=>tt_range_option,
        bstdt         TYPE if_rap_query_filter=>tt_range_option,
        gsber         TYPE if_rap_query_filter=>tt_range_option,
        waers         TYPE if_rap_query_filter=>tt_range_option,
        kansw         TYPE if_rap_query_filter=>tt_range_option,
        knafa         TYPE if_rap_query_filter=>tt_range_option,
        vlContab      TYPE if_rap_query_filter=>tt_range_option,
        valorAq       TYPE if_rap_query_filter=>tt_range_option,
        Deprec        TYPE if_rap_query_filter=>tt_range_option,
        vlContab34    TYPE if_rap_query_filter=>tt_range_option,
        valorAqAjuste TYPE if_rap_query_filter=>tt_range_option,
        DeprecAcum    TYPE if_rap_query_filter=>tt_range_option,
        answl         TYPE if_rap_query_filter=>tt_range_option,
        nafag         TYPE if_rap_query_filter=>tt_range_option,
        zaqui         TYPE if_rap_query_filter=>tt_range_option,
        zdepr         TYPE  if_rap_query_filter=>tt_range_option,
        mensagem      TYPE  if_rap_query_filter=>tt_range_option,
      END OF ty_filters,

      ty_relat TYPE STANDARD TABLE OF zc_fi_query_imob  WITH EMPTY KEY.

    DATA:
        "! Estrutura com ranges
        gs_range TYPE ty_filters.

    METHODS:

      set_filters
        IMPORTING
          it_filters TYPE if_rap_query_filter=>tt_name_range_pairs,

      build
        CHANGING
          ct_relat TYPE ty_relat.
ENDCLASS.



CLASS ZCLFI_CALC_DATE IMPLEMENTATION.


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
    DATA(lv_top)       = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)      = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows)  = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

* ---------------------------------------------------------------------------
* Recupera e seta filtros de seleção
* ---------------------------------------------------------------------------
    TRY.
        me->set_filters( EXPORTING it_filters = io_request->get_filter( )->get_as_ranges( ) ).
      CATCH cx_rap_query_filter_no_range INTO DATA(lo_ex_filter).
        lv_exp_msg = lo_ex_filter->get_longtext( ).
    ENDTRY.


* ---------------------------------------------------------------------------
* Realiza ordenação de acordo com parâmetros de entrada
* ---------------------------------------------------------------------------
    DATA(lt_requested_sort) = io_request->get_sort_elements( ).

    IF lines( lt_requested_sort ) GT 0.

      DATA(lt_sort) = VALUE abap_sortorder_tab( FOR ls_sort IN lt_requested_sort ( name = ls_sort-element_name descending = ls_sort-descending ) ).
      IF lt_sort IS NOT INITIAL.

        DATA(lv_orderby_string) = COND #( WHEN lt_sort[ 1 ]-descending = abap_true THEN |{ lt_sort[ 1 ]-name }| & | | & |{ gc_value-descending }| ELSE |{ lt_sort[ 1 ]-name }| & | | & |{ gc_value-ascending }| ).

      ENDIF.

    ELSE.
      lv_orderby_string = gc_value-order_fixo.
    ENDIF.

* ---------------------------------------------------------------------------
* Monta relatório
* ---------------------------------------------------------------------------
    DATA lt_result TYPE STANDARD TABLE OF zc_fi_query_imob WITH EMPTY KEY.
    me->build( CHANGING ct_relat = lt_result ).

** ---------------------------------------------------------------------------
** Realiza as agregações de acordo com as annotatios na custom entity
** ---------------------------------------------------------------------------
    DATA(lt_req_elements) = io_request->get_requested_elements( ).

    DATA(lt_aggr_element) = io_request->get_aggregation( )->get_aggregated_elements( ).
    IF lt_aggr_element IS NOT INITIAL.
      LOOP AT lt_aggr_element ASSIGNING FIELD-SYMBOL(<fs_aggr_element>).
        DELETE lt_req_elements WHERE table_line = <fs_aggr_element>-result_element.
        DATA(lv_aggregation) = |{ <fs_aggr_element>-aggregation_method }( { <fs_aggr_element>-input_element } ) as { <fs_aggr_element>-result_element }|.
        APPEND lv_aggregation TO lt_req_elements.
      ENDLOOP.
    ENDIF.

    DATA(lv_req_elements)  = concat_lines_of( table = lt_req_elements sep = ',' ).

    DATA(lt_grouped_element) = io_request->get_aggregation( )->get_grouped_elements( ).
    DATA(lv_grouping) = concat_lines_of(  table = lt_grouped_element sep = ',' ).

    SELECT (lv_req_elements) FROM @lt_result AS dados
                             GROUP BY (lv_grouping)
                             ORDER BY (lv_orderby_string) " Obs
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

    IF it_filters IS NOT INITIAL.

      TRY.
          gs_range-anln1   = it_filters[ name = 'ANLN1' ]-range.
        CATCH cx_root INTO DATA(lo_root).
          DATA(lv_exp_msg) = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-anln2   = it_filters[ name = 'ANLN2' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-bukrs   = it_filters[ name = 'BUKRS' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-afabe   = it_filters[ name = 'AFABE' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-aktiv   = it_filters[ name = 'AKTIV' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-anlkl   = it_filters[ name = 'ANLKL' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-gsber   = it_filters[ name = 'GSBER' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-waers   = it_filters[ name = 'WAERS' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-kansw   = it_filters[ name = 'KANSW' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-knafa   = it_filters[ name = 'KNAFA' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-vlcontab   = it_filters[ name = 'VLCONTAB' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-valoraq   = it_filters[ name = 'VALORAQ' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-deprec   = it_filters[ name = 'DEPREC' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-vlcontab34   = it_filters[ name = 'VLCONTAB34' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-valoraqajuste   = it_filters[ name = 'VALORAQAJUSTE' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-deprecacum   = it_filters[ name = 'DEPRECACUM' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-zaqui   = it_filters[ name = 'ZAQUI' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-zdepr   = it_filters[ name = 'ZDEPR' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          gs_range-mensagem   = it_filters[ name = 'MENSAGEM' ]-range.
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

    ENDIF.

  ENDMETHOD.


  METHOD build.

    DATA lt_gjahr TYPE if_rap_query_filter=>tt_range_option.
    DATA:   lv_gdatu TYPE gdatu_inv.

    IF gs_range-aktiv[ 1 ]-low IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = gs_range-aktiv[ 1 ]-low(4) ) TO lt_gjahr.
    ENDIF.
    IF gs_range-aktiv[ 1 ]-high IS NOT INITIAL.
      APPEND VALUE #( sign = 'I' option = 'EQ' low = gs_range-aktiv[ 1 ]-high(4) ) TO lt_gjahr.
    ENDIF.

    SORT lt_gjahr BY option sign low high. DELETE ADJACENT DUPLICATES FROM lt_gjahr COMPARING option sign low high.

    SELECT anln1,
            anln2,
            bukrs,
            gjahr,
            afabe,
            aktiv,
            anlkl,
            bstdt,
            gsber,
            waers,
            kansw,
            knafa,
            answl,
            nafag,
            zaqui,
            zdepr,
            moeda,
            answl34,
            nafag34,
            kansw34,
            knafa34,
            vlcontab,
            ukurs,
            valoraq,
            deprec,
            vlcontab34,
            valoraqajuste,
            deprecacum,
            mensagem
       FROM zi_fi_imob_sum
        WHERE   anln1         IN @gs_range-anln1 AND
                anln2         IN @gs_range-anln2 AND
                bukrs         IN @gs_range-bukrs AND
                afabe         IN @gs_range-afabe AND
                aktiv         IN @gs_range-aktiv AND
                anlkl         IN @gs_range-anlkl AND
                bstdt         IN @gs_range-bstdt AND
                gsber         IN @gs_range-gsber AND
                waers         IN @gs_range-waers AND
                kansw         IN @gs_range-kansw AND
                knafa         IN @gs_range-knafa AND
                vlcontab      IN @gs_range-vlcontab AND
                valoraq       IN @gs_range-valoraq  AND
                deprec        IN @gs_range-deprec AND
                vlcontab34    IN @gs_range-vlcontab34 AND
                valoraqajuste IN @gs_range-valoraqajuste AND
                deprecacum    IN @gs_range-deprecacum AND
                answl         IN @gs_range-answl AND
                nafag         IN @gs_range-nafag AND
                zaqui         IN @gs_range-zaqui AND
                zdepr         IN @gs_range-zdepr AND
                mensagem      IN @gs_range-mensagem AND
                gjahr         IN @lt_gjahr
         INTO TABLE @DATA(lt_resul).

    IF sy-subrc EQ 0.

      TYPES: BEGIN OF ty_tcurr_key,
           kurst type tcurr-kurst,
           fcurr type tcurr-fcurr,
           tcurr type tcurr-tcurr,
      end OF ty_tcurr_key.

      data: lt_tcurr_key TYPE TABLE of ty_tcurr_key.

      lt_tcurr_key = value #( for ls_resul in lt_resul ( kurst = gc_value-kurst
                                                         fcurr = ls_resul-moeda
                                                         tcurr = gc_value-tcurr ) ).

      SORT lt_tcurr_key by kurst fcurr tcurr.
      delete ADJACENT DUPLICATES FROM lt_tcurr_key COMPARING kurst fcurr tcurr.

      SELECT kurst, fcurr, tcurr, ukurs, gdatu FROM tcurr
      FOR ALL ENTRIES IN @lt_tcurr_key
        WHERE kurst = @lt_tcurr_key-kurst
          AND fcurr = @lt_tcurr_key-fcurr
          AND tcurr = @lt_tcurr_key-tcurr
          INTO TABLE @DATA(lt_tcurr).

      CHECK sy-subrc EQ 0.

        SORT lt_tcurr BY kurst fcurr tcurr gdatu ASCENDING.
         data(lt_tcurr_sort) = lt_tcurr.


        DATA(lv_data) = VALUE #( gs_range-aktiv[ 1 ]-high OPTIONAL ).

        IF lv_data IS NOT INITIAL.

          CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
            EXPORTING
              input  = lv_data+6(2) && lv_data+4(2) && lv_data(4)
            IMPORTING
              output = lv_gdatu.

          IF lv_gdatu IS NOT INITIAL.

            DELETE lt_tcurr_sort WHERE gdatu LE lv_gdatu.

          ENDIF.

        ENDIF.

        data(lt_resul_aux) = lt_resul.

        LOOP AT lt_resul_aux ASSIGNING FIELD-SYMBOL(<fs_data>).

          DATA(lv_tabix) = sy-tabix.
          DATA(lv_bukrs) =  <fs_data>-bukrs.

          <fs_data>-answl = <fs_data>-answl + <fs_data>-kansw.
          <fs_data>-nafag = <fs_data>-nafag + <fs_data>-knafa.


          IF zclfi_auth_zfibukrs=>check_custom(
            iv_bukrs = lv_bukrs
            iv_actvt = zclfi_auth_zfibukrs=>gc_actvt-exibir
            ) = abap_false.

            DELETE lt_resul_aux INDEX lv_tabix.
            CONTINUE.
          ENDIF.

          IF lv_data IS NOT INITIAL.

            <fs_data>-ukurs = VALUE #( lt_tcurr_sort[ kurst = gc_value-kurst
                                                 fcurr = <fs_data>-moeda
                                                 tcurr = gc_value-tcurr ]-ukurs OPTIONAL ) .

            IF <fs_data>-ukurs IS NOT INITIAL.

              <fs_data>-valoraq       =  ( <fs_data>-answl34 + <fs_data>-kansw34 ) * <fs_data>-ukurs.
              <fs_data>-deprec        =  (  <fs_data>-nafag34 + <fs_data>-knafa34 ) * <fs_data>-ukurs.
              <fs_data>-vlcontab34    = ( <fs_data>-answl34 * <fs_data>-ukurs ) + (  <fs_data>-nafag34 * <fs_data>-ukurs ).
              <fs_data>-valoraqajuste = <fs_data>-valoraq -    <fs_data>-answl.
              <fs_data>-deprecacum    = <fs_data>-deprec -    <fs_data>-nafag.

            ELSE.
              <fs_data>-mensagem = gc_value-men.
            ENDIF.

          ELSE.
            <fs_data>-mensagem = gc_value-men2.
          ENDIF.

        ENDLOOP.

      ENDIF.

      ct_relat = CORRESPONDING #( lt_resul_aux ).


  ENDMETHOD.
ENDCLASS.
