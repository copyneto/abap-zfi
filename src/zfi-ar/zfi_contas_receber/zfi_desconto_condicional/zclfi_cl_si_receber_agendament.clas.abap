CLASS zclfi_cl_si_receber_agendament DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zclfi_ii_si_receber_agendament .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLFI_CL_SI_RECEBER_AGENDAMENT IMPLEMENTATION.


  METHOD zclfi_ii_si_receber_agendament~si_receber_agendamento_parcela.
    TRY.
        NEW zclfi_interface_exec_lanc_desc( )->executar(
            EXPORTING
                is_input = input
            IMPORTING
             es_output = output
        ).

      CATCH zcxca_erro_interface INTO DATA(lo_erro).

        DATA(ls_erro) = VALUE zclfi_exchange_fault_data( fault_text = lo_erro->get_text( ) ).

        RAISE EXCEPTION TYPE zclfi_cx_fmt_agendamento_parce
          EXPORTING
            standard = ls_erro.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
