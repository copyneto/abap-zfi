*&---------------------------------------------------------------------*
*& Report ZFIR_JOB_ATUALIZADOC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfir_job_atualizadoc.

TABLES: bseg.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: s_bukrs FOR bseg-bukrs.
  PARAMETERS: p_gjahr TYPE bsid_view-gjahr DEFAULT sy-datum(4),
              p_mansp TYPE bsid_view-mansp DEFAULT 'P'.

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  DATA(go_job) = NEW zclfi_atualizadoc( is_bukrs = s_bukrs[]
                                        iv_mansp = p_mansp
                                        iv_gjahr = p_gjahr ).
  go_job->process( ).

 MESSAGE i001(zfi_atualizadoc) DISPLAY LIKE 'A'.
