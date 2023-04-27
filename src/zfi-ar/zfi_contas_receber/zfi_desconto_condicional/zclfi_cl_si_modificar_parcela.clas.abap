CLASS zclfi_cl_si_modificar_parcela DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zclfi_ii_si_modificar_parcela .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zclfi_cl_si_modificar_parcela IMPLEMENTATION.
  METHOD zclfi_ii_si_modificar_parcela~si_modificar_parcela_agendamen.
    TRY.
        NEW zclfi_interface_mod_agend_parc( )->processar(
            EXPORTING
                is_input = input
            IMPORTING
             es_output = output
        ).

      CATCH zcxca_erro_interface INTO DATA(lo_erro).

        DATA(ls_erro) = VALUE zclfi_exchange_fault_data( fault_text = lo_erro->get_text( ) ).

        RAISE EXCEPTION TYPE zclfi_cx_fmt_parcela_agendamen
          EXPORTING
            standard = ls_erro.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
