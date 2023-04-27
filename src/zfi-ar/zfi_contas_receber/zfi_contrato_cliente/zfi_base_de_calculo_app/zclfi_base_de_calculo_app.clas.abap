CLASS zclfi_base_de_calculo_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS apaga_base
      IMPORTING
        !iv_contrato     TYPE ze_num_contrato
        !iv_aditivo      TYPE ze_num_aditivo
        !iv_bukrs        TYPE bukrs
        !iv_belnr        TYPE belnr_d
        !iv_gjahr        TYPE gjahr
        !iv_buzei        TYPE buzei
        !iv_ajuste_anual TYPE ze_ajuste_anual
        !iv_obs_ajuste   TYPE ze_obs_ajuste
        !iv_gsber        TYPE gsber
        !iv_familia_cl   TYPE rkeg_wwmt1
        !iv_chave_manual TYPE ze_chave_manual
      EXPORTING
        !et_return       TYPE bapiret2_t .
    METHODS update_calc_cresci
      IMPORTING
        !is_values       TYPE ztfi_calc_cresci
        !iv_contrato     TYPE ze_num_contrato
        !iv_aditivo      TYPE ze_num_aditivo
        !iv_bukrs        TYPE bukrs
        !iv_belnr        TYPE belnr_d
        !iv_gjahr        TYPE gjahr
        !iv_buzei        TYPE buzei
        !iv_ajuste_anual TYPE ze_ajuste_anual
        !iv_gsber        TYPE gsber
        !iv_familia_cl   TYPE rkeg_wwmt1
        !iv_chave_manual TYPE ze_chave_manual
      EXPORTING
        !et_return       TYPE bapiret2_t .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zclfi_base_de_calculo_app IMPLEMENTATION.


  METHOD apaga_base.
    TRY .

        SELECT SINGLE *                              "#EC CI_SEL_NESTED
          FROM ztfi_calc_cresci
          INTO @DATA(ls_calc)
          WHERE contrato     = @iv_contrato AND
                aditivo      = @iv_aditivo  AND
                bukrs        = @iv_bukrs    AND
                belnr        = @iv_belnr    AND
                gjahr        = @iv_gjahr    AND
                buzei        = @iv_buzei    AND
                ajuste_anual = @iv_ajuste_anual AND
                gsber        = @iv_gsber AND
                familia_cl   = @iv_familia_cl AND
                chave_manual = @iv_chave_manual.

        IF sy-subrc IS INITIAL.

          ls_calc-obs_ajuste = iv_obs_ajuste.
          ls_calc-bonus_calculado =  abap_false.
          ls_calc-mont_bonus =  abap_false.


          MODIFY ztfi_calc_cresci FROM ls_calc.     "#EC CI_IMUD_NESTED
          IF sy-subrc IS INITIAL.
            et_return[] = VALUE #( BASE et_return ( type = 'S' id = 'ZFI_BASE_CALCULO' number = '006' ) ).
          ENDIF.

        ENDIF.

      CATCH cx_root INTO DATA(lo_catch). " Missing Input parameter in a method

        CALL FUNCTION 'RS_EXCEPTION_TO_BAPIRET2' "Convert Expection into Message
          EXPORTING
            i_r_exception = lo_catch             " cx_root       Abstract Superclass for All Global Exceptions
          CHANGING
            c_t_bapiret2  = et_return.           " bapirettab    BW: Table with Messages (Application Log)

    ENDTRY.
  ENDMETHOD.


  METHOD update_calc_cresci.
    TRY .
        SELECT SINGLE *                              "#EC CI_SEL_NESTED
          FROM ztfi_calc_cresci
          INTO @DATA(ls_calc)
          WHERE contrato = @is_values-contrato AND
                aditivo  = @is_values-aditivo  AND
                bukrs    = @is_values-bukrs    AND
                belnr    = @is_values-belnr    AND
                gjahr    = @is_values-gjahr    AND
                buzei    = @is_values-buzei    .

        IF sy-subrc IS INITIAL.

* Campos CHAVE
*          IF iv_contrato IS NOT INITIAL AND
*            ls_calc-contrato NE iv_contrato.
*            DATA(lv_contrato) = ls_calc-contrato.    "número antigo
*            ls_calc-contrato  = iv_contrato.         "número novo
*
*          ENDIF.
*
*          IF iv_aditivo IS NOT INITIAL AND
*            ls_calc-aditivo NE iv_aditivo.
*            DATA(lv_aditivo) = ls_calc-aditivo.
*            ls_calc-aditivo = iv_aditivo.
*
*          ENDIF.

          IF iv_bukrs IS NOT INITIAL AND
             ls_calc-bukrs NE iv_bukrs.

            ls_calc-bukrs = iv_bukrs.

          ENDIF.

          IF iv_belnr IS NOT INITIAL AND
             ls_calc-belnr NE iv_belnr.

            ls_calc-belnr = iv_belnr.

          ENDIF.

          IF iv_gjahr IS NOT INITIAL AND
             ls_calc-gjahr NE iv_gjahr .

            ls_calc-gjahr = iv_gjahr.

          ENDIF.

          IF iv_buzei IS NOT INITIAL AND
             ls_calc-buzei NE iv_buzei.

            ls_calc-buzei = iv_buzei.

          ENDIF.

          IF iv_ajuste_anual IS NOT INITIAL AND
             ls_calc-ajuste_anual NE iv_ajuste_anual.

            ls_calc-ajuste_anual = iv_ajuste_anual.

          ENDIF.

          IF iv_gsber IS NOT INITIAL AND
             ls_calc-gsber NE iv_gsber.

            ls_calc-gsber = iv_gsber.

          ENDIF.

          IF iv_familia_cl IS NOT INITIAL AND
             ls_calc-familia_cl NE iv_familia_cl.

            ls_calc-familia_cl = iv_familia_cl.

          ENDIF.

          IF iv_chave_manual IS NOT INITIAL AND
            ls_calc-chave_manual NE iv_chave_manual.
            ls_calc-chave_manual = iv_chave_manual.

          ENDIF.

* Demais CAMPOS
          IF is_values-wrbtr IS NOT INITIAL AND
             ls_calc-wrbtr NE is_values-wrbtr.

            ls_calc-wrbtr = is_values-wrbtr.

          ENDIF.

          IF is_values-bschl IS NOT INITIAL AND
             ls_calc-bschl NE is_values-bschl.

            ls_calc-bschl = is_values-bschl.

          ENDIF.
          IF is_values-blart IS NOT INITIAL AND
             ls_calc-blart NE is_values-blart.

            ls_calc-blart = is_values-blart.

          ENDIF.
          IF is_values-zuonr IS NOT INITIAL AND
            ls_calc-zuonr NE is_values-zuonr.

            ls_calc-zuonr = is_values-zuonr.

          ENDIF.
          IF is_values-kunnr IS NOT INITIAL AND
             ls_calc-kunnr NE is_values-kunnr.

            ls_calc-kunnr = is_values-kunnr.

          ENDIF.

          IF is_values-zlsch IS NOT INITIAL AND
             ls_calc-zlsch NE is_values-zlsch.

            ls_calc-zlsch = is_values-zlsch.

          ENDIF.
          IF is_values-sgtxt IS NOT INITIAL AND
             ls_calc-sgtxt NE is_values-sgtxt.

            ls_calc-sgtxt = is_values-sgtxt.

          ENDIF.
          IF is_values-netdt IS NOT INITIAL AND
             ls_calc-netdt NE is_values-netdt.

            ls_calc-netdt = is_values-netdt.

          ENDIF.
          IF is_values-xblnr IS NOT INITIAL AND
             ls_calc-xblnr NE is_values-xblnr.

            ls_calc-xblnr = is_values-xblnr.

          ENDIF.
          IF is_values-budat IS NOT INITIAL AND
             ls_calc-budat NE is_values-budat.

            ls_calc-budat = is_values-budat.

          ENDIF.
          IF is_values-bldat IS NOT INITIAL AND
       ls_calc-bldat NE is_values-bldat.

            ls_calc-bldat = is_values-bldat.

          ENDIF.
          IF is_values-augbl IS NOT INITIAL AND
             ls_calc-augbl NE is_values-augbl.

            ls_calc-augbl = is_values-augbl.

          ENDIF.
          IF is_values-augdt IS NOT INITIAL AND
             ls_calc-augdt NE is_values-augdt.

            ls_calc-augdt = is_values-augdt.

          ENDIF.
          IF is_values-vbeln IS NOT INITIAL AND
             ls_calc-vbeln NE is_values-vbeln.

            ls_calc-vbeln = is_values-vbeln.

          ENDIF.
          IF is_values-posnr IS NOT INITIAL AND
             ls_calc-posnr NE is_values-posnr.

            ls_calc-posnr = is_values-posnr.

          ENDIF.
          IF is_values-vgbel IS NOT INITIAL AND
             ls_calc-vgbel NE is_values-vgbel.

            ls_calc-vgbel = is_values-vgbel.

          ENDIF.
          IF is_values-vtweg IS NOT INITIAL AND
             ls_calc-vtweg NE is_values-vtweg.

            ls_calc-vtweg = is_values-vtweg.

          ENDIF.
          IF is_values-spart IS NOT INITIAL AND
             ls_calc-spart NE is_values-spart.

            ls_calc-spart = is_values-spart.

          ENDIF.
          IF is_values-bzirk IS NOT INITIAL AND
             ls_calc-bzirk NE is_values-bzirk.

            ls_calc-bzirk = is_values-bzirk.

          ENDIF.
          IF is_values-katr2 IS NOT INITIAL AND
             ls_calc-katr2 NE is_values-katr2.

            ls_calc-katr2 = is_values-katr2.

          ENDIF.
          IF is_values-wwmt1 IS NOT INITIAL AND
             ls_calc-wwmt1 NE is_values-wwmt1.

            ls_calc-wwmt1 = is_values-wwmt1.

          ENDIF.
          IF is_values-prctr IS NOT INITIAL AND
             ls_calc-prctr NE is_values-prctr.

            ls_calc-prctr = is_values-prctr.

          ENDIF.
          IF is_values-tipo_entrega IS NOT INITIAL AND
             ls_calc-tipo_entrega NE is_values-tipo_entrega.

            ls_calc-tipo_entrega = is_values-tipo_entrega.

          ENDIF.
          IF is_values-xref1_hd IS NOT INITIAL AND
             ls_calc-xref1_hd NE is_values-xref1_hd.

            ls_calc-xref1_hd = is_values-xref1_hd.

          ENDIF.
          IF is_values-status_dde IS NOT INITIAL AND
             ls_calc-status_dde NE is_values-status_dde.

            ls_calc-status_dde = is_values-status_dde.

          ENDIF.
          IF is_values-tipo_apuracao IS NOT INITIAL AND
             ls_calc-tipo_apuracao NE is_values-tipo_apuracao.

            ls_calc-tipo_apuracao = is_values-tipo_apuracao.

          ENDIF.
          IF is_values-tipo_ap_imposto IS NOT INITIAL AND
             ls_calc-tipo_ap_imposto NE is_values-tipo_ap_imposto.

            ls_calc-tipo_ap_imposto = is_values-tipo_ap_imposto.

          ENDIF.
          IF is_values-tipo_imposto IS NOT INITIAL AND
             ls_calc-tipo_imposto NE is_values-tipo_imposto.

            ls_calc-tipo_imposto = is_values-tipo_imposto.

          ENDIF.
          IF is_values-impost_desconsid IS NOT INITIAL AND
             ls_calc-impost_desconsid NE is_values-impost_desconsid.

            ls_calc-impost_desconsid = is_values-impost_desconsid.

          ENDIF.
          IF is_values-mont_liq_tax IS NOT INITIAL AND
             ls_calc-mont_liq_tax NE is_values-mont_liq_tax.

            ls_calc-mont_liq_tax = is_values-mont_liq_tax.

          ENDIF.
          IF is_values-mont_valido IS NOT INITIAL AND
             ls_calc-mont_valido NE is_values-mont_valido.

            ls_calc-mont_valido = is_values-mont_valido.

          ENDIF.
          IF is_values-tipo_desconto IS NOT INITIAL AND
             ls_calc-tipo_desconto NE is_values-tipo_desconto.

            ls_calc-tipo_desconto = is_values-tipo_desconto.

          ENDIF.
          IF is_values-cond_desconto IS NOT INITIAL AND
             ls_calc-cond_desconto NE is_values-cond_desconto.

            ls_calc-cond_desconto = is_values-cond_desconto.

          ENDIF.
          IF is_values-kostl IS NOT INITIAL AND
             ls_calc-kostl NE is_values-kostl.

            ls_calc-kostl = is_values-kostl.

          ENDIF.
          IF is_values-mont_bonus IS NOT INITIAL AND
             ls_calc-mont_bonus NE is_values-mont_bonus.

            ls_calc-mont_bonus = is_values-mont_bonus.

          ENDIF.
          IF is_values-bonus_calculado IS NOT INITIAL AND
             ls_calc-bonus_calculado NE is_values-bonus_calculado.

            ls_calc-bonus_calculado = is_values-bonus_calculado.

          ENDIF.
          IF is_values-obs_ajuste IS NOT INITIAL AND
             ls_calc-obs_ajuste NE is_values-obs_ajuste.

            ls_calc-obs_ajuste = is_values-obs_ajuste.

          ENDIF.

          MODIFY ztfi_calc_cresci FROM ls_calc.
          IF sy-subrc IS INITIAL.
            et_return[] = VALUE #( BASE et_return ( type = 'S' id = 'ZFI_BASE_CALCULO' number = '006' ) ).
          ENDIF.

*          IF lv_contrato IS NOT INITIAL OR
*             lv_aditivo  IS NOT INITIAL .
*
*            me->update_contrato(
*             EXPORTING
*             iv_contrato     = lv_contrato
*             iv_contrato_new = ls_calc-contrato
*             iv_aditivo      = lv_aditivo
*             iv_aditivo_new  = ls_calc-aditivo
*             IMPORTING
*             et_return = DATA(lt_return) ).
*          ENDIF.

        ENDIF.

      CATCH cx_mdg_missing_input_parameter INTO DATA(lo_catch). " Missing Input parameter in a method

        CALL FUNCTION 'RS_EXCEPTION_TO_BAPIRET2' "Convert Expection into Message
          EXPORTING
            i_r_exception = lo_catch             " cx_root       Abstract Superclass for All Global Exceptions
          CHANGING
            c_t_bapiret2  = et_return.           " bapirettab    BW: Table with Messages (Application Log)

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
