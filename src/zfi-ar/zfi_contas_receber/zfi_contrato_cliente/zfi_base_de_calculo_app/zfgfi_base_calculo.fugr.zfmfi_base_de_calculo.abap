FUNCTION zfmfi_base_de_calculo.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IV_CONTRATO) TYPE  ZE_NUM_CONTRATO
*"     REFERENCE(IV_ADITIVO) TYPE  ZE_NUM_ADITIVO
*"     REFERENCE(IV_BUKRS) TYPE  BUKRS
*"     REFERENCE(IV_BELNR) TYPE  BELNR_D
*"     REFERENCE(IV_GJAHR) TYPE  GJAHR
*"     REFERENCE(IV_BUZEI) TYPE  BUZEI
*"     REFERENCE(IV_AJUSTE_ANUAL) TYPE  ZE_AJUSTE_ANUAL
*"     REFERENCE(IV_OBS_AJUSTE) TYPE  ZE_OBS_AJUSTE
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------


  TRY .

  SELECT SINGLE *
    FROM ztfi_calc_cresci
    INTO @DATA(ls_calc)
    WHERE contrato = @iv_contrato AND
          aditivo  = @iv_aditivo  AND
          bukrs    = @iv_bukrs    AND
          belnr    = @iv_belnr    AND
          gjahr    = @iv_gjahr    AND
          buzei    = @iv_buzei    AND
          ajuste_anual = @iv_ajuste_anual.

  IF sy-subrc IS INITIAL.

    ls_calc-obs_ajuste = iv_obs_ajuste.
    ls_calc-bonus_calculado =  abap_false.


    MODIFY ztfi_calc_cresci FROM ls_calc.

  ENDIF.

    CATCH cx_root INTO DATA(lo_catch). " Missing Input parameter in a method

      CALL FUNCTION 'RS_EXCEPTION_TO_BAPIRET2' "Convert Expection into Message
        EXPORTING
          i_r_exception = lo_catch             " cx_root       Abstract Superclass for All Global Exceptions
        CHANGING
          c_t_bapiret2  = et_return.           " bapirettab    BW: Table with Messages (Application Log)

  ENDTRY.


ENDFUNCTION.
