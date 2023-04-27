***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Autom. bancária VAN FINNET                             *
*** AUTOR : Anderson Miazato - META                                   *
*** FUNCIONAL: Raphael Rocha - META                                   *
***   Este include é chamado no form datei_schliessen                 *
***   do include include RFFORI99, report RFFOBR_A                    *
*** DATA : 22.10.2021                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 22.10.2021 | Anderson Miazato   | Desenvolvimento inicial         *
***********************************************************************

*&---------------------------------------------------------------------*
*& Include          ZFIE_AUTBANC_GRAVAR_COB
*&---------------------------------------------------------------------*

  "Verifica se os tipos de pagamento NÃO exigem aprovação.
  IF reguh-rzawe CA zclfi_automatizacao_bancaria=>gc_forma_pagto-cobranca AND reguh-xvorl IS INITIAL.
    "Efetua a gravação do arquivo de remessa na pasta de saída para a VAN (FINNET).
    zclfi_automatizacao_bancaria=>gravar_saida( is_reguh = reguh
                                                iv_tipo = 2 ).
    "Verifica se os tipos de pagamento NÃO exigem aprovação. RISCO SACADO
  ELSEIF reguh-rzawe CA zclfi_automatizacao_bancaria=>gc_forma_pagto-riscosacado AND reguh-xvorl IS INITIAL.
    zclfi_automatizacao_bancaria=>gravar_saida( is_reguh = reguh
                                                iv_tipo = 1 ).
    "Verifica se os tipos de pagamento NÃO exigem aprovação. GNRE
  ELSEIF reguh-rzawe EQ 'G' AND reguh-xvorl IS INITIAL.
    zclfi_automatizacao_bancaria=>gravar_saida( is_reguh = reguh
                                                iv_tipo = 1 ).
  ENDIF.
