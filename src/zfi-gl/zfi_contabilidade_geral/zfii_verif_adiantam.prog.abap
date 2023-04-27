*&---------------------------------------------------------------------*
*& Include ZFII_VERIF_ADIANTAM
*&---------------------------------------------------------------------*
  CONSTANTS: lc_grpcontas_ffco(4) VALUE 'FFCO',
             lc_blart_zp(2)       VALUE 'ZP'.

  DATA lt_umskz TYPE fdp_corr_umskz_rt.


  lt_umskz[] = VALUE #( sign = 'I' option = 'EQ' ( low = 'F' )
                                                 ( low = '8' ) ).

  SELECT COUNT(*)
    FROM bsik_view
    INTO @DATA(lv_count)
    WHERE bukrs EQ @bseg-bukrs "Empresa
      AND lifnr EQ @bseg-lifnr "Fornecedor
      AND blart NE @lc_blart_zp
      AND umskz IN @lt_umskz.  "Código de Razão Especial

  " Checar grupo de contas
  SELECT SINGLE ktokk
    FROM lfa1
    INTO @DATA(lv_ktokk)
    WHERE lifnr EQ @bseg-lifnr
      AND ktokk EQ @lc_grpcontas_ffco.

  IF sy-subrc = 0 AND
     lv_count >= 3.
    b_result = 'F' .
  ENDIF.
