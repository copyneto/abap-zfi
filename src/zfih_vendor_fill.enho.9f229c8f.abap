"Name: \FU:FI_VENDOR_CHECK\SE:BEGIN\EI
ENHANCEMENT 0 ZFIH_VENDOR_FILL.
TYPES: BEGIN OF ty_vtbfha,
         bukrs  TYPE vtbfha-bukrs,
         rfha   TYPE vtbfha-rfha,
         kontrh TYPE vtbfha-kontrh,
         rbusa  TYPE vtbfha-rbusa,
         bupla  TYPE vtbfha-bupla,
       END OF  ty_vtbfha.

  DATA: ls_vtbfha TYPE ty_vtbfha.

  DATA: lt_j1btrmstax  TYPE TABLE OF vtbfha.
  DATA: ls_j1btrmstax TYPE vtbfha.

  DATA: lv_koart TYPE bseg-koart.

  " Importa dados da transação J1BTRMSTAX (SAPDBTAF)
  IMPORT lt_j1btrmstax TO lt_j1btrmstax FROM DATABASE indx(tx) ID 'TX'.

  READ TABLE lt_j1btrmstax INTO ls_j1btrmstax INDEX 1.

  IF sy-subrc NE 0.
    CLEAR ls_j1btrmstax.
  ENDIF.

  FIELD-SYMBOLS: <fs_blart> TYPE blart.

  ASSIGN  ('(SAPMF05A)XBKPF-BLART') TO <fs_blart>.

  SELECT SINGLE bukrs rfha kontrh rbusa bupla
    FROM vtbfha
    INTO ls_vtbfha
    WHERE bukrs EQ ls_j1btrmstax-bukrs AND
          rfha  EQ ls_j1btrmstax-rfha.

    IF sy-subrc NE 0.
      CLEAR ls_vtbfha.
    ELSE.
      SELECT SINGLE koart
        INTO lv_koart
        FROM bseg
        WHERE lifnr EQ ls_vtbfha-kontrh AND
              ( koart EQ 'K' OR koart EQ 'D' ).

        IF sy-subrc   EQ 0      AND
           sy-tcode   EQ 'FB01'.

          IF <fs_blart> IS ASSIGNED.
             IF <fs_blart> EQ 'TF' OR <fs_blart> EQ 'TZ'.
              i_lifnr = ls_vtbfha-kontrh.
             ENDIF.
            ENDIF.
        ENDIF.
    ENDIF.
ENDENHANCEMENT.
