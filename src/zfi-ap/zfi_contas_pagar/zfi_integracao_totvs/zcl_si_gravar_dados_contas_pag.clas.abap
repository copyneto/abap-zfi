class ZCL_SI_GRAVAR_DADOS_CONTAS_PAG definition
  public
  create public .

public section.

  interfaces ZII_SI_GRAVAR_DADOS_CONTAS_PAG .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SI_GRAVAR_DADOS_CONTAS_PAG IMPLEMENTATION.


  METHOD zii_si_gravar_dados_contas_pag~si_gravar_dados_contas_pagar_r.

    TYPES: BEGIN OF ty_msg,
             msgv1 TYPE msgv1,
             msgv2 TYPE msgv2,
             msgv3 TYPE msgv3,
             msgv4 TYPE msgv4,
           END OF ty_msg.

    DATA: ls_msg TYPE ty_msg.
    TRY.
        NEW zclfi_totvs_doc_pagar( )->processa_interface_doc_pagar( is_input = input ).

      CATCH zcxfi_totvs_doc_pagar INTO DATA(lo_cx_totvs).

        CALL METHOD cl_proxy_fault=>raise
          EXPORTING
            exception_class_name = 'ZFI_CX_FMT_DADOS_CONTAS_PAGAR'
            bapireturn_tab       = lo_cx_totvs->get_bapiretreturn( ).

      CATCH cx_root INTO DATA(lo_cx_root).

        ls_msg = lo_cx_root->get_text( ).

        CALL METHOD cl_proxy_fault=>raise
          EXPORTING
            exception_class_name = 'ZFI_CX_FMT_DADOS_CONTAS_PAGAR'
            bapireturn_tab       = NEW zcxfi_totvs_doc_pagar(
                                                              iv_textid   = zcxfi_totvs_doc_pagar=>gc_cxfi_totvs_doc_pagar
                                                              iv_msgv1    = ls_msg-msgv1
                                                              iv_msgv2    = ls_msg-msgv2
                                                              iv_msgv3    = ls_msg-msgv3
                                                              iv_msgv4    = ls_msg-msgv4
                                                            )->get_bapiretreturn( ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
