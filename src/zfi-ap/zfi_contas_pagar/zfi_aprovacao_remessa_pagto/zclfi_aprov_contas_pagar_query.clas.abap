"! <p>Log Dados Mestre de Materiais</p>
CLASS zclfi_aprov_contas_pagar_query DEFINITION PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_rap_query_provider.


  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      "! Lista de filtros range da tela
      gt_filtro_ranges  TYPE if_rap_query_filter=>tt_name_range_pairs.

    METHODS buscar_range_filtro
      IMPORTING
        iv_name           TYPE string
      RETURNING
        VALUE(rt_retorno) TYPE if_rap_query_filter=>tt_range_option.

ENDCLASS.



CLASS zclfi_aprov_contas_pagar_query IMPLEMENTATION.

  METHOD if_rap_query_provider~select.

    TRY.
        IF io_request->is_data_requested( ).
          DATA(lv_entity_id) = io_request->get_entity_id( ).

          DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
          DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).
          DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0 ELSE lv_top ).

          CASE lv_entity_id.
            WHEN 'ZC_FI_APROV_CONTAS_PAGAR'.
              TRY.
                  gt_filtro_ranges = io_request->get_filter( )->get_as_ranges( ).
                  SORT gt_filtro_ranges BY name.
                CATCH cx_rap_query_filter_no_range.
                  RETURN.
              ENDTRY.

*              DATA(lt_aprov_contas_pagar_x) = NEW zclfi_aprov_contas_pagar_util( )->get_contas_pagar( gt_filtro_ranges ).
              DATA(lt_aprov_contas_pagar) = NEW zclfi_aprov_contas_pagar_util( )->get_contas_pagar_2( gt_filtro_ranges ).

              DATA(lt_sortorder) = CORRESPONDING abap_sortorder_tab( io_request->get_sort_elements( ) MAPPING name = element_name ).
              SORT lt_aprov_contas_pagar BY (lt_sortorder).

              io_response->set_total_number_of_records( lines( lt_aprov_contas_pagar ) ).
              io_response->set_data( lt_aprov_contas_pagar  ).

            WHEN 'ZC_FI_APROV_DOC_PGTO'.
              TRY.
*                  gt_filtro_ranges = io_request->get_filter( )->get_as_ranges( ).

                  DATA(lt_filter) = VALUE rsds_twhere( ).

                  SPLIT io_request->get_filter( )->get_as_sql_string( ) AT 'AND' INTO TABLE DATA(lt_where).

                  LOOP AT lt_where ASSIGNING FIELD-SYMBOL(<fs_where>).

                    REPLACE '(' IN <fs_where> WITH ''.
                    REPLACE ')' IN <fs_where> WITH ''.
                    CONDENSE <fs_where>.

                    APPEND INITIAL LINE TO lt_filter ASSIGNING FIELD-SYMBOL(<fs_filter>).
                    APPEND <fs_where> TO <fs_filter>-where_tab.

                  ENDLOOP.

                  DATA(lt_range) = VALUE rsds_trange( ).

                  CALL FUNCTION 'FREE_SELECTIONS_WHERE_2_RANGE'
                    EXPORTING
                      where_clauses            = lt_filter
                    IMPORTING
                      field_ranges             = lt_range
                    EXCEPTIONS
                      expression_not_supported = 1
                      incorrect_expression     = 2
                      OTHERS                   = 3."#EC CI_SUBRC

                  IF sy-subrc <> 0.
*                   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
                  ENDIF.

                  gt_filtro_ranges = VALUE #( BASE gt_filtro_ranges FOR ls_range IN lt_range[ 1 ]-frange_t ( name = ls_range-fieldname range = CORRESPONDING #( ls_range-selopt_t ) ) ).

                  SORT gt_filtro_ranges BY name.

                CATCH cx_rap_query_filter_no_range.
                  RETURN.
              ENDTRY.

*              DATA(lv_filter) = io_request->get_filter( )->get_as_sql_string( ).
*              DATA(lt_aprov_doc_pgto) = NEW zclfi_aprov_contas_pagar_util( )->get_doc_pgto( lv_filter ).
*              DATA(lt_aprov_doc_pgto) = NEW zclfi_aprov_contas_pagar_util( )->get_doc_pgto( gt_filtro_ranges ).
              DATA(lt_aprov_doc_pgto) = NEW zclfi_aprov_contas_pagar_util( )->get_doc_pgto2( gt_filtro_ranges ).
              io_response->set_total_number_of_records( lines( lt_aprov_doc_pgto ) ).
              io_response->set_data( lt_aprov_doc_pgto  ).

          ENDCASE.

        ENDIF.
      CATCH cx_rfc_dest_provider_error  INTO DATA(lv_dest).

    ENDTRY.
  ENDMETHOD.

  METHOD buscar_range_filtro.
    READ TABLE gt_filtro_ranges ASSIGNING FIELD-SYMBOL(<fs_filtro_ranges>) WITH KEY name = iv_name BINARY SEARCH.
    IF sy-subrc = 0.
      rt_retorno = <fs_filtro_ranges>-range.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
