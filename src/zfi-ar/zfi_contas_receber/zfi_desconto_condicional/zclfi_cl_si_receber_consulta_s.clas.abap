CLASS zclfi_cl_si_receber_consulta_s DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zclfi_ii_si_receber_consulta_s .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_cl_si_receber_consulta_s IMPLEMENTATION.
  METHOD zclfi_ii_si_receber_consulta_s~si_receber_consulta_status_par.
    TRY.
        NEW zclfi_interface_cons_statu_pdc( )->consulta_status_parcelas(
            EXPORTING
                is_input = input
            IMPORTING
             es_output = output
        ).

      CATCH zcxca_erro_interface INTO DATA(lo_erro).

        DATA(ls_erro) = VALUE zclfi_exchange_fault_data( fault_text = lo_erro->get_text( ) ).

        RAISE EXCEPTION TYPE zclfi_cx_fmt_consulta_status_p
          EXPORTING
            standard = ls_erro.

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
