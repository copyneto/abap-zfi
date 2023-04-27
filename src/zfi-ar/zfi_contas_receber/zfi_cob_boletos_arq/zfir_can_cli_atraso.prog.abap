*&---------------------------------------------------------------------*
*&                       3Corações                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& DESCRIÇÃO: Cancelamento por cliente e por dias de atraso            *
*& AUTOR    : Emílio Matheus                                           *
*& FUNCIONAL: Raphael da Silva                                         *
*& DATA     : 06/09/2021                                               *
*&---------------------------------------------------------------------*
*& HISTÓRICO DAS MODIFICAÇÕES                                          *
***--------------------------------------------------------------------*
*& DATA      | AUTOR        | DESCRIÇÃO                                *
***--------------------------------------------------------------------*
*&           |              |                                          *

REPORT zfir_can_cli_atraso.

TABLES knb1.
SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-000.

  SELECT-OPTIONS: s_bukrs FOR knb1-bukrs OBLIGATORY,
                  s_kunnr FOR knb1-kunnr.
  PARAMETERS: p_verzn TYPE verzn  OBLIGATORY DEFAULT '60'.

SELECTION-SCREEN END OF BLOCK sel.

START-OF-SELECTION.
  NEW zclfi_exec_canc_cliente( )->executar(
    iv_bukrs = s_bukrs[]
    iv_kunnr = s_kunnr[]
    iv_verzn = p_verzn
  ).
