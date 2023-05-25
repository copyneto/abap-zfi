"Name: \PR:SAPFF001\FO:KONTIERUNGSBLOCK_BSEG_FUELLEN\SE:END\EI
ENHANCEMENT 0 ZFIH_DIVISION_FILL.
TYPES: BEGIN OF ty_vtbfha,
         bukrs  TYPE vtbfha-bukrs,
         rfha   TYPE vtbfha-rfha,
         kontrh TYPE vtbfha-kontrh,
         rbusa  TYPE vtbfha-rbusa,
         bupla  TYPE vtbfha-bupla,
       END OF  ty_vtbfha.

DATA: ls_vtbfha TYPE ty_vtbfha.

DATA: lt_j1btrmstax  TYPE TABLE OF vtbfha.
DATA: ls_j1btrmstax  TYPE vtbfha.

" Importa dados da transação J1BTRMSTAX (SAPDBTAF)
IMPORT lt_j1btrmstax TO lt_j1btrmstax FROM DATABASE indx(tx) ID 'TX'.

READ TABLE lt_j1btrmstax INTO ls_j1btrmstax INDEX 1.

IF sy-subrc NE 0.
  CLEAR ls_j1btrmstax.
ENDIF.

IF bseg-koart EQ 'K' OR
   bseg-koart EQ 'D'.

  IF sy-tcode   EQ 'FB01' AND
     bkpf-blart EQ 'TF' OR bkpf-blart EQ 'TZ'.

    SELECT SINGLE bukrs rfha kontrh rbusa bupla
      FROM vtbfha
      INTO ls_vtbfha
      WHERE bukrs EQ ls_j1btrmstax-bukrs AND
            rfha  EQ ls_j1btrmstax-rfha.

    IF sy-subrc NE 0.
      CLEAR ls_vtbfha.
    ELSE.
      bseg-gsber = ls_vtbfha-rbusa.
      bseg-bupla = ls_vtbfha-bupla.
    ENDIF.

  ENDIF.

ENDIF.

ENDENHANCEMENT.
