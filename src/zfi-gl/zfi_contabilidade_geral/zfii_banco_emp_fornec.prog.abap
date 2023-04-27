*&---------------------------------------------------------------------*
*& Include ZFII_BANCO_EMP_FORNEC
*&---------------------------------------------------------------------*
  DATA: lv_cod_banco TYPE ze_banco_key.

  CLEAR: uv_banco_emp.

  " Somente a primeira ocorrência encontrada na lfbk será considerada
  SELECT bankl
    FROM lfbk
   WHERE lifnr = @bseg-lifnr
    INTO @DATA(lv_bankl)
    UP TO 1 ROWS.
  ENDSELECT.

  IF sy-subrc IS INITIAL
 AND strlen( lv_bankl ) >= 3. " Verifica se está com mínimo de 3 caracteres que identifica o banco
    lv_cod_banco = lv_bankl(3).
  ELSE.
    CLEAR lv_cod_banco.
  ENDIF.

  " Busca configuração de banco empresa do fornecedor por empresa
  SELECT SINGLE bukrs,
                banco,
                hbkid,
                hktid
    FROM ztfi_banco_empr
   WHERE bukrs = @bseg-bukrs
     AND banco = @lv_cod_banco
    INTO @DATA(ls_banco_empr).

  IF sy-subrc IS NOT INITIAL.
    SELECT SINGLE bukrs,
                  banco,
                  hbkid,
                  hktid
      FROM ztfi_banco_empr
     WHERE bukrs = @bseg-bukrs
       AND banco = @space
      INTO @ls_banco_empr.
  ENDIF.

  IF sy-subrc IS INITIAL.

    " Verificar tabela T012 Bancos da empresa
    SELECT COUNT(*)
      FROM t012
     WHERE bukrs = ls_banco_empr-bukrs
       AND hbkid = ls_banco_empr-hbkid.

    IF sy-subrc IS INITIAL.
      " Retorna
      uv_banco_emp = ls_banco_empr-hbkid.
    ENDIF.
  ENDIF.
