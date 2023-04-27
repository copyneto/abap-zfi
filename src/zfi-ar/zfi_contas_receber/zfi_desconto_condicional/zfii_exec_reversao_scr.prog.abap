*&---------------------------------------------------------------------*
*& Include zfii_exec_reversao_scr
*&---------------------------------------------------------------------*

DATA: gv_bukrs TYPE bkpf-bukrs,
      gv_belnr TYPE bkpf-belnr,
      gv_gjahr TYPE bkpf-gjahr,
      gv_blart TYPE bkpf-blart.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS: s_bukrs FOR gv_bukrs,
                  s_belnr FOR gv_belnr,
                  s_gjahr FOR gv_gjahr,
                  s_blart FOR gv_blart.

SELECTION-SCREEN END OF BLOCK b1.
