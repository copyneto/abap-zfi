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
*& Include          ZFIE_COMPROV_PAGTO_F02
*&---------------------------------------------------------------------*

" Os dados relacionados ao Comprovante de pagamento, Segmento Z serão lidos e armazenados aqui
" O segmento Z é lido no include ZFIE_COMPROV_PAGTO_F01
" Os dados do Comprovante de pagamento serão gravados no include ZFIE_COMPROV_PAGTO_F03
IF go_retpagto_segz IS BOUND.

  go_retpagto_segz->set_data(
    EXPORTING
      is_segmento_a   = items_p_a
      is_segmento_j   = items_p_j
      is_segmento_oz  = items_p_oz
      is_febko        = febko
      is_febep        = febep
  ).

ENDIF.
