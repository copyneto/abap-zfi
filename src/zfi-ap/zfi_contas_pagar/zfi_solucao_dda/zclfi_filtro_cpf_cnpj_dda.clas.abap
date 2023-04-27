"!<p>Filtro de CNPJ e CPF no <strong>App Conciliação manual DDA</strong>. <br/>
"! Esta classe é utilizada na CDS view <em>ZC_FI_COCKPIT_DDA</em> <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato - Meta</p>
"!<p><strong>Data:</strong> 13/out/2021</p>
CLASS zclfi_filtro_cpf_cnpj_dda DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_filter_transform .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_filtro_cpf_cnpj_dda IMPLEMENTATION.
  METHOD if_sadl_exit_filter_transform~map_atom.

    IF iv_element <> 'CNPJFORMAT'.
      RETURN.
    ENDIF.

    DATA(lv_input_val) = iv_value.

    lv_input_val = replace( val   = lv_input_val
                            regex = '[^\d]'
                            with  = ' '
                            occ   = 0 ).

    DATA(lo_cfac) = cl_sadl_cond_prov_factory_pub=>create_simple_cond_factory( ).
    DATA(lo_filter) = lo_cfac->element( 'CNPJ' ).

    CASE iv_operator.

      WHEN if_sadl_exit_filter_transform~co_operator-equals.

        ro_condition = lo_filter->equals( lv_input_val ).

      WHEN if_sadl_exit_filter_transform~co_operator-less_than.

        ro_condition = lo_filter->less_than( lv_input_val ).

      WHEN if_sadl_exit_filter_transform~co_operator-greater_than.
        ro_condition = lo_filter->greater_than( lv_input_val ).

      WHEN if_sadl_exit_filter_transform~co_operator-is_null.
        ro_condition = lo_filter->is_null( ).

      WHEN if_sadl_exit_filter_transform~co_operator-covers_pattern.
        ro_condition = lo_filter->covers_pattern( lv_input_val ).

    ENDCASE.


  ENDMETHOD.

ENDCLASS.
