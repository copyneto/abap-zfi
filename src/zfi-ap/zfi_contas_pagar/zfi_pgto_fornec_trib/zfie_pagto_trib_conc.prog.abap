*&---------------------------------------------------------------------*
*& Include          ZFIE_PAGTO_TRIB_CONC
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_bdata_ap,
         rec(240) TYPE c,
       END OF ty_bdata_ap.

DATA: ls_bdata_ap TYPE ty_bdata_ap.

LOOP AT bdata_ap ASSIGNING FIELD-SYMBOL(<fs_bdata_ap>).


  ls_bdata_ap = <fs_bdata_ap>.

  IF <fs_bdata_ap>-rec+7(1) = '3'.
    IF <fs_bdata_ap>-rec+13(1)  = 'O'.
      IF <fs_bdata_ap>-rec(3) = '341'.

        <fs_bdata_ap>-rec+61(30) = ls_bdata_ap-rec+65(30).
        <fs_bdata_ap>-rec+91(8) = ls_bdata_ap-rec+95(8).
        <fs_bdata_ap>-rec+99(8) = ls_bdata_ap-rec+136(8).
        <fs_bdata_ap>-rec+107(15) = ls_bdata_ap-rec+144(15).
        <fs_bdata_ap>-rec+122(20) = ls_bdata_ap-rec+174(20).
        <fs_bdata_ap>-rec+142(20) = ls_bdata_ap-rec+215(20).
      ENDIF.
    ENDIF.
  ENDIF.

  IF <fs_bdata_ap>-rec+7(1) = '5' ."AND st_sgment_n = 'X'.
    IF <fs_bdata_ap>-rec(3) = '341'.
      CONCATENATE '0000' ls_bdata_ap-rec+65(14) INTO <fs_bdata_ap>-rec+23(18).
    ENDIF.
  ENDIF.


ENDLOOP.
