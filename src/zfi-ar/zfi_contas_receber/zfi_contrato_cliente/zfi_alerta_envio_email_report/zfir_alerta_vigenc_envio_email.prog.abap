*&---------------------------------------------------------------------*
*& Report ZFII_ALERTA_VIGENC_ENVIO_EMAIL
*&---------------------------------------------------------------------*
*&
*&--------------------------------------------------------------------*
***********************************************************************
***                       © 3corações                               ***
***********************************************************************
***                                                                   *
*** DESCRIÇÃO:JOB Envio de email-Alerta de Vigência Contratos Cliente *
*** AUTOR :Zenilda Lima – META                                        *
*** FUNCIONAL:Raphael Rocha – META                                    *
*** DATA : 27/12/2021                                                 *
***********************************************************************
*** HISTÓRICO DAS MODIFICAÇÕES                                        *
***-------------------------------------------------------------------*
*** DATA | AUTOR | DESCRIÇÃO                                          *
***-------------------------------------------------------------------*
***      |       |                                                    *
***********************************************************************
REPORT zfir_alerta_vigenc_envio_email.
TABLES ztfi_contrato.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-000.

  SELECT-OPTIONS: s_contra  FOR ztfi_contrato-contrato,
                  s_aditiv  FOR ztfi_contrato-aditivo.

SELECTION-SCREEN END OF BLOCK sel.

INITIALIZATION.

  DATA lo_cl_alert TYPE REF TO zclfi_alerta_contrato_cliente.

  CREATE OBJECT lo_cl_alert.

START-OF-SELECTION.

  lo_cl_alert->execute( iv_contrato = s_contra[]
                        iv_aditivo  = s_aditiv[] ).

  MESSAGE text-001 TYPE 'I'.
