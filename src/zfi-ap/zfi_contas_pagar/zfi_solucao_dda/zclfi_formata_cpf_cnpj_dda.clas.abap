"!<p>Formatação de CNPJ e CPF no <strong>App de Conciliação manual DDA</strong>. <br/>
"! Esta classe é utilizada na CDS view <em>ZC_FI_COCKPIT_DDA e ZC_FI_CONCILIACAO_MANUAL_DDA</em> <br/> <br/>
"!<p><strong>Autor:</strong> Anderson Miazato - Meta</p>
"!<p><strong>Data:</strong> 13/out/2021</p>
CLASS zclfi_formata_cpf_cnpj_dda DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_formata_cpf_cnpj_dda IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA: lt_calculated_data TYPE STANDARD TABLE OF zi_fi_cockpit_dda WITH DEFAULT KEY.
    DATA: lv_cnpj TYPE char18,
          lv_cpf  TYPE char14.

    IF it_original_data IS INITIAL.
      RETURN.
    ENDIF.

    MOVE-CORRESPONDING it_original_data TO lt_calculated_data.

    LOOP AT lt_calculated_data ASSIGNING FIELD-SYMBOL(<fs_calc_data>).

      IF <fs_calc_data>-Cnpj IS NOT INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_CGCBR_OUTPUT'
          EXPORTING
            input  = <fs_calc_data>-Cnpj
          IMPORTING
            output = lv_cnpj.

        <fs_calc_data>-CNPJFormat = lv_cnpj.

      ENDIF.


      IF <fs_calc_data>-SupplierCNPJ IS NOT INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_CGCBR_OUTPUT'
          EXPORTING
            input  = <fs_calc_data>-SupplierCNPJ
          IMPORTING
            output = lv_cnpj.

        <fs_calc_data>-SupplierCNPJFormat = lv_cnpj.

      ENDIF.

      IF <fs_calc_data>-SupplierCpf IS NOT INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_CPFBR_OUTPUT'
          EXPORTING
            input  = <fs_calc_data>-SupplierCpf
          IMPORTING
            output = lv_cpf.

        <fs_calc_data>-SupplierCPFFormat = lv_cpf.

      ENDIF.

    ENDLOOP.

    MOVE-CORRESPONDING lt_calculated_data TO ct_calculated_data.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF line_exists( it_requested_calc_elements[ table_line = 'CNPJFORMAT' ] ).
      APPEND 'CNPJ' TO et_requested_orig_elements.
    ENDIF.

    IF line_exists( it_requested_calc_elements[ table_line = 'SUPPLIERCNPJFORMAT' ] ).
      APPEND 'SUPPLIERCNPJ' TO et_requested_orig_elements.
    ENDIF.

    IF line_exists( it_requested_calc_elements[ table_line = 'SUPPLIERCPFFORMAT' ] ).
      APPEND 'SUPPLIERCPF' TO et_requested_orig_elements.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
