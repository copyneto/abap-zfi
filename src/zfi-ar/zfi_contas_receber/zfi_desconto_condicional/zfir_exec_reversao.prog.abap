***********************************************************************
*** © 3corações                                                     ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: [Reversão da Provisão PDC ]                            *
*** AUTOR : [Denilson Pasini Pina] – [META IT]                        *
*** FUNCIONAL: [Raphael Rocha] – [META IT]                            *
*** DATA : 13.03.2022                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA | AUTOR | DESCRIÇÃO                                          *
***-------------------------------------------------------------------*
***      |       |                                                    *
***********************************************************************
REPORT zfir_exec_reversao.

INCLUDE zfii_exec_reversao_def.
INCLUDE zfii_exec_reversao_scr.
INCLUDE zfii_exec_reversao_imp.

DATA: lt_data TYPE TABLE OF zsfi_output_revert.

START-OF-SELECTION.

  DATA(lo_reverte) = NEW zclfi_reverte_prov( it_bukrs = s_bukrs[]
                                             it_belnr = s_belnr[]
                                             it_gjahr = s_gjahr[] ).

  DATA(lt_return) = lo_reverte->main_process(  )  .

  lt_data = CORRESPONDING #( lt_return ).


  NEW lcl_report(  )->display_report(  lt_data )   .
