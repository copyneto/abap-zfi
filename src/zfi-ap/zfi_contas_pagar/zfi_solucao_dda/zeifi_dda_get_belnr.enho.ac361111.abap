"Name: \PR:J_1BBR20\FO:GET_BELNR\SE:END\EI
ENHANCEMENT 0 ZEIFI_DDA_GET_BELNR.

  "Caso tenha encontrado alguma fatura e o CNPJ não bateu, verificar raiz cnpj
  IF p_belnr IS INITIAL AND
     lt_bsik IS NOT INITIAL.

    LOOP AT lt_bsik INTO ls_bsik.

      SELECT SINGLE bukrs belnr gjahr xcpdd lifnr
         FROM bseg
         INTO w_bseg1
        WHERE bukrs = ls_bsik-bukrs
          AND gjahr = ls_bsik-gjahr
          AND belnr = ls_bsik-belnr
          AND koart = 'K'.               "Vendor Line Item

      IF sy-subrc = 0.

        SELECT SINGLE lifnr stcd1 stcd2 stkzn
           FROM lfa1
           INTO w_lfa1
          WHERE lifnr = w_bseg1-lifnr.

        cnpj_tmp = cnpj.
        SHIFT CNPJ_TMP LEFT.
        IF cnpj_tmp(8) = w_lfa1-stcd1(8).
          vendor = w_bseg1-lifnr.
          p_belnr = w_bseg1-belnr.
        ENDIF.

      ENDIF.

      CLEAR: CNPJ_TMP.

    ENDLOOP.

  ENDIF.

ENDENHANCEMENT.
