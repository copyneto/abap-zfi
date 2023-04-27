CLASS zclfi_cl_si_recebe_consulta_pr DEFINITION
  PUBLIC
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES zclfi_ii_si_recebe_consulta_pr .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zclfi_cl_si_recebe_consulta_pr IMPLEMENTATION.
  METHOD zclfi_ii_si_recebe_consulta_pr~si_recebe_consulta_proposta_in.
    TRY.
        NEW zclfi_interface_cons_proposta( )->executar(
            EXPORTING
                is_input = input
            IMPORTING
             es_output = output
        ).

      CATCH zcxca_erro_interface INTO DATA(lo_erro).

        DATA(ls_erro) = VALUE zclfi_exchange_fault_data( fault_text = lo_erro->get_text( ) ).

        RAISE EXCEPTION TYPE zclfi_cx_fmt_consulta_proposta
          EXPORTING
            standard = ls_erro.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
