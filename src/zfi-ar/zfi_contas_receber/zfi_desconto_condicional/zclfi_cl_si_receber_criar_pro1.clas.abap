CLASS zclfi_cl_si_receber_criar_pro1 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zclfi_ii_si_receber_criar_pro1 .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCLFI_CL_SI_RECEBER_CRIAR_PRO1 IMPLEMENTATION.


  METHOD zclfi_ii_si_receber_criar_pro1~si_receber_criar_proposta_in_s.

    DATA: lt_erro TYPE zclfi_dt_criar_proposta_re_tab.

    TRY.
        NEW zclfi_interface_proc_proposta( )->executar(
            EXPORTING
                is_input = input
            IMPORTING
             es_output = output
        ).

      CATCH zcxca_erro_interface INTO DATA(lo_erro).

        DATA(ls_erro) = VALUE zclfi_exchange_fault_data( fault_text = lo_erro->get_text( ) ).

*        RAISE EXCEPTION TYPE zclfi_cx_fmt_criar_proposta
*          EXPORTING
*            standard = ls_erro.

        lt_erro = VALUE #( BASE lt_erro ( erro = ls_erro-fault_text ) ).

        output-mt_criar_proposta_resp-retorno_provisionamento_parcel[] = CORRESPONDING #( lt_erro[] ).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
