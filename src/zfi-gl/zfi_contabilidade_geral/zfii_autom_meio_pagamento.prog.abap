*&---------------------------------------------------------------------*
*& Include ZFII_AUTOM_MEIO_PAGAMENTO
*&---------------------------------------------------------------------*

  IF NOT bseg-lifnr IS INITIAL.

    SELECT SINGLE zwels
      FROM lfb1
      INTO @DATA(lv_zwels)
      WHERE lifnr = @bseg-lifnr
        AND bukrs = @bseg-bukrs.

    bseg-zlsch = COND #( WHEN sy-subrc EQ 0 AND
                         strlen( lv_zwels ) EQ 1
                         THEN lv_zwels(1)
                         ELSE bseg-zlsch ).

  ENDIF.
