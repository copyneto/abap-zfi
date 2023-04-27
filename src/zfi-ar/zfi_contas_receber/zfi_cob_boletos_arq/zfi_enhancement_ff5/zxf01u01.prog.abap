*&---------------------------------------------------------------------*
*& Include          ZXF01U01
*&---------------------------------------------------------------------*

READ TABLE t_febcl ASSIGNING FIELD-SYMBOL(<fs_febcl>) INDEX 1.
IF sy-subrc = 0.

  e_febep = i_febep.

  IF i_febep-avkon <> <fs_febcl>-agkon .
    e_febep-avkon = <fs_febcl>-agkon.
  ENDIF.

  IF i_febep-belnr <> <fs_febcl>-selvon(10).
    e_febep-belnr = <fs_febcl>-selvon(10).
    e_febep-pnota = <fs_febcl>-selvon(10).
  ENDIF.

  IF i_febep-gjahr <> <fs_febcl>-selvon+10(4).
    e_febep-gjahr = <fs_febcl>-selvon+10(4)..
  ENDIF.

ENDIF.
