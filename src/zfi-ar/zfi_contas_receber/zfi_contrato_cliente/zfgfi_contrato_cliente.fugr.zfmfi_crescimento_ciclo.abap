FUNCTION zfmfi_crescimento_ciclo.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IV_CONTRATO) TYPE  ZE_NUM_CONTRATO
*"     REFERENCE(IV_ADITIVO) TYPE  ZE_NUM_ADITIVO OPTIONAL
*"     REFERENCE(IV_EXERCICIO) TYPE  GJAHR
*"  EXPORTING
*"     REFERENCE(ET_CICLOS) TYPE  ZCTGFI_CRESC_CICLO
*"  EXCEPTIONS
*"      CONTRATO_NOT_FOUND
*"      ADITIVO_NOT_FOUND
*"----------------------------------------------------------------------
  DATA: lv_begda  TYPE begda,
        lv_endda  TYPE endda,
        lv_endda2 TYPE endda.

  SELECT contrato,
         aditivo,
         periodicidade,
         inicio_periodic
    FROM ztfi_cad_cresci
   WHERE contrato = @iv_contrato
    INTO TABLE @DATA(lt_cresc).

  IF iv_aditivo IS SUPPLIED.
    DELETE lt_cresc WHERE aditivo NE iv_aditivo.
  ENDIF.

  TRY.
      DATA(ls_cresc) = lt_cresc[ 1 ].
    CATCH cx_sy_itab_line_not_found INTO DATA(lr_err).
  ENDTRY.

  IF ls_cresc-inicio_periodic = '00'.
    ls_cresc-inicio_periodic = '01'.
  ENDIF.

  lv_begda = CONV datum( |{ iv_exercicio }{ ls_cresc-inicio_periodic }01| ).

  DATA(lv_iter) = SWITCH numc2( ls_cresc-periodicidade
                                         WHEN 'M' THEN 12
                                         WHEN 'B' THEN 6
                                         WHEN 'T' THEN 4
                                         WHEN 'Q' THEN 3
                                         WHEN 'S' THEN 2
                                         WHEN 'A' THEN 1 ).

  DATA(lv_perio) = SWITCH numc2( ls_cresc-periodicidade
                                          WHEN 'M' THEN 1
                                          WHEN 'B' THEN 2
                                          WHEN 'T' THEN 3
                                          WHEN 'Q' THEN 4
                                          WHEN 'S' THEN 6
                                          WHEN 'A' THEN 12 ).

  DO lv_iter TIMES.

    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        days      = 0
        date      = lv_begda
        months    = lv_perio
        years     = 0
      IMPORTING
        calc_date = lv_endda.


    lv_endda2 = lv_endda - 1.

    et_ciclos = VALUE #( BASE et_ciclos ( ciclo = sy-index begda = lv_begda endda = lv_endda2 ) ).

    lv_begda = lv_endda.

  ENDDO.

  DELETE et_ciclos WHERE endda > sy-datum.

ENDFUNCTION.
