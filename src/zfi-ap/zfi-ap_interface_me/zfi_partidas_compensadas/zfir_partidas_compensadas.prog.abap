*&---------------------------------------------------------------------*
*&                       3Corações                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& DESCRIÇÃO: Partidas compensadas ao Fornecedor                       *
*& AUTOR    : Rodrigo Felix Farias                                     *
*& FUNCIONAL: Raphael da Silva Amorim Rocha                            *
*& DATA     : 25/03/2022                                               *
*&---------------------------------------------------------------------*
*& HISTÓRICO DAS MODIFICAÇÕES                                          *
***--------------------------------------------------------------------*
*& DATA       | AUTOR        | DESCRIÇÃO                               *
***--------------------------------------------------------------------*
REPORT zfir_partidas_compensadas.

TABLES: t001, bseg.

SELECTION-SCREEN BEGIN OF BLOCK bloco1 WITH FRAME
  TITLE TEXT-001.

  SELECT-OPTIONS: s_bukrs FOR t001-bukrs,
                  s_ebeln FOR bseg-ebeln,
                  s_belnr FOR bseg-belnr,
                  s_gjahr FOR bseg-gjahr.

SELECTION-SCREEN END OF BLOCK bloco1.


START-OF-SELECTION.

  DATA(gv_return) = NEW zclfi_partidas_compensadas( ir_ebeln = s_ebeln[]
                                                    ir_bukrs = s_bukrs[]
                                                    ir_gjahr = s_gjahr[]
                                                    ir_belnr = s_belnr[] )->send_me(  ).

END-of-SELECTION.

  WRITE: gv_return.
