FUNCTION zfmfi_wf_docpagar_app_upd.
*"----------------------------------------------------------------------
*"*"Módulo função atualização:
*"
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_BELNR) TYPE  BELNR_D
*"     VALUE(IV_BUKRS) TYPE  BUKRS
*"     VALUE(IV_GJAHR) TYPE  GJAHR
*"     VALUE(IV_BUZEI) TYPE  BUZEI
*"----------------------------------------------------------------------

  SELECT SINGLE koart
           FROM bseg
           INTO @DATA(lv_koart)
          WHERE bukrs EQ @iv_bukrs
            AND belnr EQ @iv_belnr
            AND gjahr EQ @iv_gjahr
            AND buzei EQ @iv_buzei.

  IF sy-subrc EQ 0 AND lv_koart EQ 'K'.

    NEW zclfi_doc_pagar_wf( iv_belnr = iv_belnr
                            iv_bukrs = iv_bukrs
                            iv_gjahr = iv_gjahr
                            iv_buzei = iv_buzei )->trigger_start_wf( ).

  ENDIF.

ENDFUNCTION.
