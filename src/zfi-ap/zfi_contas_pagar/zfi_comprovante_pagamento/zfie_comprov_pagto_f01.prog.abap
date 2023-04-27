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
*& Include          ZFIE_COMPROV_PAGTO_F01
*&---------------------------------------------------------------------*

" Os dados do Retorno de pagamento são armazenados para tratamento do segmento Z
" O restante dos dados relacionados ao Comprovante de pagamento serão lidos
" no include ZFIE_COMPROV_PAGTO_F02 e gravados no include ZFIE_COMPROV_PAGTO_F03
FREE go_retpagto_segz.
go_retpagto_segz = NEW zclfi_retorno_pagto_segz( it_dados_arquivo = bdata_ap[] ).
