***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Carga Histórico de Pagamentos                          *
*** AUTOR    : Thiago da Graça – META                                 *
*** FUNCIONAL: Luiz Eduardo Quintanilha Dos Santos – META             *
*** DATA     : 21.02.2022                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR                 | DESCRIÇÃO                     *
***-------------------------------------------------------------------*
*** 21.02.22  | Thiago da Graça       | Criação do programa           *
***********************************************************************
REPORT zfir_job_mercados.
*********************************************************************
* TABLES                                                            *
*********************************************************************
TABLES: bkpf.
*********************************************************************
* TELA DE SELEÇÃO                                                   *
*********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_bukrs FOR bkpf-bukrs,
                  s_dtsel FOR bkpf-budat.

  PARAMETERS:
    p_estorn TYPE datum,
    p_dtlanc TYPE datum.

SELECTION-SCREEN END OF BLOCK b1.
**********************************************************************
* EVENTOS                                                            *
**********************************************************************

INITIALIZATION.
  "Cria instancia
  DATA(lo_contab) = zclfi_contabilizacao=>get_instance( ).

  "Export referencias
  GET REFERENCE OF: s_bukrs[]  INTO lo_contab->gr_bukrs,
                    s_dtsel[]  INTO lo_contab->gr_dtsel.

**********************************************************************
* LOGICA PRINCIPAL
**********************************************************************
START-OF-SELECTION.

  PERFORM: f_executa.
*&---------------------------------------------------------------------*
*&      Form F_EXECUTA
*&---------------------------------------------------------------------*
FORM f_executa.
  "Preenche parametros
  lo_contab->set_ref_data( iv_dtlanc    = p_estorn
                           iv_dtestorno = p_dtlanc ).

  DATA(lt_mensagens) = lo_contab->build( iv_merc_int = abap_true ).

  IF  line_exists( lt_mensagens[ type = 'E' ] ).         "#EC CI_STDSEQ
    MESSAGE e001(ZFI_Deferimento).
  ELSE.
    MESSAGE e002(ZFI_Deferimento).
  ENDIF.
ENDFORM.
