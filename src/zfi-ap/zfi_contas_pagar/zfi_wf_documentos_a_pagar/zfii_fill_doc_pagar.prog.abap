*&---------------------------------------------------------------------*
*& Include          ZFII_FILL_DOC_PAGAR
*&---------------------------------------------------------------------*

DATA: lr_zlspr TYPE RANGE OF bseg-zlspr,
      lv_check TYPE abap_bool.


IMPORT lv_check TO lv_check FROM MEMORY ID 'ZTCOMP'.

lr_zlspr = VALUE #( ( sign = 'I' option = 'EQ' low = '' )
                    ( sign = 'I' option = 'EQ' low = 'A') ).

IF bseg-koart = 'K' AND  bseg-zlspr IN lr_zlspr .

  SELECT COUNT(*)
      FROM lfb1
    WHERE lifnr = bseg-lifnr
      AND bukrs = bseg-bukrs
      AND fdgrv = 'A01'.

  IF sy-subrc = 0.
    bseg-zlspr = 'C'.
  ENDIF.

ENDIF.

IF lv_check = abap_true AND
  bseg-zlspr IS NOT INITIAL.
  bseg-zlspr = ''.
  FREE MEMORY ID 'ZTCOMP'.
ENDIF.
