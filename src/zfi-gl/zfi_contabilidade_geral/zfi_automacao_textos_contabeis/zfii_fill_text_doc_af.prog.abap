***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Automação de textos contábeis                          *
***  Preenche texto de item para documentos do tipo AF - Lançamentos  *
***  de depreciação                                                   *
*** AUTOR : Anderson Miazato - META                                   *
*** FUNCIONAL: Luiz Eduardo Quintanilha - META                        *
*** DATA : 23.03.2022                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA       | AUTOR              | DESCRIÇÃO                       *
***-------------------------------------------------------------------*
*** 23.03.2022 | Anderson Miazato   | Desenvolvimento inicial         *
***********************************************************************

*&---------------------------------------------------------------------*
*& Include ZFII_FILL_TEXT_DOC_AF
*&---------------------------------------------------------------------*

  zclfi_auto_txt_contab=>preenche_texto_doc_af(
    EXPORTING
      is_bseg  = bseg
      is_bkpf  = bkpf
    CHANGING
      cv_sgtxt = bseg-sgtxt ).
