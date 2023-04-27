*&---------------------------------------------------------------------*
*& Include ZFII_VALID_NEW_GL
*&---------------------------------------------------------------------*

IF bseg-koart <> 'D' AND bseg-koart <> 'K'.
  IF bseg-gsber IS INITIAL OR bseg-bupla IS INITIAL.
    b_result = 'T'.

    "Preencher no item & a Divisão e o Local de Negócio
    MESSAGE e003(zfi_validacao_newgl) WITH bseg-buzei.
  ENDIF.

  "Verificando se os valores preenchidos estão relacionados para uma
  "determinada empresa na ZTFI_PARAM_RM
  SELECT COUNT( * )
    FROM ztfi_param_rm
    WHERE bukrs = @bkpf-bukrs
      AND gsber = @bseg-gsber.

  IF sy-subrc IS NOT INITIAL.
    b_result = 'T'.

    "Divisão & não pertence à empresa &
    MESSAGE e002(zfi_validacao_newgl) WITH bseg-gsber bkpf-bukrs.
  ENDIF.
ELSE.
  IF bseg-bupla IS INITIAL.
    b_result = 'T'.

    "Preencher no item & o Local de Negócio
    MESSAGE e004(zfi_validacao_newgl) WITH bseg-buzei.
  ENDIF.
ENDIF.


SELECT COUNT( * )
  FROM ztfi_param_rm
  WHERE bukrs = @bkpf-bukrs
    AND bupla = @bseg-bupla.

IF sy-subrc IS NOT INITIAL.
  b_result = 'T'.

  "Local de Negócios & não pertence à empresa &
  MESSAGE e001(zfi_validacao_newgl) WITH bseg-bupla bkpf-bukrs.
ENDIF.
