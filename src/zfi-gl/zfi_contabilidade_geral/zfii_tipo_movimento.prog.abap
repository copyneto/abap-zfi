*&---------------------------------------------------------------------*
*& Include          ZFII_TIPO_MOVIMENTO
*&---------------------------------------------------------------------*

IF bseg-bewar IS INITIAL.

  "@@ Busca plano de contas
  SELECT SINGLE ktopl
    FROM ska1
    INTO @DATA(lv_ktopl)
    WHERE saknr = @bseg-hkont.

  IF sy-subrc = 0.

    "@@ Busca tipo de movimento
    SELECT SINGLE bewar
      INTO bseg-bewar
      FROM ztfi_tipo_movi
      WHERE ktopl = lv_ktopl
         AND hkont = bseg-hkont
         AND shkzg = bseg-shkzg
         AND blart = bkpf-blart.

  ENDIF.

ENDIF.
