***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: FI AP - Comprovante de Pagamento Segmento Z            *
*** AUTOR : Anderson Miazato - META                                   *
*** FUNCIONAL: Raphael da Silva Amorim Rocha - META                   *
*** DATA : 10.09.2021                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 10.09.2021 | Anderson Miazato   | Desenvolvimento inicial         *
***********************************************************************

*&---------------------------------------------------------------------*
*& Include          ZFIE_COMPROV_PAGTO_F03
*&---------------------------------------------------------------------*
" Os dados relacionados ao Comprovante de pagamento, Segmento Z serão gravados aqui
" O segmento Z é lido no include ZFIE_COMPROV_PAGTO_F01
" A leitura e seleção de dados relacionados ao Comprovante de pagamento, Segmento Z
" são executadas no include ZFIE_COMPROV_PAGTO_F02
IF go_retpagto_segz IS BOUND.
  go_retpagto_segz->save_data( ).
ENDIF.
