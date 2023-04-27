***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Autom. bancária VAN FINNET                             *
***   Este include é chamado no form datei_schliessen                 *
***   do include RFFORI99, report RFFOBR_U                            *
*** AUTOR : Anderson Miazato - META                                   *
*** FUNCIONAL: Raphael Rocha - META                                   *
*** DATA : 22.10.2021                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 22.10.2021 | Anderson Miazato   | Desenvolvimento inicial         *
***********************************************************************

*&---------------------------------------------------------------------*
*& Include          ZFIE_AUTBANC_GRAVAR_ARQ
*&---------------------------------------------------------------------*
    zclfi_automatizacao_bancaria=>exec_proposal( is_reguh = reguh ).
