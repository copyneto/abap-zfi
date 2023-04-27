*&---------------------------------------------------------------------*
*& Report ZFIR_CONCREDITO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfir_concredito.

TABLES: bseg.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: s_bukrs FOR bseg-bukrs,
                  s_belnr FOR bseg-belnr,
                  s_fat   FOR bseg-belnr.
SELECTION-SCREEN: END OF BLOCK b1.

INITIALIZATION.

  DATA(go_report) = NEW zclfi_prog_conc_cred( ).

  GET REFERENCE OF s_belnr[] INTO go_report->gs_refdata-belnr.
  GET REFERENCE OF s_bukrs[] INTO go_report->gs_refdata-bukrs.
  GET REFERENCE OF s_fat[]   INTO go_report->gs_refdata-fat.

START-OF-SELECTION.

  go_report->process( ).
