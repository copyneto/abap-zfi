***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: FI-GL 212 Chave de referência na variação cambial      *
*** AUTOR : Anderson Miazato - META                                   *
*** FUNCIONAL: Eduardo Quintanilha - META                             *
*** DATA : 11.12.2021                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 27.12.2021 | Anderson Miazato   | Desenvolvimento inicial         *
***********************************************************************

*&---------------------------------------------------------------------*
*& Include          ZFIE_VAR_CAMBIAL_POSTING_HD
*&---------------------------------------------------------------------*

  NEW zclfi_variacao_cambial_refhd( is_post_db = cs_post_db )->execute(
    CHANGING
      cs_post_batch = cs_post_batch
      ct_doc_header = ct_doc_header
      ct_post_batch = ct_post_batch
  ).
