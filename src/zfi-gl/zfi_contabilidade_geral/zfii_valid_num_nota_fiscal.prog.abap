*&---------------------------------------------------------------------*
*& Include ZFII_VALID_NUM_NOTA_FISCAL
*&---------------------------------------------------------------------*

  DATA lv_xblnr(06) TYPE n.

  " Selecionar número da nota fiscal correspondente
  SELECT SINGLE belnr, gjahr
    FROM ekbe
    INTO ( @DATA(lv_belnr), @DATA(lv_gjahr) )
    WHERE ebeln EQ @bseg-ebeln
      AND xblnr EQ @bseg-vbeln
      AND bwart EQ '862'
      AND bewtp EQ 'U'.

  b_result = b_true.

  IF sy-subrc EQ 0.

    DATA(lv_refkey) = CONV j_1brefkey( |{ lv_belnr }{ lv_gjahr }| ).

    SELECT SINGLE a~nfnum
      FROM j_1bnfdoc AS a
      INNER JOIN j_1bnflin AS b ON a~docnum = b~docnum
      INTO @DATA(lv_nota)
      WHERE a~nftype EQ 'G1'
        AND b~refkey EQ @lv_refkey
        AND a~cancel EQ ' '.

    IF sy-subrc EQ 0.
      MOVE bkpf-xblnr TO lv_xblnr.
      IF lv_xblnr NE lv_nota.
        b_result = b_false.
      ENDIF.
    ENDIF.

  ENDIF.
