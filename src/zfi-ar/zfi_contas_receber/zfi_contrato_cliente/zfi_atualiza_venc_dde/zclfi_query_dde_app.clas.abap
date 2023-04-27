CLASS zclfi_query_dde_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      "! Configura os filtros que serão utilizados no relatório
      "! @parameter it_filters | Filtros do Aplicativo
      set_filters
        IMPORTING
          it_filters  TYPE if_rap_query_filter=>tt_name_range_pairs
          io_instance TYPE REF TO zclfi_venc_dde_data.

ENDCLASS.



CLASS zclfi_query_dde_app IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    "Cria instancia
    DATA(lo_venc_dde) = zclfi_venc_dde_data=>get_instance( ).
* ---------------------------------------------------------------------------
* Recupera informações de entidade, paginação, etc
* ---------------------------------------------------------------------------
    DATA(lv_top)       = io_request->get_paging( )->get_page_size( ).
    DATA(lv_skip)      = io_request->get_paging( )->get_offset( ).
    DATA(lv_max_rows)  = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).
** ---------------------------------------------------------------------------
** Recupera e seta filtros de seleção
** ---------------------------------------------------------------------------
    TRY.
        me->set_filters( EXPORTING it_filters = io_request->get_filter( )->get_as_ranges( ) io_instance = lo_venc_dde ). "#EC CI_CONV_OK
      CATCH cx_rap_query_filter_no_range INTO DATA(lo_ex_filter).
        DATA(lv_exp_msg) = lo_ex_filter->get_longtext( ).
    ENDTRY.

** ---------------------------------------------------------------------------
** Monta relatório
** ---------------------------------------------------------------------------
    DATA(lt_result) = lo_venc_dde->build(  ).
** ---------------------------------------------------------------------------
** Realiza ordenação de acordo com parâmetros de entrada
** ---------------------------------------------------------------------------
    DATA(lt_requested_sort) = io_request->get_sort_elements( ).
    IF lines( lt_requested_sort ) > 0.
      DATA(lt_sort) = VALUE abap_sortorder_tab( FOR ls_sort IN lt_requested_sort ( name = ls_sort-element_name descending = ls_sort-descending ) ).
      SORT lt_result BY (lt_sort).
    ENDIF.

*    DATA(lt_teste) = lt_result[].
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
    lt_result_page = VALUE #( FOR ls_result_aux IN lt_result FROM ( lv_skip + 1 ) TO ( lv_skip + lv_max_rows ) ( ls_result_aux ) ).
* ---------------------------------------------------------------------------
* Monta o total de registros
* ---------------------------------------------------------------------------
    IF io_request->is_total_numb_of_rec_requested(  ).
      io_response->set_total_number_of_records( CONV #( lines( lt_result[] ) ) ).
    ENDIF.
* ---------------------------------------------------------------------------
* Verifica se informação foi solicitada e exibe registros
* ---------------------------------------------------------------------------
    TRY.
        CHECK io_request->is_data_requested( ).
        io_response->set_data( lt_result_page[] ).
      CATCH cx_rfc_dest_provider_error  INTO DATA(lo_ex_dest).
        lv_exp_msg = lo_ex_dest->get_longtext( ).
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD set_filters.

    DATA ls_param TYPE zsfi_filtros_dde.

    IF it_filters IS NOT INITIAL.

      TRY.
          ls_param-bukrs = CORRESPONDING #( it_filters[ name = 'BUKRS' ]-range ). "#EC CI_STDSEQ
        CATCH cx_root INTO DATA(lo_root).
          DATA(lv_exp_msg) = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          ls_param-belnr   = CORRESPONDING #( it_filters[ name = 'BELNR' ]-range ). "#EC CI_STDSEQ
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.


      TRY.
          ls_param-gjahr  =  CORRESPONDING #(  it_filters[ name = 'GJAHR' ]-range ). "#EC CI_STDSEQ
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          ls_param-kunnr   = CORRESPONDING #( it_filters[ name = 'KUNNR' ]-range ). "#EC CI_STDSEQ
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          ls_param-vbeln   = CORRESPONDING #( it_filters[ name = 'VBELN' ]-range ). "#EC CI_STDSEQ
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.
          ls_param-vgbel   = CORRESPONDING #( it_filters[ name = 'VGBEL' ]-range ). "#EC CI_STDSEQ
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.

          ls_param-dataentrega   = CORRESPONDING #( it_filters[ name = 'DATAENTREGA' ]-range ). "#EC CI_STDSEQ
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.

      TRY.

          ls_param-bschl   = CORRESPONDING #( it_filters[ name = 'BSCHL' ]-range ). "#EC CI_STDSEQ
        CATCH cx_root INTO lo_root.
          lv_exp_msg = lo_root->get_longtext( ).
      ENDTRY.


      "Export referencias
      GET REFERENCE OF: ls_param-bukrs[]     INTO io_instance->gr_bukrs.
      GET REFERENCE OF: ls_param-belnr[]     INTO io_instance->gr_belnr.
      GET REFERENCE OF: ls_param-gjahr[]     INTO io_instance->gr_gjahr.
      GET REFERENCE OF: ls_param-kunnr[]     INTO io_instance->gr_kunnr.
      GET REFERENCE OF: ls_param-vbeln[]     INTO io_instance->gr_vbeln.
      GET REFERENCE OF: ls_param-vgbel[]     INTO io_instance->gr_vgbel.
      GET REFERENCE OF: ls_param-dataentrega INTO io_instance->gr_dataentrega.
      GET REFERENCE OF: ls_param-bschl       INTO io_instance->gr_bschl.

      io_instance->set_ref_data(  ).
    ENDIF.

  ENDMETHOD.


ENDCLASS.
