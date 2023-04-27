FUNCTION zfmfi_dda_atrib.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IS_PROCESS_DDA) TYPE  J1B_ERROR_DDA
*"     VALUE(IV_BELNR) TYPE  BELNR_D
*"     VALUE(IV_BUZEI) TYPE  BUZEI
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  BAPIRET2_TAB
*"----------------------------------------------------------------------
  NEW zclfi_dda_xblnr( )->processa_dda_manual(
    EXPORTING
      is_dda_manual = is_process_dda
      iv_belnr   = iv_belnr
      iv_buzei   = iv_buzei
    IMPORTING
      et_return  = et_return  ).


ENDFUNCTION.
