*&---------------------------------------------------------------------*
*&                       3Corações                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& DESCRIÇÃO: Cancelamento bancário de faturas                         *
*& AUTOR    : Emílio Matheus                                           *
*& FUNCIONAL: Raphael da Silva                                         *
*& DATA     : 06/09/2021                                               *
*&---------------------------------------------------------------------*
*& HISTÓRICO DAS MODIFICAÇÕES                                          *
***--------------------------------------------------------------------*
*& DATA      | AUTOR        | DESCRIÇÃO                                *
***--------------------------------------------------------------------*
*&           |              |                                          *
REPORT zfir_can_banc_dev.

TABLES: bseg.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-000.

*  PARAMETERS:     p_bukrs  TYPE bukrs    OBLIGATORY.

  SELECT-OPTIONS: s_bukrs  FOR bseg-bukrs,
                  s_budat  FOR sy-datum OBLIGATORY.

SELECTION-SCREEN END OF BLOCK sel.


INITIALIZATION.

  DATA lo_cl_bol TYPE REF TO zclfi_exec_canc_bancario.

  CREATE OBJECT lo_cl_bol.

  lo_cl_bol->calc_date( CHANGING cr_budat = s_budat[] ).

START-OF-SELECTION.

  lo_cl_bol->get_data( iv_bukrs = s_bukrs[]
                       iv_budat = s_budat[]
                       iv_report = abap_true ).
