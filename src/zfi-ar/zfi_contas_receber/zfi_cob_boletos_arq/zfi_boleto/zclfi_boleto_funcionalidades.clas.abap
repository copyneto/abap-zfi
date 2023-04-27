class ZCLFI_BOLETO_FUNCIONALIDADES definition
  public
  final
  create public .

public section.

  data:
    BEGIN OF gs_boleto_nn.
        INCLUDE TYPE ztfi_boleto_nn.
    DATA: END OF gs_boleto_nn .

  class-methods LINHA_DIGITAVEL
    importing
      !IV_CB type CHAR44
    returning
      value(RS_LD) type ZSFI_BOLETO_LD .
  class-methods CODIGO_BARRAS
    importing
      !IS_DADOS_BOLETO type ZSFI_BOLETO_237
    returning
      value(RV_CB) type CHAR44 .
  class-methods DIG_VERF_MOD11
    importing
      !IV_CB type CHAR44
    returning
      value(RV_DIGVRF) type NUMC1 .
  class-methods DIG_VERF_MOD10_NN
    importing
      !IS_BOLETO type ZSFI_BOLETO_237
    returning
      value(RV_DIGVRF) type CHAR1 .
  class-methods DIG_VERF_MOD11_NN
    importing
      !IV_NOS_NUMERO type NUMC13
    returning
      value(RV_DIGVRF) type CHAR1 .
  class-methods DIG_VERF_MOD10_CONV
    importing
      !IV_CAMPO type NUMC11
    exporting
      !EV_DIGVRF type NUMC01 .
  class-methods DIG_VERF_MOD11_CONV
    importing
      !IV_CAMPO type C
    returning
      value(RV_DIGVRF) type CHAR1 .
  class-methods INTRV_NOSSO_NUMERO
    importing
      !IV_BUKRS type BUKRS
      !IV_HBKID type HBKID
      !IV_XREF3 type XREF3
    returning
      value(RS_NNUMERO) like GS_BOLETO_NN .
protected section.
private section.

  class-methods DIG_VERF_MOD10
    importing
      !IS_LNH_DIG type ZSFI_BOLETO_LD
    returning
      value(RS_DIGVRF) type ZSFI_BOLETO_DV10 .
ENDCLASS.



CLASS ZCLFI_BOLETO_FUNCIONALIDADES IMPLEMENTATION.


  METHOD codigo_barras.

    DATA: ls_campo_livre TYPE zsfi_boleto_cp_liv.

    DATA: lv_cod_barras    TYPE zed_boleto_cb,
          lv_dt_base       TYPE sy-datum,
          lv_dt_venc       TYPE sy-datum,
          lv_dv_cb(1)      TYPE n,
          lv_vencimento(4) TYPE n,
          lv_valor(10)     TYPE n.

    CONSTANTS: lc_dt_base TYPE sy-datum VALUE '19971007'.

    lv_dt_base    = lc_dt_base.
    lv_dt_venc    = is_dados_boleto-vencimento.
    lv_vencimento = lv_dt_venc - lv_dt_base.

    CASE is_dados_boleto-banco.
      WHEN '237'.
        ls_campo_livre-agencia   = is_dados_boleto-agencia.
        ls_campo_livre-carteira  = is_dados_boleto-carteira.
        ls_campo_livre-documento = is_dados_boleto-nossonum.
        ls_campo_livre-conta     = is_dados_boleto-conta.
        ls_campo_livre-zero      = 0.

        MOVE ls_campo_livre TO lv_cod_barras+19(25).

        lv_cod_barras(3)    = is_dados_boleto-banco.
        lv_cod_barras+3(1)  = is_dados_boleto-moeda.
        lv_cod_barras+5(4)  = lv_vencimento.

        IF is_dados_boleto-valorabat IS NOT INITIAL.
          lv_valor = is_dados_boleto-valorcob.
        ELSE.
          lv_valor = is_dados_boleto-valordoc.
        ENDIF.

        lv_cod_barras+9(10) = lv_valor.

      WHEN OTHERS.
        " Outros bancos

    ENDCASE.

    CALL METHOD zclfi_boleto_funcionalidades=>dig_verf_mod11
      EXPORTING
        iv_cb     = lv_cod_barras
      RECEIVING
        rv_digvrf = lv_dv_cb.

    lv_cod_barras+4(1) = lv_dv_cb.

    rv_cb = lv_cod_barras.

  ENDMETHOD.


  METHOD dig_verf_mod10.

    FIELD-SYMBOLS: <fs_campo> TYPE any.

    DATA: lv_nmcampo(20) TYPE c,
          lv_campo(20)   TYPE c,
          lv_mult1       TYPE n,
          lv_mult2       TYPE n,
          lv_pos(2)      TYPE n,
          lv_qtd(2)      TYPE n,
          lv_cont        TYPE n,
          lv_result1(2)  TYPE n,
          lv_result2(2)  TYPE n,
          lv_result3(2)  TYPE n,
          lv_result4(2)  TYPE n,
          lv_dezena(2)   TYPE n,
          lv_dv          TYPE i.

    lv_mult2 = 2.

    DO 3 TIMES.

      ADD 1 TO lv_cont.
      CONCATENATE 'IS_LNH_DIG-CAMPO' lv_cont INTO lv_nmcampo.
      ASSIGN (lv_nmcampo) TO <fs_campo>.

      lv_pos = 0.

      CLEAR: lv_campo,
             lv_result1,
             lv_result2,
             lv_result3,
             lv_result4,
             lv_dv.

      IF lv_nmcampo EQ 'IS_LNH_DIG-CAMPO1'.
        lv_qtd        = 9.
        lv_campo(5)   = <fs_campo>(5).
        lv_campo+5(4) = <fs_campo>+6(4).
      ELSE.
        lv_qtd        = 10.
        lv_campo(5)   = <fs_campo>(5).
        lv_campo+5(5) = <fs_campo>+6(5).
      ENDIF.

      DO lv_qtd TIMES.                                   "#EC CI_NESTED

        lv_mult1   = lv_campo+lv_pos(1).
        lv_result1 = ( lv_mult1 * lv_mult2 ).

        IF lv_result1 > 9.
          lv_result2 = lv_result1(1) + lv_result1+1(1).
        ELSE.
          lv_result2 = lv_result1.
        ENDIF.

        lv_result3 = lv_result3 + lv_result2.

        IF lv_mult2 EQ 1.
          lv_mult2 = 2.
        ELSE.
          lv_mult2 = 1.
        ENDIF.

        ADD 1 TO lv_pos.

      ENDDO.

      lv_dezena(1)   = lv_result3(1).
      lv_dezena+1(1) = 0.
      lv_dezena      = lv_dezena + 10.
      lv_result4     = lv_dezena - lv_result3.

      IF lv_result4 EQ 10.
        lv_dv = 0.
      ELSE.
        lv_dv = lv_result4.
      ENDIF.

      CONCATENATE 'RS_DIGVRF-DV_CP' lv_cont INTO lv_nmcampo.
      ASSIGN (lv_nmcampo) TO <fs_campo>.
      <fs_campo> = lv_dv.

    ENDDO.
  ENDMETHOD.


  METHOD dig_verf_mod10_conv.

    DATA: lv_campo11 TYPE numc11,
          lv_mult1   TYPE n,
          lv_mult2   TYPE n,
          lv_tam(2)  TYPE n,
          lv_pos(2)  TYPE n,
          lv_qtd(2)  TYPE n,
          lv_result1 TYPE i,
          lv_result2 TYPE i,
          lv_result3 TYPE i,
          lv_resto   TYPE i.

    lv_campo11 = iv_campo.

    lv_tam = strlen( iv_campo ).
    lv_qtd = 1.

    lv_mult2 = 2.
    lv_pos   = lv_tam - 1.

    DO lv_tam TIMES.

      lv_mult1   = iv_campo+lv_pos(1).
      lv_result1 = ( lv_mult1 * lv_mult2 ).
      lv_result2 = lv_result2 + lv_result1.

      IF lv_mult2 EQ 2.
        lv_mult2 = 1.
      ELSE.
        lv_mult2 = 2.
      ENDIF.

      SUBTRACT 1 FROM lv_pos.

    ENDDO.

    IF lv_result2 IS NOT INITIAL.
      lv_resto   = lv_result2 MOD 10.
      lv_result3 = 10 - lv_resto.
    ENDIF.

  ENDMETHOD.


  METHOD dig_verf_mod10_nn.

    DATA: lv_mult1    TYPE n,
          lv_mult2(2) TYPE n,
          lv_cont(2)  TYPE n,
          lv_result1  TYPE i,
          lv_result2  TYPE i,
          lv_resto    TYPE i.

    DATA(lv_num) = is_boleto-agencia && is_boleto-conta && is_boleto-carteira && is_boleto-nossonum.

    DATA(lv_qtd) = strlen( lv_num ).

    lv_cont  = lv_qtd - 1.
    lv_mult2 = 2.

    DO lv_qtd TIMES.

      lv_mult1   = lv_num+lv_cont(1).
      lv_result1 = ( lv_mult1 * lv_mult2 ).
      lv_result2 = lv_result2 + lv_result1.

      IF lv_qtd EQ 0.
        EXIT.
      ENDIF.

      SUBTRACT 1 FROM lv_cont.

      CASE lv_mult2.
        WHEN 1.
          ADD 1 TO lv_mult2.
        WHEN 2.
          SUBTRACT 1 FROM lv_mult2.
        WHEN OTHERS.
      ENDCASE.

    ENDDO.

    IF lv_result2 IS NOT INITIAL.

      lv_resto = lv_result2 MOD 10.

      IF lv_resto = 0.
        rv_digvrf = 0.
      ELSE.
        rv_digvrf = 10 - lv_resto.
      ENDIF.

    ENDIF.
  ENDMETHOD.


  METHOD dig_verf_mod11.

    DATA: lv_cb43(43) TYPE n,
          lv_mult1    TYPE n,
          lv_mult2    TYPE n,
          lv_pos(2)   TYPE n,
          lv_qtd(2)   TYPE n,
          lv_result1  TYPE i,
          lv_result2  TYPE i,
          lv_result3  TYPE i,
          lv_resto    TYPE i.

    lv_cb43(4) = iv_cb(4).
    lv_cb43+4  = iv_cb+5.

    lv_pos = 42.
    lv_qtd = 6.

    DO lv_qtd TIMES.

      lv_mult2 = 2.

      DO 8 TIMES.                                        "#EC CI_NESTED

        lv_mult1   = lv_cb43+lv_pos(1).
        lv_result1 = ( lv_mult1 * lv_mult2 ).
        lv_result2 = lv_result2 + lv_result1.

        IF lv_pos EQ 0.
          EXIT.
        ENDIF.

        SUBTRACT 1 FROM lv_pos.
        ADD 1 TO lv_mult2.

      ENDDO.
    ENDDO.

    IF lv_result2 IS NOT INITIAL.

      lv_resto   = lv_result2 MOD 11.
      lv_result3 = 11 - lv_resto.

      CASE lv_result3.
        WHEN 0.
          rv_digvrf = 1.
        WHEN 10.
          rv_digvrf = 1.
        WHEN 11.
          rv_digvrf = 1.
        WHEN OTHERS.
          rv_digvrf = lv_result3.
      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD dig_verf_mod11_conv.

    DATA: lv_index  TYPE i,
          lv_step   TYPE i VALUE 1,
          lv_value  TYPE i,
          lv_total  TYPE i,
          lv_cd     TYPE i,
          lv_length TYPE i.

    lv_length = strlen( iv_campo ).
    lv_index  = lv_length.

    DO lv_length TIMES.

      ADD 1 TO lv_step.

      IF lv_step > 9.
        lv_step = 2.
      ENDIF.

      lv_index = lv_index - 1.
      lv_value = iv_campo+lv_index(1).
      lv_value = lv_value * lv_step.
      lv_total = lv_total + lv_value.

    ENDDO.

    lv_value = lv_total MOD 11.

    IF lv_value = 0
    OR lv_value = 1.
      lv_cd = 0.
    ELSE.
      lv_cd = 11 - lv_value.
    ENDIF.

    rv_digvrf = lv_cd.

  ENDMETHOD.


  METHOD dig_verf_mod11_nn.

    DATA: ls_cb13 TYPE ztfi_boleto_nn.

    DATA: lv_mult1    TYPE n,
          lv_mult2(2) TYPE n,
          lv_pos(2)   TYPE n,
          lv_qtd(2)   TYPE n,
          lv_result1  TYPE i,
          lv_result2  TYPE i,
          lv_result3  TYPE i,
          lv_resto    TYPE i.

    CONSTANTS: lc_cart TYPE char2 VALUE '09',
               lc_dv_p TYPE char1 VALUE 'P'.

    ls_cb13 = iv_nos_numero.

    lv_pos = strlen( iv_nos_numero ) - 1.
    lv_qtd = 3.

    ls_cb13(02) = lc_cart.

    DO lv_qtd TIMES.

      lv_mult2 = 2.

      DO 6 TIMES.                                        "#EC CI_NESTED

        lv_mult1   = ls_cb13+lv_pos(1).
        lv_result1 = ( lv_mult1 * lv_mult2 ).
        lv_result2 = lv_result2 + lv_result1.

        IF lv_pos EQ 0.
          EXIT.
        ENDIF.

        SUBTRACT 1 FROM lv_pos.
        ADD 1 TO lv_mult2.
      ENDDO.
    ENDDO.

    IF lv_result2 IS NOT INITIAL.

      lv_resto   = lv_result2 MOD 11.
      lv_result3 = 11 - lv_resto.

      CASE lv_result3.
        WHEN 10.
          rv_digvrf = 'P'.
        WHEN 11.
          rv_digvrf = 0.
        WHEN OTHERS.
          rv_digvrf = lv_result3.
      ENDCASE.

    ENDIF.
  ENDMETHOD.


  METHOD intrv_nosso_numero.

    SELECT SINGLE *
      FROM ztfi_boleto_nn
      INTO @rs_nnumero
     WHERE bukrs = @iv_bukrs
       AND hbkid = @iv_hbkid.

    CHECK sy-subrc IS INITIAL.

    IF iv_xref3 IS INITIAL.
      ADD 1 TO rs_nnumero-nosso_numero.
      MODIFY ztfi_boleto_nn FROM rs_nnumero.
    ELSE.
      rs_nnumero-nosso_numero = iv_xref3.
    ENDIF.

  ENDMETHOD.


  METHOD linha_digitavel.

    DATA: ls_ldigitav TYPE zsfi_boleto_ld.

    DATA: lv_11 TYPE char01,
          lv_10 TYPE zsfi_boleto_dv10.

    CONSTANTS: lc_ponto TYPE char1 VALUE '.'.

    ls_ldigitav-campo1(4)   = iv_cb(4).
    ls_ldigitav-campo1+4(1) = iv_cb+19(1).
    ls_ldigitav-campo1+5(1) = lc_ponto.
    ls_ldigitav-campo1+6(4) = iv_cb+20(4).

    ls_ldigitav-campo2(5)   = iv_cb+24(5).
    ls_ldigitav-campo2+5(1) = lc_ponto.
    ls_ldigitav-campo2+6(5) = iv_cb+29(5).

    ls_ldigitav-campo3(5)   = iv_cb+34(5).
    ls_ldigitav-campo3+5(1) = lc_ponto.
    ls_ldigitav-campo3+6(5) = iv_cb+39(5).

    CALL METHOD zclfi_boleto_funcionalidades=>dig_verf_mod11
      EXPORTING
        iv_cb     = iv_cb
      RECEIVING
        rv_digvrf = lv_11.

    ls_ldigitav-campo4 = lv_11.

    ls_ldigitav-campo5(4)    = iv_cb+5(4).
    ls_ldigitav-campo5+4(10) = iv_cb+9(10).

    CALL METHOD zclfi_boleto_funcionalidades=>dig_verf_mod10
      EXPORTING
        is_lnh_dig = ls_ldigitav
      RECEIVING
        rs_digvrf  = lv_10.

    ls_ldigitav-campo1+10(1)   = lv_10-dv_cp1.
    ls_ldigitav-campo2+11(1)   = lv_10-dv_cp2.
    ls_ldigitav-campo3+11(1)   = lv_10-dv_cp3.

    MOVE ls_ldigitav TO rs_ld.

  ENDMETHOD.
ENDCLASS.
