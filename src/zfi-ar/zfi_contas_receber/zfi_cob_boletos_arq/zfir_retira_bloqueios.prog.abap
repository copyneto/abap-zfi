***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Retirada de Bloqueios das faturas para execução em JOB.*
*** AUTOR    : [Denilson Pasini Pina] –[META]                         *
*** FUNCIONAL: [Raphael Rocha]                                        *
*** DATA     : [10.09.2021]                                           *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR        | DESCRIÇÃO                              *
***-------------------------------------------------------------------*
***           |              |                                        *
***********************************************************************
REPORT zfir_retira_bloqueios.

INCLUDE zfii_retira_bloqueios_top.
INCLUDE zfii_retira_bloqueios_def.
INCLUDE zfii_retira_bloqueios_Src.
INCLUDE zfii_retira_bloqueios_imp.

START-OF-SELECTION.

   go_desb = NEW zclfi_retira_bloqueios( ir_bukrs = s_bukrs[]
                                         ir_kunnr = s_kunnr[]
                                         ir_belnr = s_belnr[]
                                         ir_buzei = s_buzei[]
                                         ir_gjahr = s_gjhar[]
                                         ir_xblnr = s_xblnr[]
                                         ir_zuonr = s_zuonr[]
                                         ir_hbkid = s_hbkid[]
                                         ir_zlsch = s_zlsch[] ) .

  IF sy-batch IS INITIAL.
    "Processamento ONLINE

    IF go_desb IS BOUND.
      "Busca dados e exibi report
      NEW lcl_report( go_desb->get_report_data( ) )->display_report( ).
    ENDIF.

  ELSE.
    "Processamento BACKGROUND

    IF go_desb IS BOUND.
      "Busca documentos relevantes para o processo e efetua desbloqueio
      go_desb->process_unlock( ).
    ENDIF.

  ENDIF.
