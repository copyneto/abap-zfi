***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: JOB Automação textos contábeis                         *
*** AUTOR : Anderson Miazato - META                                   *
*** FUNCIONAL: Luiz Eduardo Quintanilha - META                        *
*** DATA : 17.01.2022                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 17.01.2022 | Anderson Miazato   | Desenvolvimento inicial         *
***********************************************************************

*&---------------------------------------------------------------------*
*& Report zfir_automacao_txt_contab
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfir_automacao_txt_contab.

TABLES: bseg, bkpf.

" Tela de seleção
SELECTION-SCREEN BEGIN OF BLOCK b01.

  SELECT-OPTIONS:
    s_bukrs for bkpf-bukrs,
    s_gjahr for bkpf-gjahr,
    s_budat for bkpf-budat,
    s_belnr FOR bseg-belnr.

SELECTION-SCREEN END OF BLOCK b01.

START-OF-SELECTION.

  NEW zclfi_auto_txt_contab( it_bukrs = s_bukrs[]
                             it_gjahr = s_gjahr[]
                             it_budat = s_budat[]
                             it_belnr = s_belnr[]
  )->execute( ).

  IF sy-batch EQ abap_false.
    MESSAGE s004(zfi_auto_txt_contab) WITH zclfi_auto_txt_log=>gc_log_objeto-obj zclfi_auto_txt_log=>gc_log_objeto-subobj.
  ENDIF.
