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

    CONSTANTS:
      BEGIN OF gc_parametros,
        modulo TYPE ze_param_modulo VALUE 'FI-AP',
        chave1 TYPE ztca_param_par-chave1 VALUE 'F110SNAODOW',
        chave2 TYPE ztca_param_par-chave2 VALUE 'FORMAPGTO',
      END OF gc_parametros.

    DATA: lr_rzawe TYPE RANGE OF reguh-rzawe.

    TRY.

        DATA(lo_tabela_parametros) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 24.07.2023

        lo_tabela_parametros->m_get_range(
          EXPORTING
            iv_modulo = gc_parametros-modulo
            iv_chave1 = gc_parametros-chave1
            iv_chave2 = gc_parametros-chave2
            IMPORTING
              et_range  = lr_rzawe
        ).
      CATCH zcxca_tabela_parametros. " Classe de exceção Tabela de Parâmetros

    ENDTRY.



    "Verifica se os tipos de pagamento NÃO exigem aprovação.
    IF reguh-rzawe CA zclfi_automatizacao_bancaria=>gc_forma_pagto-cobranca AND reguh-xvorl IS INITIAL.
      "Efetua a gravação do arquivo de remessa na pasta de saída para a VAN (FINNET).
      zclfi_automatizacao_bancaria=>gravar_saida( is_reguh = reguh
                                                  iv_tipo = 2 ).
      "Verifica se os tipos de pagamento NÃO exigem aprovação. RISCO SACADO
    ELSEIF reguh-rzawe NOT IN lr_rzawe AND reguh-xvorl IS INITIAL.
      zclfi_automatizacao_bancaria=>gravar_saida( is_reguh = reguh
                                                  iv_tipo = 1 ).
      "Verifica se os tipos de pagamento NÃO exigem aprovação. GNRE
    ELSEIF reguh-rzawe EQ 'G' AND reguh-xvorl IS INITIAL.
      zclfi_automatizacao_bancaria=>gravar_saida( is_reguh = reguh
                                                  iv_tipo = 1 ).
    ENDIF.
