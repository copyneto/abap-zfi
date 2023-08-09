*&---------------------------------------------------------------------*
*& Include          ZFII_FILL_ZLSCH
*&---------------------------------------------------------------------*
  DATA:
    lr_blart TYPE RANGE OF blart.

  CONSTANTS:
    lc_modulo	TYPE ztca_param_par-modulo VALUE 'FI-AP',
    lc_chave1	TYPE ztca_param_par-chave1 VALUE 'FORMA_DE_PAGAMENTO',
    lc_chave2	TYPE ztca_param_par-chave2 VALUE 'TIPODOC'.
  CLEAR lr_blart.
  TRY.
      DATA(lo_param) = zclca_tabela_parametros=>get_instance( ). " CHANGE - LSCHEPP - 24.07.2023
      lo_param->m_get_range(
        EXPORTING
          iv_modulo = lc_modulo
          iv_chave1 = lc_chave1
          iv_chave2 = lc_chave2
        IMPORTING
          et_range  = lr_blart
      ).
    CATCH zcxca_tabela_parametros.
  ENDTRY.

  IF sy-tcode IS NOT INITIAL
      OR ( sy-tcode IS INITIAL AND bseg-koart = 'K' AND bkpf-blart IN lr_blart ).

    SELECT *
      FROM ztsd_gnret009
      INTO TABLE @DATA(lt_gnret009)
     WHERE lifnr = @bseg-lifnr
       AND bukrs = @bseg-bukrs.

    IF sy-subrc NE 0.

      SELECT SINGLE zwels
      FROM lfb1
      INTO @DATA(lv_zwels)
      WHERE lifnr = @bseg-lifnr
        AND bukrs = @bseg-bukrs.

      bseg-zlsch = lv_zwels(1).

    ENDIF.

  ENDIF.
