*&---------------------------------------------------------------------*
*& Include zfii_exec_reversao_imp
*&---------------------------------------------------------------------*

CLASS lcl_report IMPLEMENTATION.

  METHOD display_report.

    DATA: lo_salv TYPE REF TO cl_salv_table.

    TRY.

        DATA(lt_data) = it_data.

        CALL METHOD cl_salv_table=>factory
          EXPORTING
            list_display = if_salv_c_bool_sap=>true
          IMPORTING
            r_salv_table = lo_salv
          CHANGING
            t_table      = lt_data.

        lo_salv->get_functions(  )->set_all( abap_true ).
        lo_salv->get_columns(  )->set_optimize( abap_true ).
        lo_salv->display(  ).

      CATCH cx_salv_msg.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
