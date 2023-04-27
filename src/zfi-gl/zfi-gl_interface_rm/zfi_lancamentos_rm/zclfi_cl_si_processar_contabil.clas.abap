CLASS zclfi_cl_si_processar_contabil DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zclfi_ii_si_processar_contabil .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zclfi_cl_si_processar_contabil IMPLEMENTATION.


  METHOD zclfi_ii_si_processar_contabil~si_processar_contabil_lancamen.

    TRY.

        NEW zclfi_lancamento_contabil( )->get_data(
            EXPORTING
                is_input = input
        ).

      CATCH zclfi_cx_lancamento_contabil INTO DATA(lo_erro).

        DATA(ls_erro) = VALUE zclfi_exchange_fault_data( fault_text = lo_erro->get_text( ) ).

        RAISE EXCEPTION TYPE zclfi_cx_fmt_contabi_lancament
          EXPORTING
            standard = ls_erro.

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
