CLASS zclfi_cl_si_consulta_pendencia DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zclfi_ii_si_consulta_pendencia .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_cl_si_consulta_pendencia IMPLEMENTATION.
  METHOD zclfi_ii_si_consulta_pendencia~si_consulta_pendencia_financei.
    TRY.
        NEW zclfi_interface_cons_pend_pdc( )->consulta_pendencia_financeira(
            EXPORTING
                is_input = input
            IMPORTING
             es_output = output
        ).

      CATCH zcxca_erro_interface INTO DATA(lo_erro).

        DATA(ls_erro) = VALUE zclfi_exchange_fault_data( fault_text = lo_erro->get_text( ) ).

        RAISE EXCEPTION TYPE zclfi_cx_fmt_consulta_pendenci
          EXPORTING
            standard = ls_erro.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
