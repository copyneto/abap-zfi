*&---------------------------------------------------------------------*
*&                       3Corações                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& DESCRIÇÃO: Renovação de Contrato                                    *
*& AUTOR    : Mauro Rangel                                             *
*& FUNCIONAL: Raphael da Silva                                         *
*& DATA     : 12/01/2022                                               *
*&---------------------------------------------------------------------*
*& HISTÓRICO DAS MODIFICAÇÕES                                          *
***--------------------------------------------------------------------*
*& DATA      | AUTOR        | DESCRIÇÃO                                *
***--------------------------------------------------------------------*
REPORT zfir_renovar_contrato.
TABLES ztfi_contrato.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-000.

  SELECT-OPTIONS: s_bukrs  FOR ztfi_contrato-bukrs,
                  s_branch FOR ztfi_contrato-branch,
                  s_contra FOR ztfi_contrato-contrato.

SELECTION-SCREEN END OF BLOCK sel.

INITIALIZATION.

  DATA(lo_reno_contrato) = NEW zclfi_job_renovar_contrato( ).

START-OF-SELECTION.

  lo_reno_contrato->execute_job(  iv_empresa    = s_bukrs[]
                                  iv_locnegocio = s_branch[]
                                  iv_contrato   = s_contra[] ).

MESSAGE text-001 TYPE 'I'.
