*&---------------------------------------------------------------------*
*& Include          ZSDI_CAF_TRATAR_CONTABILIZACAO
*&---------------------------------------------------------------------*
***********************************************************************
***                      © 3corações                                ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO: Include Contratos Contabilizados                         *
*** AUTOR    : [Flavia Nunes] –[META]                                  *
*** FUNCIONAL: [] –[META]                              *
*** DATA     : [04/01/22]                                             *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA      | AUTOR        | DESCRIÇÃO                              *
***-------------------------------------------------------------------*
***           |              |                                        *
***********************************************************************

DATA(lo_contratos_contab) = NEW zclfi_contratos_contab( ).
lo_contratos_contab->executar( EXPORTING
                                         is_cvbrk      = cvbrk
                                         is_cvbrp      = cvbrp
                                         it_cvbrp      = cvbrp[]
                                         it_xaccit     = xaccit[]
                                         it_xaccfi     = xaccfi[]
                                         it_xacccr     = xacccr[]
                                         it_doc_uuid_h = lt_uuid[]
                               IMPORTING
                                         et_return = DATA(lt_return)  ).
